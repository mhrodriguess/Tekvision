import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import '../l10n/strings.dart';
import '../services/esp32_camera_service.dart';
import '../services/tts_service.dart';
import '../state/app_preferences.dart';

/// Zona horizontal do centro da bounding box no quadro da câmera, já
/// corrigida para o espelhamento da ESP32-CAM (ver `_horizontalZone`).
/// É uma aproximação visual — não representa distância.
enum _HZone { extremeLeft, left, center, right, extremeRight }

/// Zona vertical do centro da bounding box no quadro da câmera.
enum _VZone { top, middle, bottom }

/// Roda o YOLO26n (`assets/models/yolo26n.tflite`) localmente no
/// smartphone sobre os frames que a ESP32-CAM já está entregando via
/// [Esp32CameraService], e converte as detecções relevantes em
/// alertas curtos falados pelo [TtsService] já existente no app.
///
/// Não recebe imagem por conta própria — apenas escuta
/// `Esp32CameraService.instance.lastFrame`, que é o mesmo frame usado
/// pela pré-visualização da tela principal. Não há um segundo canal
/// de comunicação com a ESP32-CAM, nem um segundo sistema de TTS.
///
/// Processa sempre o frame mais recente: se uma inferência ainda está
/// rodando quando um novo frame chega, o novo frame é descartado (não
/// se acumula fila) — o próximo frame que chegar depois que a
/// inferência atual terminar é que será processado.
class YoloDetectionService {
  YoloDetectionService._internal();
  static final YoloDetectionService instance = YoloDetectionService._internal();

  static const String _modelAssetPath = 'assets/models/yolo26n.tflite';

  final YOLO _yolo = YOLO(modelPath: _modelAssetPath, task: YOLOTask.detect);

  bool _modelLoaded = false;
  Future<bool>? _modelLoading;

  bool _running = false;
  bool _busy = false;

  // --- Zonas horizontais (5) ---------------------------------------
  // 0.0 = borda esquerda da imagem JÁ CORRIGIDA (física), 1.0 = borda
  // direita física. Ver `_horizontalZone` para a correção do
  // espelhamento da ESP32-CAM.
  static const double _extremeLeftBoundary = 0.15;
  static const double _leftBoundary = 0.40;
  static const double _rightBoundary = 0.60;
  static const double _extremeRightBoundary = 0.85;

  // --- Zonas verticais (3) -------------------------------------------
  // 0.0 = topo da imagem, 1.0 = base da imagem.
  static const double _topBoundary = 0.35;
  static const double _bottomBoundary = 0.65;

  // Confiança mínima para um alerta ser falado. Detecções abaixo disso
  // são ignoradas — reduz falsos positivos e ruído de alertas.
  static const double _minConfidence = 0.55;

  // Evita repetir o MESMO alerta (mesmo objeto, mesma zona) enquanto
  // ele continuar lá. Só reforça depois desse intervalo.
  static const Duration _sameKeyCooldown = Duration(seconds: 4);

  // Intervalo mínimo entre quaisquer dois alertas falados, mesmo que
  // sejam de objetos/zonas diferentes. Evita "tagarelice" quando um
  // objeto oscila entre duas zonas vizinhas quase a cada frame
  // (~130ms), ou quando vários objetos aparecem quase ao mesmo tempo.
  static const Duration _minGapBetweenAlerts = Duration(milliseconds: 1200);

  // Se um objeto que estava sendo anunciado some da cena por mais que
  // esse tempo, ele é tratado como "desaparecido": se reaparecer
  // depois, soa como um alerta novo (não fica preso ao cooldown de
  // repetição de antes de sumir).
  static const Duration _disappearGap = Duration(milliseconds: 900);

  String? _lastAnnouncedKey;
  DateTime? _lastAnnouncedAt;
  DateTime? _lastSeenAt;

  /// Liga o processamento. Deve ser chamado junto com o mesmo
  /// `_toggleSystem()` que já inicia `Esp32CameraService`.
  void start() {
    if (_running) return;
    _running = true;
    _lastAnnouncedKey = null;
    _lastAnnouncedAt = null;
    _lastSeenAt = null;
    // Carregamento do modelo roda em segundo plano; não atrasa o
    // início do sistema nem a pré-visualização da câmera, que
    // funcionam independentemente disso.
    unawaited(_ensureModelLoaded());
    Esp32CameraService.instance.lastFrame.addListener(_onFrameChanged);
  }

  /// Desliga o processamento. Uma inferência já em andamento termina
  /// normalmente, mas seu resultado é ignorado (ver `_runInference`).
  void stop() {
    if (!_running) return;
    _running = false;
    Esp32CameraService.instance.lastFrame.removeListener(_onFrameChanged);
  }

