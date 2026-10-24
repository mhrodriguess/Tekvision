import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

/// Barra de legenda exibida no rodapé das telas, mostrando por escrito a
/// última mensagem falada pelo TTS. Fica oculta até a primeira fala.
class CaptionBar extends StatelessWidget {
  const CaptionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TtsService.instance.lastMessage,
      builder: (context, message, _) {
        if (message.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: TekColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TekColors.cardBorderIdle),
          ),
          child: Row(
            children: [
              Icon(Icons.volume_up_rounded, size: 18, color: TekColors.subtitleText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 13, color: TekColors.subtitleText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
