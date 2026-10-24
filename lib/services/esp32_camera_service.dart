import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Estado da conexão com a ESP32-CAM.
///
/// Nome `TekConnectionState` (em vez de `ConnectionState`) para não
/// colidir com o enum embutido do Flutter.
enum TekConnectionState { disconnected, connecting, connected, error }

/// Serviço responsável exclusivamente por buscar frames da ESP32-CAM
/// pela rede Wi-Fi local e expor o estado da conexão.
///
/// Nesta etapa não há nenhuma lógica de IA/YOLO aqui — só comunicação.
/// Segue o mesmo padrão de `TtsService`/`AppPreferences`: singleton com
/// `ValueNotifier`, para telas reagirem sem precisar de listener manual.
class Esp32CameraService {
  Esp32CameraService._internal();
  static final Esp32CameraService instance = Esp32CameraService._internal();

  final ValueNotifier<TekConnectionState> connectionState =
      ValueNotifier<TekConnectionState>(TekConnectionState.disconnected);

  /// Último frame recebido, já em bytes JPEG — pronto para `Image.memory`.
  final ValueNotifier<Uint8List?> lastFrame = ValueNotifier<Uint8List?>(null);

  String? _host; // ex.: "192.168.1.42"
  Timer? _pollTimer;
  bool _requestInFlight = false;

  /// Intervalo entre capturas. Mudei para 130ms para um envio mais rápido
  static const _pollInterval = Duration(milliseconds: 130);
  static const _requestTimeout = Duration(seconds: 3);

  bool get isConnected => connectionState.value == TekConnectionState.connected;

  /// Inicia a busca periódica de frames em `http://$host/capture`.
  void connect(String host) {
    _host = host;
    connectionState.value = TekConnectionState.connecting;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchFrame());
    _fetchFrame(); // primeira tentativa imediata, sem esperar o timer
  }

  /// Para a busca de frames e limpa o estado.
  void disconnect() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _host = null;
    connectionState.value = TekConnectionState.disconnected;
    lastFrame.value = null;
  }

  Future<void> _fetchFrame() async {
    final host = _host;
    if (host == null || _requestInFlight) return;
    _requestInFlight = true;
    try {
      final uri = Uri.parse('http://$host/capture');
      final response = await http.get(uri).timeout(_requestTimeout);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        lastFrame.value = response.bodyBytes;
        connectionState.value = TekConnectionState.connected;
      } else {
        connectionState.value = TekConnectionState.error;
      }
    } catch (_) {
      // Falha de rede, timeout, ESP32 desligada, etc. — não derruba o
      // app; apenas reflete o erro no estado para a UI mostrar.
      connectionState.value = TekConnectionState.error;
    } finally {
      _requestInFlight = false;
    }
  }
}
