import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../state/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/caption_bar.dart';
import '../widgets/tek_action_card.dart';
import '../widgets/tek_back_button.dart';

/// Tela "Selecionar Idioma": duas opções centralizadas (Português /
/// English). O 1º toque numa opção já faz o preview falado no idioma de
/// destino; o 2º toque confirma, troca o idioma globalmente e volta para
/// Configurações.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> with PrefsReactive {
  final TapSelectionController _selection = TapSelectionController();

  @override
  void initState() {
    super.initState();
    TtsService.instance.speak(t(L.openingLanguageMsg));
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = AppPreferences.instance.highContrast.value;

    return Scaffold(
      backgroundColor: TekColors.bgBottom,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TekScreenHeader(
                      title: t(L.selectLanguageTitle),
                      selectionController: _selection,
                    ),
                  ),
                  if (highContrast)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TekColors.configuracoes.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TekColors.configuracoes),
                      ),
                      child: Text(
                        t(L.active),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: TekColors.configuracoes,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x22FFFFFF)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LanguageOption(
                      code: 'pt-BR',
                      name: t(L.portugueseName),
                      native: t(L.portugueseNative),
                      selectionController: _selection,
                    ),
                    const SizedBox(height: 56),
                    _LanguageOption(
                      code: 'en-US',
                      name: t(L.englishName),
                      native: t(L.englishNative),
                      selectionController: _selection,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CaptionBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatefulWidget {
  final String code;
  final String name;
  final String native;
  final TapSelectionController selectionController;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.native,
    required this.selectionController,
  });

  @override
  State<_LanguageOption> createState() => _LanguageOptionState();
}

class _LanguageOptionState extends State<_LanguageOption> {
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
      // Fala só o nome, pronunciado no idioma de destino (preview) —
      // sem "toque novamente" na voz, isso fica só no texto visual.
      TtsService.instance.speak(widget.name, overrideLocale: widget.code);
      // Sem cancelamento automático por tempo — ver TekActionCard.
    } else {
      setState(() => _awaitingConfirmation = false);
      widget.selectionController.clear();
      AppPreferences.instance.localeCode.value = widget.code;
      TtsService.instance.speak(
        fill(t(L.languageChangedMsg), 'language', widget.native),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _awaitingConfirmation;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: highlighted ? TekColors.selecting.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: highlighted ? Border.all(color: TekColors.selecting, width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: highlighted ? TekColors.selecting : TekColors.subtitleText,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.public,
                  color: highlighted ? TekColors.selecting : TekColors.subtitleText,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: TekColors.titleText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _awaitingConfirmation ? tFor(L.tapToConfirm, widget.code) : widget.native,
                style: TextStyle(
                  fontSize: 14,
                  color: highlighted ? TekColors.selecting : TekColors.subtitleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
