import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

/// Card de ação da tela principal.
///
/// Confirmação por toque duplo: 1º toque destaca o card (borda/brilho na
/// própria cor do card) e fala só o nome do botão; 2º toque confirma e
/// executa. Se outro `TekActionCard` for tocado antes da confirmação, a
/// seleção deste é cancelada — coordenado pelo `TapSelectionController`
/// compartilhado entre os cards da tela.
///
/// IMPORTANTE: a fala do TTS nunca é esperada (`await`) antes de agendar
/// o cancelamento automático da seleção. Se a fala travasse por algum
/// motivo (ex: engine de TTS ocupado), o botão ficaria selecionado para
/// sempre — por isso a fala é "fire-and-forget".
class TekActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String idleSubtitle;
  final Color color;
  final VoidCallback onConfirmed;

  /// Controla o quão forte é o brilho/borda em repouso (0.0–1.0).
  final double emphasis;

  final TapSelectionController selectionController;

  const TekActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.idleSubtitle,
    required this.color,
    required this.onConfirmed,
    required this.selectionController,
    this.emphasis = 0.6,
  });

  @override
  State<TekActionCard> createState() => _TekActionCardState();
}

class _TekActionCardState extends State<TekActionCard> {
  bool _awaitingConfirmation = false;
  VoidCallback? _unregister;

  @override
  void dispose() {
    _unregister?.call();
    super.dispose();
  }

  void _cancelSelection() {
    if (mounted && _awaitingConfirmation) {
      setState(() => _awaitingConfirmation = false);
    }
  }

  void _handleTap() {
    if (!_awaitingConfirmation) {
      setState(() => _awaitingConfirmation = true);
      _unregister = widget.selectionController.select(_cancelSelection);
      TtsService.instance.speak(widget.title); // fire-and-forget
      // Sem cancelamento automático por tempo: a seleção fica ativa até
      // o usuário confirmar (2º toque) ou selecionar outro card. Um
      // timeout curto fazia o 2º toque "perder a janela" e parecer que
      // o toque duplo tinha falhado.
    } else {
      setState(() => _awaitingConfirmation = false);
      widget.selectionController.clear();
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderOpacity = _awaitingConfirmation ? 1.0 : widget.emphasis;

    return Semantics(
      button: true,
      label: _awaitingConfirmation
          ? '${t(L.tapAgainToConfirm)} ${widget.title}'
          : '${widget.title}. ${widget.idleSubtitle}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TekColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withValues(alpha: borderOpacity * 0.8),
              width: _awaitingConfirmation ? 2.4 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: borderOpacity * 0.4),
                blurRadius: _awaitingConfirmation ? 28 : 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.6),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TekColors.titleText,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _awaitingConfirmation ? t(L.tapAgainToConfirm) : widget.idleSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: _awaitingConfirmation ? widget.color : TekColors.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coordena a seleção de toque duplo entre vários widgets: quando um
/// novo elemento é selecionado, o anterior é automaticamente cancelado.
class TapSelectionController {
  VoidCallback? _cancelCurrent;

  VoidCallback select(VoidCallback onCancel) {
    _cancelCurrent?.call();
    _cancelCurrent = onCancel;
    return () {
      if (_cancelCurrent == onCancel) _cancelCurrent = null;
    };
  }

  void clear() {
    _cancelCurrent = null;
  }
}
