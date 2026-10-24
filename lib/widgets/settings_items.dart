import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'tek_action_card.dart';

/// Card com cabeçalho de seção (ex: "VOZ E ÁUDIO"), agrupando itens.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: TekColors.subtitleText,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Item de configuração do tipo liga/desliga (ex: "Alto contraste"), com
/// toque duplo. O CARTÃO INTEIRO é a área de toque (não só o texto).
/// Fala apenas o nome no 1º toque — nada de "toque novamente" na voz,
/// isso fica só no texto visual.
class SettingsToggleRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onConfirmedChange;
  final TapSelectionController selectionController;

  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onConfirmedChange,
    required this.selectionController,
  });

  @override
  State<SettingsToggleRow> createState() => _SettingsToggleRowState();
}

class _SettingsToggleRowState extends State<SettingsToggleRow> {
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
    final nextValue = !widget.value;
    if (!_awaitingConfirmation) {
      setState(() => _awaitingConfirmation = true);
      _unregister = widget.selectionController.select(_cancel);
      TtsService.instance.speak(widget.title); // fire-and-forget
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingConfirmation = false);
      widget.selectionController.clear();
      widget.onConfirmedChange(nextValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _awaitingConfirmation
        ? TekColors.selecting
        : (widget.value ? TekColors.configuracoes : TekColors.cardBorderIdle);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: '${widget.title}, ${widget.value ? "ativo" : "inativo"}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _handleTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: TekColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: _awaitingConfirmation || widget.value ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: TekColors.titleText)),
                        const SizedBox(height: 4),
                        Text(
                          _awaitingConfirmation ? t(L.tapToConfirm) : widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: _awaitingConfirmation
                                ? TekColors.selecting
                                : TekColors.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.value ? t(L.active) : t(L.inactive),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: widget.value ? TekColors.configuracoes : TekColors.subtitleText,
                    ),
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

/// Item de configuração do tipo "escolha com botão" (ex: "Idioma"), com
/// toque duplo. O CARTÃO INTEIRO é clicável, não só o rótulo do botão.
class SettingsChoiceRow extends StatefulWidget {
  final String title;
  final String valueLabel;
  final String buttonLabel;
  final VoidCallback onConfirmed;
  final TapSelectionController selectionController;

  const SettingsChoiceRow({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.buttonLabel,
    required this.onConfirmed,
    required this.selectionController,
  });

  @override
  State<SettingsChoiceRow> createState() => _SettingsChoiceRowState();
}

class _SettingsChoiceRowState extends State<SettingsChoiceRow> {
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
      TtsService.instance.speak(widget.title); // fire-and-forget
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingConfirmation = false);
      widget.selectionController.clear();
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _awaitingConfirmation ? TekColors.selecting : TekColors.cardBorderIdle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: TekColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: _awaitingConfirmation ? 1.8 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16, color: TekColors.titleText)),
                      const SizedBox(height: 4),
                      Text(widget.valueLabel,
                          style: TextStyle(fontSize: 13, color: TekColors.subtitleText)),
                    ],
                  ),
                ),
                Text(
                  _awaitingConfirmation ? t(L.tapToConfirm) : widget.buttonLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _awaitingConfirmation ? TekColors.selecting : TekColors.configuracoes,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Controle de velocidade da voz: rótulo do nível atual, indicador em
/// pontos e botões "Diminuir" / "Aumentar", cada um com toque duplo.
class VoiceSpeedControl extends StatefulWidget {
  final String title;
  final int levelIndex; // 0..totalLevels-1
  final int totalLevels;
  final String levelLabel;
  final String decreaseLabel;
  final String increaseLabel;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final TapSelectionController selectionController;

  const VoiceSpeedControl({
    super.key,
    required this.title,
    required this.levelIndex,
    required this.totalLevels,
    required this.levelLabel,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
    required this.selectionController,
  });

  @override
  State<VoiceSpeedControl> createState() => _VoiceSpeedControlState();
}

class _VoiceSpeedControlState extends State<VoiceSpeedControl> {
  bool _awaitingDecrease = false;
  bool _awaitingIncrease = false;
  VoidCallback? _unregisterDecrease;
  VoidCallback? _unregisterIncrease;

  @override
  void dispose() {
    _unregisterDecrease?.call();
    _unregisterIncrease?.call();
    super.dispose();
  }

  void _cancelDecrease() {
    if (mounted && _awaitingDecrease) setState(() => _awaitingDecrease = false);
  }

  void _cancelIncrease() {
    if (mounted && _awaitingIncrease) setState(() => _awaitingIncrease = false);
  }

  void _handleDecrease() {
    if (!widget.canDecrease) return;
    if (!_awaitingDecrease) {
      setState(() => _awaitingDecrease = true);
      _unregisterDecrease = widget.selectionController.select(_cancelDecrease);
      TtsService.instance.speak(widget.decreaseLabel); // fire-and-forget
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingDecrease = false);
      widget.selectionController.clear();
      widget.onDecrease();
    }
  }

  void _handleIncrease() {
    if (!widget.canIncrease) return;
    if (!_awaitingIncrease) {
      setState(() => _awaitingIncrease = true);
      _unregisterIncrease = widget.selectionController.select(_cancelIncrease);
      TtsService.instance.speak(widget.increaseLabel); // fire-and-forget
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingIncrease = false);
      widget.selectionController.clear();
      widget.onIncrease();
    }
  }

  Widget _dot(int index) {
    final active = index == widget.levelIndex;
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? TekColors.iniciar : TekColors.cardBorderIdle,
      ),
    );
  }

  Widget _speedButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required bool awaiting,
    required VoidCallback onTap,
  }) {
    final color = !enabled
        ? TekColors.subtitleText.withValues(alpha: 0.35)
        : (awaiting ? TekColors.selecting : TekColors.iniciar);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: TekColors.bgTop,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: enabled ? 0.6 : 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  awaiting ? t(L.tapToConfirm) : label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TekColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TekColors.cardBorderIdle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: TekColors.titleText)),
              Text(widget.levelLabel,
                  style: TextStyle(color: TekColors.iniciar, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.totalLevels, _dot),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _speedButton(
                label: widget.decreaseLabel,
                icon: Icons.chevron_left_rounded,
                enabled: widget.canDecrease,
                awaiting: _awaitingDecrease,
                onTap: _handleDecrease,
              ),
              const SizedBox(width: 12),
              _speedButton(
                label: widget.increaseLabel,
                icon: Icons.chevron_right_rounded,
                enabled: widget.canIncrease,
                awaiting: _awaitingIncrease,
                onTap: _handleIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
