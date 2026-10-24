import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/tts_service.dart';
import '../state/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/caption_bar.dart';
import '../widgets/settings_items.dart';
import '../widgets/tek_action_card.dart';
import '../widgets/tek_back_button.dart';
import 'language_screen.dart';

/// Tela de Configurações, com as 3 seções exatas do protótipo validado:
/// Voz e áudio (velocidade da voz), Exibição (alto contraste) e Geral
/// (idioma). Nada de vibração/ESP32 aqui — isso pertence ao sistema
/// físico independente (spec seção 11).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const _speedLabelKeys = [L.speedSlow, L.speedNormal, L.speedFast];
const _speedRates = [0.35, 0.5, 0.7];

class _SettingsScreenState extends State<SettingsScreen> with PrefsReactive {
  final TapSelectionController _selection = TapSelectionController();

  @override
  void initState() {
    super.initState();
    TtsService.instance.speak(t(L.settingsOpenedMsg)); // fire-and-forget
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final speedIndex = prefs.speedIndex.value;
    final highContrast = prefs.highContrast.value;
    final languageLabel =
        prefs.localeCode.value == 'pt-BR' ? t(L.portugueseNative) : t(L.englishShortNative);

    return Scaffold(
      backgroundColor: TekColors.bgBottom,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TekScreenHeader(title: t(L.settingsTitle), selectionController: _selection),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x22FFFFFF)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                children: [
                  SettingsSection(
                    title: t(L.sectionVoiceAudio),
                    children: [
                      VoiceSpeedControl(
                        title: t(L.voiceSpeed),
                        levelIndex: speedIndex,
                        totalLevels: _speedLabelKeys.length,
                        levelLabel: t(_speedLabelKeys[speedIndex]),
                        decreaseLabel: t(L.decrease),
                        increaseLabel: t(L.increase),
                        canDecrease: speedIndex > 0,
                        canIncrease: speedIndex < _speedLabelKeys.length - 1,
                        selectionController: _selection,
                        onDecrease: () {
                          setState(() => prefs.speedIndex.value--);
                          TtsService.instance.setSpeechRate(_speedRates[prefs.speedIndex.value]);
                          TtsService.instance.speak(fill(t(L.decreaseConfirmedMsg), 'level',
                              t(_speedLabelKeys[prefs.speedIndex.value])));
                        },
                        onIncrease: () {
                          setState(() => prefs.speedIndex.value++);
                          TtsService.instance.setSpeechRate(_speedRates[prefs.speedIndex.value]);
                          TtsService.instance.speak(fill(t(L.increaseConfirmedMsg), 'level',
                              t(_speedLabelKeys[prefs.speedIndex.value])));
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: t(L.sectionDisplay),
                    children: [
                      SettingsToggleRow(
                        title: t(L.highContrast),
                        subtitle: t(L.highContrastDesc),
                        value: highContrast,
                        selectionController: _selection,
                        onConfirmedChange: (v) {
                          setState(() => prefs.highContrast.value = v);
                          TtsService.instance.speak(v ? t(L.hcActivatedMsg) : t(L.hcDeactivatedMsg));
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: t(L.sectionGeneral),
                    children: [
                      SettingsChoiceRow(
                        title: t(L.language),
                        valueLabel: languageLabel,
                        buttonLabel: t(L.select),
                        selectionController: _selection,
                        onConfirmed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LanguageScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        t(L.footerVersion),
                        style: TextStyle(fontSize: 11, color: TekColors.subtitleText.withValues(alpha: 0.5)),
                      ),
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