  Future<bool> _ensureModelLoaded() async {
    if (_modelLoaded) return true;
    if (_modelLoading != null) return _modelLoading!;
    final future = _loadModel();
    _modelLoading = future;
    final ok = await future;
    _modelLoading = null;
    return ok;
  }

  Future<bool> _loadModel() async {
    try {
      final ok = await _yolo.loadModel();
      _modelLoaded = ok;
      if (!ok) {
        debugPrint('[YOLO] loadModel() retornou false para $_modelAssetPath');
      }
      return ok;
    } catch (e) {
      debugPrint('[YOLO] Falha ao carregar o modelo: $e');
      return false;
    }
  }

  void _onFrameChanged() {
    if (!_running || _busy) return; // frame descartado: já há uma inferência em curso
    final frame = Esp32CameraService.instance.lastFrame.value;
    if (frame == null) return;
    _busy = true;
    _runInference(frame).whenComplete(() => _busy = false);
  }

  Future<void> _runInference(Uint8List frameBytes) async {
    try {
      final loaded = await _ensureModelLoaded();
      if (!loaded || !_running) return;

      final result = await _yolo.predict(frameBytes);
      if (!_running) return; // sistema foi parado enquanto a inferência rodava

      final rawDetections = (result['detections'] as List?) ?? const [];
      final detections = rawDetections
          .map((d) => YOLOResult.fromMap(d as Map))
          .where((r) => r.confidence >= _minConfidence)
          .toList();

      if (detections.isEmpty) {
        _handleNothingDetected();
        return;
      }

      // Só o objeto mais confiável do frame gera alerta. Evita que
      // várias detecções no mesmo frame virem uma fila de mensagens —
      // e mantém o aviso curto e único por vez.
      detections.sort((a, b) => b.confidence.compareTo(a.confidence));
      final best = detections.first;
      _lastSeenAt = DateTime.now();

      // A imagem da ESP32-CAM chega espelhada horizontalmente (visão
      // "selfie"). Corrige-se aqui, no cálculo da posição, invertendo o
      // eixo X — sem tocar na comunicação ESP32-CAM ↔ app nem decodificar
      // e reprocessar a imagem em si (mais simples e mais barato, já que
      // só a leitura da coordenada precisa ser corrigida).
      final mirroredCenterX = 1.0 - best.normalizedBox.center.dx;

      final hZone = _horizontalZone(mirroredCenterX);
      final vZone = _verticalZone(best.normalizedBox.center.dy);
      final key = '${best.className}|${hZone.name}|${vZone.name}';

      _maybeAnnounce(key, best.className, hZone, vZone);
    } catch (e) {
      debugPrint('[YOLO] Erro na inferência: $e');
    }
  }

  /// Chamado quando o frame atual não teve nenhuma detecção relevante.
  /// Se o objeto que estava sendo anunciado ficar ausente por tempo
  /// suficiente, ele é considerado "fora de cena": a próxima vez que
  /// algo for detectado, soa como um alerta novo, mesmo que seja o
  /// mesmo objeto na mesma posição de antes.
  void _handleNothingDetected() {
    if (_lastAnnouncedKey == null) return;
    final lastSeen = _lastSeenAt;
    if (lastSeen == null) return;
    if (DateTime.now().difference(lastSeen) >= _disappearGap) {
      _lastAnnouncedKey = null;
    }
  }

  void _maybeAnnounce(String key, String rawClassName, _HZone hZone, _VZone vZone) {
    final now = DateTime.now();
    final sinceLast = _lastAnnouncedAt == null ? null : now.difference(_lastAnnouncedAt!);
    final isNewKey = key != _lastAnnouncedKey;

    final minGapOk = sinceLast == null || sinceLast >= _minGapBetweenAlerts;
    final repeatOk = isNewKey || sinceLast == null || sinceLast >= _sameKeyCooldown;
    if (!minGapOk || !repeatOk) return;

    _lastAnnouncedKey = key;
    _lastAnnouncedAt = now;

    final message = fill(
      fill(t(L.detectionAlert), 'object', _localizedClassName(rawClassName)),
      'position',
      _describePosition(hZone, vZone),
    );
    TtsService.instance.speak(message); // fire-and-forget, mesmo padrão usado no resto do app
  }

  _HZone _horizontalZone(double x) {
    if (x < _extremeLeftBoundary) return _HZone.extremeLeft;
    if (x < _leftBoundary) return _HZone.left;
    if (x <= _rightBoundary) return _HZone.center;
    if (x <= _extremeRightBoundary) return _HZone.right;
    return _HZone.extremeRight;
  }

  _VZone _verticalZone(double y) {
    if (y < _topBoundary) return _VZone.top;
    if (y <= _bottomBoundary) return _VZone.middle;
    return _VZone.bottom;
  }

