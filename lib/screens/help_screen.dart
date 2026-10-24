import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../state/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/caption_bar.dart';
import '../widgets/tek_action_card.dart';
import '../widgets/tek_back_button.dart';

/// Tela de Ajuda: tutorial de áudio fixo em 3 partes (spec seção 9).
/// Cada card tem toque duplo: 1º toque seleciona/anuncia o título, 2º
/// toque reproduz a explicação completa em áudio.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with PrefsReactive {
  final TapSelectionController _selection = TapSelectionController();

  @override
  void initState() {
    super.initState();
    TtsService.instance.speak(t(L.helpOpenedMsg)); // fire-and-forget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TekColors.bgBottom,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TekScreenHeader(title: t(L.help), selectionController: _selection),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x22FFFFFF)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HelpCard(
                    icon: Icons.mic_rounded,
                    color: TekColors.iniciar,
                    title: t(L.welcomeTitle),
                    selectionController: _selection,
                    spokenText: t(L.welcomeBody),
                    child: Text(
                      t(L.welcomeBody),
                      style: TextStyle(color: TekColors.subtitleText, fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HelpCard(
                    icon: Icons.volume_up_rounded,
                    color: TekColors.configuracoes,
                    title: t(L.doubleTapTitle),
                    selectionController: _selection,
                    spokenText: '${t(L.firstTapTitle)}: ${t(L.firstTapDesc)} '
                        '${t(L.secondTapTitle)}: ${t(L.secondTapDesc)} '
                        '${t(L.cancelTapTitle)}: ${t(L.cancelTapDesc)}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NumberedItem(number: '1', color: TekColors.iniciar, title: t(L.firstTapTitle), desc: t(L.firstTapDesc)),
                        const SizedBox(height: 10),
                        _NumberedItem(number: '2', color: TekColors.configuracoes, title: t(L.secondTapTitle), desc: t(L.secondTapDesc)),
                        const SizedBox(height: 10),
                        _NumberedItem(icon: Icons.close_rounded, color: TekColors.ajuda, title: t(L.cancelTapTitle), desc: t(L.cancelTapDesc)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HelpCard(
                    icon: Icons.help_outline_rounded,
                    color: TekColors.ajuda,
                    title: t(L.mainFunctionsTitle),
                    selectionController: _selection,
                    spokenText: '${t(L.fnStartTitle)}: ${t(L.fnStartDesc)} '
                        '${t(L.fnSettingsTitle)}: ${t(L.fnSettingsDesc)} '
                        '${t(L.fnHelpTitle)}: ${t(L.fnHelpDesc)}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NumberedItem(icon: Icons.play_arrow_rounded, color: TekColors.iniciar, title: t(L.fnStartTitle), desc: t(L.fnStartDesc)),
                        const SizedBox(height: 10),
                        _NumberedItem(icon: Icons.settings_rounded, color: TekColors.configuracoes, title: t(L.fnSettingsTitle), desc: t(L.fnSettingsDesc)),
                        const SizedBox(height: 10),
                        _NumberedItem(icon: Icons.help_outline_rounded, color: TekColors.ajuda, title: t(L.fnHelpTitle), desc: t(L.fnHelpDesc)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      t(L.footerHelp),
                      style: TextStyle(fontSize: 11, color: TekColors.subtitleText.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CaptionBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de ajuda com toque duplo: 1º toque anuncia o título, 2º toque lê
/// a explicação completa em voz alta ("2x para ouvir").
class _HelpCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String spokenText;
  final Widget child;
  final TapSelectionController selectionController;

  const _HelpCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.spokenText,
    required this.child,
    required this.selectionController,
  });

  @override
  State<_HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<_HelpCard> {
  bool _selected = false;
  VoidCallback? _unregister;

  @override
  void dispose() {
    _unregister?.call();
    super.dispose();
  }

  void _cancel() {
    if (mounted && _selected) setState(() => _selected = false);
  }

  void _handleTap() {
    if (!_selected) {
      setState(() => _selected = true);
      _unregister = widget.selectionController.select(_cancel);
      TtsService.instance.speak('${widget.title}, ${t(L.tapAgainToListen)}'); // fire-and-forget
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _selected = false);
      widget.selectionController.clear();
      TtsService.instance.speak(widget.spokenText); // fire-and-forget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.title}. ${t(L.listenHint)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TekColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _selected ? widget.color : widget.color.withValues(alpha: 0.3),
              width: _selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: TekColors.titleText,
                      ),
                    ),
                  ),
                  Text(
                    t(L.listenHint),
                    style: TextStyle(fontSize: 11, color: TekColors.ajuda),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  final String? number;
  final IconData? icon;
  final Color color;
  final String title;
  final String desc;

  const _NumberedItem({
    this.number,
    this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          alignment: Alignment.center,
          child: number != null
              ? Text(number!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))
              : Icon(icon, size: 13, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TekColors.titleText)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 12, color: TekColors.subtitleText)),
            ],
          ),
        ),
      ],
    );
  }
}
