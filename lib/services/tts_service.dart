import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../state/app_preferences.dart';

/// Serviço central de retorno por voz (TTS).
///
/// Toda fala passa por aqui, e por padrão usa sempre o idioma atual do
/// app (`AppPreferences.instance.localeCode`). Isso evita que alguma
/// tela precise lembrar de trocar o idioma do TTS manualmente.
class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  /// Última mensagem falada, exposta para a barra de legenda visual.
  final ValueNotifier<String> lastMessage = ValueNotifier<String>('');

  Future<void> init({double rate = 0.5}) async {
    if (_initialized) return;
    await _tts.setLanguage(AppPreferences.instance.localeCode.value);
    await _tts.setSpeechRate(rate);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  /// Fala [message] no idioma atual do app, ou em [overrideLocale] se
  /// fornecido (usado apenas para o preview na tela de seleção de
  /// idioma, que soa no idioma de destino antes de confirmar a troca).
  Future<void> speak(String message, {String? overrideLocale}) async {
    if (!_initialized) {
      await init();
    }
    final locale = overrideLocale ?? AppPreferences.instance.localeCode.value;
    await _tts.setLanguage(locale);
    lastMessage.value = message;
    await _tts.stop(); // evita fila de mensagens acumuladas
    await _tts.speak(message);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }
}