  /// Monta uma descrição curta e natural da posição, priorizando o que
  /// é útil para navegação — não fala as duas coordenadas sempre.
  ///
  /// Exemplos: "à esquerda", "à direita extrema", "no centro",
  /// "acima à direita", "abaixo à esquerda", "acima" (quando o objeto
  /// está em cima mas horizontalmente centralizado).
  String _describePosition(_HZone hZone, _VZone vZone) {
    if (vZone == _VZone.middle) {
      if (hZone == _HZone.center) return t(L.posCenter); // "no centro"
      return t(_horizontalLabelKey(hZone));
    }
    final verticalWord = t(vZone == _VZone.top ? L.posAbove : L.posBelow);
    if (hZone == _HZone.center) return verticalWord; // "acima" / "abaixo"
    return '$verticalWord ${t(_horizontalLabelKey(hZone))}';
  }

  L _horizontalLabelKey(_HZone hZone) {
    switch (hZone) {
      case _HZone.extremeLeft:
        return L.posExtremeLeft;
      case _HZone.left:
        return L.posLeft;
      case _HZone.center:
        return L.posCenter;
      case _HZone.right:
        return L.posRight;
      case _HZone.extremeRight:
        return L.posExtremeRight;
    }
  }

  String _localizedClassName(String rawClassName) {
    final code = AppPreferences.instance.localeCode.value;
    if (code == 'pt-BR') {
      final pt = _ptClassNames[rawClassName];
      if (pt != null) return _capitalize(pt);
    }
    return _capitalize(rawClassName);
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

/// Tradução dos nomes de classe do COCO (conjunto usado pelo YOLO26n
/// pré-treinado) para português. Uma classe detectada que não esteja
/// aqui simplesmente usa o nome em inglês capitalizado — não impede o
/// alerta de funcionar.
const Map<String, String> _ptClassNames = {
  'person': 'pessoa',
  'bicycle': 'bicicleta',
  'car': 'carro',
  'motorcycle': 'moto',
  'airplane': 'avião',
  'bus': 'ônibus',
  'train': 'trem',
  'truck': 'caminhão',
  'boat': 'barco',
  'traffic light': 'semáforo',
  'fire hydrant': 'hidrante',
  'stop sign': 'placa de pare',
  'parking meter': 'parquímetro',
  'bench': 'banco',
  'bird': 'pássaro',
  'cat': 'gato',
  'dog': 'cachorro',
  'horse': 'cavalo',
  'sheep': 'ovelha',
  'cow': 'vaca',
  'elephant': 'elefante',
  'bear': 'urso',
  'zebra': 'zebra',
  'giraffe': 'girafa',
  'backpack': 'mochila',
  'umbrella': 'guarda-chuva',
  'handbag': 'bolsa',
  'tie': 'gravata',
  'suitcase': 'mala',
  'frisbee': 'frisbee',
  'skis': 'esquis',
  'snowboard': 'snowboard',
  'sports ball': 'bola',
  'kite': 'pipa',
  'baseball bat': 'taco de beisebol',
  'baseball glove': 'luva de beisebol',
  'skateboard': 'skate',
  'surfboard': 'prancha de surfe',
  'tennis racket': 'raquete de tênis',
  'bottle': 'garrafa',
  'wine glass': 'taça de vinho',
  'cup': 'copo',
  'fork': 'garfo',
  'knife': 'faca',
  'spoon': 'colher',
  'bowl': 'tigela',
  'banana': 'banana',
  'apple': 'maçã',
  'sandwich': 'sanduíche',
  'orange': 'laranja',
  'broccoli': 'brócolis',
  'carrot': 'cenoura',
  'hot dog': 'cachorro-quente',
  'pizza': 'pizza',
  'donut': 'rosquinha',
  'cake': 'bolo',
  'chair': 'cadeira',
  'couch': 'sofá',
  'potted plant': 'planta',
  'bed': 'cama',
  'dining table': 'mesa',
  'toilet': 'vaso sanitário',
  'tv': 'televisão',
  'laptop': 'notebook',
  'mouse': 'mouse',
  'remote': 'controle remoto',
  'keyboard': 'teclado',
  'cell phone': 'celular',
  'microwave': 'micro-ondas',
  'oven': 'forno',
  'toaster': 'torradeira',
  'sink': 'pia',
  'refrigerator': 'geladeira',
  'book': 'livro',
  'clock': 'relógio',
  'vase': 'vaso',
  'scissors': 'tesoura',
  'teddy bear': 'ursinho de pelúcia',
  'hair drier': 'secador de cabelo',
  'toothbrush': 'escova de dente',
};
