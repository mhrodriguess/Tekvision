import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../ai/yolo_detection_service.dart';
import '../l10n/strings.dart';
import '../services/esp32_camera_service.dart';
import '../services/tts_service.dart';
import '../state/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/caption_bar.dart';
import '../widgets/tek_action_card.dart';
import '../widgets/tek_logo.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

/// Tela principal do TekVision.
///
/// Layout (de cima para baixo): logo pequena e centralizada, área fixa
/// de visualização da câmera, indicador opcional "Sistema ativo", e os
/// 3 controles principais (Iniciar/Parar, Configurações, Ajuda) + barra
/// de legenda.
///
/// IMPORTANTE DE ACESSIBILIDADE: a área de câmera é SEMPRE renderizada
/// (com altura fixa), estando o sistema ligado ou não — ela só troca o
/// que mostra dentro do mesmo espaço. Isso é proposital: como o botão
/// "Iniciar/Parar" e os demais controles ficam depois dela na coluna,
/// se a área aparecesse/desaparecesse condicionalmente ela empurraria
/// os botões para cima ou para baixo ao iniciar/parar o sistema — o
/// que quebra a previsibilidade de toque para quem usa o app sem
/// enxergar a tela. Por isso a área nunca é adicionada/removida da
/// árvore; só o conteúdo dela muda.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// IP da ESP32-CAM dentro da rede Wi-Fi PRIVADA que ela mesma cria
/// (modo Access Point). O celular precisa estar conectado a essa rede
/// (SSID "TekVision-Cam" por padrão, ver `esp32cam_capture.ino`) para
/// alcançar este IP — não é a rede doméstica/roteador.
const String _esp32Host = '192.168.4.1';

class _HomeScreenState extends State<HomeScreen> with PrefsReactive {
  bool _running = false;
  final TapSelectionController _selection = TapSelectionController();

  @override
  void initState() {
    super.initState();
    TtsService.instance.init();
  }

  @override
  void dispose() {
    // Evita continuar buscando/processando frames se o usuário sair do
    // app com o sistema em execução.
    Esp32CameraService.instance.disconnect();
    YoloDetectionService.instance.stop();
    super.dispose();
  }

  void _toggleSystem() {
    setState(() => _running = !_running);
    TtsService.instance.speak(_running ? t(L.systemStartedMsg) : t(L.systemStoppedMsg));

    if (_running) {
      Esp32CameraService.instance.connect(_esp32Host);
      YoloDetectionService.instance.start();
    } else {
      YoloDetectionService.instance.stop();
      Esp32CameraService.instance.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TekColors.bgBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TekColors.bgTop, TekColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 4),
                const TekLogo(width: 120),
                const SizedBox(height: 14),

                // Área de câmera: sempre presente, altura fixa. Ver
                // comentário da classe acima sobre por que isso não é
                // condicional.
                _CameraPreviewArea(running: _running),

                if (_running) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: TekColors.parar),
                      const SizedBox(width: 6),
                      Text(
                        t(L.systemActive),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: TekColors.parar,
                        ),
                      ),
                    ],
                  ),
                ],
                // Nota: este indicador aparece/desaparece acima do
                // Spacer abaixo, então não desloca o botão
                // Iniciar/Parar nem os demais controles — o Spacer
                // absorve a diferença de altura.
                const Spacer(),

                TekActionCard(
                  icon: _running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  title: _running ? t(L.stopSystem) : t(L.startSystem),
                  idleSubtitle: _running ? t(L.stopSystemHint) : t(L.startSystemHint),
                  color: _running ? TekColors.parar : TekColors.iniciar,
                  emphasis: 1.0,
                  selectionController: _selection,
                  onConfirmed: _toggleSystem,
                ),
                const SizedBox(height: 16),

                TekActionCard(
                  icon: Icons.settings_rounded,
                  title: t(L.settings),
                  idleSubtitle: t(L.settingsHint),
                  color: TekColors.configuracoes,
                  emphasis: 0.55,
                  selectionController: _selection,
                  onConfirmed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                const SizedBox(height: 16),

                TekActionCard(
                  icon: Icons.help_outline_rounded,
                  title: t(L.help),
                  idleSubtitle: t(L.helpHint),
                  color: TekColors.ajuda,
                  emphasis: 0.5,
                  selectionController: _selection,
                  onConfirmed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
                  },
                ),
                const SizedBox(height: 16),
                const CaptionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Área fixa de visualização da câmera, sempre presente na árvore
/// (altura constante), logo abaixo da logo e acima do botão
/// Iniciar/Parar. Troca apenas o conteúdo interno conforme o sistema
/// está ligado/desligado e conforme o estado da conexão com a
/// ESP32-CAM.
class _CameraPreviewArea extends StatelessWidget {
  final bool running;

  const _CameraPreviewArea({required this.running});

  String _statusLabel(TekConnectionState state) {
    switch (state) {
      case TekConnectionState.disconnected:
        return t(L.espDisconnected);
      case TekConnectionState.connecting:
        return t(L.espConnecting);
      case TekConnectionState.connected:
        return t(L.espConnected);
      case TekConnectionState.error:
        return t(L.espError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Esp32CameraService.instance;
    return Container(
      height: 150,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TekColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TekColors.cardBorderIdle),
      ),
      child: !running
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_outlined, color: TekColors.subtitleText, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    t(L.cameraPreviewOff),
                    style: TextStyle(fontSize: 12, color: TekColors.subtitleText),
                  ),
                ],
              ),
            )
          : ValueListenableBuilder<TekConnectionState>(
              valueListenable: service.connectionState,
              builder: (context, state, _) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ValueListenableBuilder<Uint8List?>(
                      valueListenable: service.lastFrame,
                      builder: (context, frame, _) {
                        if (frame == null) {
                          return Center(
                            child: Text(
                              t(L.cameraPreviewWaiting),
                              style: TextStyle(fontSize: 12, color: TekColors.subtitleText),
                            ),
                          );
                        }
                        return Image.memory(
                          frame,
                          fit: BoxFit.cover,
                          gaplessPlayback: true, // evita "flash" entre frames
                        );
                      },
                    ),
                    Positioned(
                      left: 8,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(state),
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
