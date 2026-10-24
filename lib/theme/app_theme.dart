import 'package:flutter/material.dart';
import '../state/app_preferences.dart';

/// Paleta do TekVision, com duas variantes: normal e alto contraste
/// (seção 5 e 6 da especificação). Todos os getters leem o estado global
/// em `AppPreferences.instance.highContrast` — como `main.dart` reconstrói
/// a árvore inteira quando esse valor muda, qualquer widget que leia
/// `TekColors.xxx` durante o `build()` já pega a paleta certa.
class TekColors {
  TekColors._();

  static bool get _hc => AppPreferences.instance.highContrast.value;

  static Color get bgTop => _hc ? const Color(0xFF000000) : const Color(0xFF07070A);
  static Color get bgBottom => _hc ? const Color(0xFF000000) : const Color(0xFF0C0C11);

  static Color get cardBg => _hc ? const Color(0xFF111111) : const Color(0xFF121217);
  static Color get cardBorderIdle =>
      _hc ? const Color(0x33FFFFFF) : const Color(0x14FFFFFF);

  static Color get titleText => _hc ? const Color(0xFFFFFFFF) : const Color(0xFFF5F5F7);
  static Color get subtitleText =>
      _hc ? const Color(0xFFE0E0E0) : const Color(0xFF9A9AA5);

  // Cores de ação. No modo normal são um pouco mais suaves; no alto
  // contraste seguem exatamente a paleta de referência da especificação.
  static Color get iniciar => _hc ? const Color(0xFF0066FF) : const Color(0xFF3B82F6);
  static Color get parar => _hc ? const Color(0xFFFF3B30) : const Color(0xFFE5484D);
  static Color get configuracoes => _hc ? const Color(0xFF00C853) : const Color(0xFF2FA85B);
  static Color get ajuda => _hc ? const Color(0xFFFFD600) : const Color(0xFFD9A441);

  /// Cor universal de "seleção" (1º toque, aguardando confirmação) usada
  /// em itens que não têm uma cor própria de ação (ex: itens de
  /// Configurações). Nos cards da tela principal, a própria cor do card
  /// já serve como indicador de seleção.
  static Color get selecting => iniciar;

  static Color get attention => const Color(0xFFFF8A00);
}

ThemeData buildTekVisionTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: TekColors.bgBottom,
    colorScheme: base.colorScheme.copyWith(
      primary: TekColors.iniciar,
      surface: TekColors.cardBg,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: TekColors.titleText,
      displayColor: TekColors.titleText,
    ),
  );
}
