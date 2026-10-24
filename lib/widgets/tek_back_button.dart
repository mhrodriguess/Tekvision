import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'tek_action_card.dart';

/// Cabeçalho de tela com botão de voltar por toque duplo.
///
/// A área de toque cobre a LARGURA INTEIRA do cabeçalho (não só o ícone
/// ou o texto do título) — usa `SizedBox(width: double.infinity)` como
/// filho direto do `InkWell` para garantir isso mesmo dentro de um `Row`
/// ou `Column` que não force o preenchimento horizontal.
///
/// No 1º toque, fala só "Voltar" (sem "toque novamente" na voz — esse
/// aviso fica só no texto visual, como pedido). A fala nunca é esperada
/// (`await`) antes de agendar o cancelamento automático da seleção.
class TekScreenHeader extends StatefulWidget {
  final String title;
  final TapSelectionController selectionController;

  const TekScreenHeader({
    super.key,
    required this.title,
    required this.selectionController,
  });

  @override
  State<TekScreenHeader> createState() => _TekScreenHeaderState();
}

class _TekScreenHeaderState extends State<TekScreenHeader> {
  bool _awaitingConfirmation = false;
  VoidCallback? _unregister;

  @override
  void dispose() {
    _unregister?.call();
    super.dispose();
  }

  void _cancel() {
    if (mounted && _awaitingConfirmation) setState(() => _awaitingConfirmation = false);
  }

  void _handleTap() {
    if (!_awaitingConfirmation) {
      setState(() => _awaitingConfirmation = true);
      _unregister = widget.selectionController.select(_cancel);
      TtsService.instance.speak(t(L.back)); // fire-and-forget, só o nome
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingConfirmation = false);
      widget.selectionController.clear();
      TtsService.instance.speak(t(L.goingBackMsg));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _awaitingConfirmation ? '${t(L.tapAgainToConfirm)} ${t(L.back)}' : t(L.back),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          child: SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: _awaitingConfirmation ? TekColors.selecting.withValues(alpha: 0.15) : null,
                border: _awaitingConfirmation
                    ? Border(bottom: BorderSide(color: TekColors.selecting, width: 2))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TekColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_back_rounded, color: TekColors.titleText, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: TekColors.titleText,
                        ),
                      ),
                      if (_awaitingConfirmation)
                        Text(
                          t(L.backConfirmHint),
                          style: TextStyle(fontSize: 11, color: TekColors.selecting),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
