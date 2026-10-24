import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'state/app_preferences.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TekVisionApp());
}

class TekVisionApp extends StatelessWidget {
  const TekVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reconstrói a árvore inteira quando idioma, alto contraste ou
    // velocidade de voz mudam, para que qualquer widget que leia
    // TekColors.* ou t(L.*) durante o build já pegue o valor atual.
    return AnimatedBuilder(
      animation: AppPreferences.instance.listenable,
      builder: (context, _) {
        return MaterialApp(
          title: 'TekVision',
          debugShowCheckedModeBanner: false,
          theme: buildTekVisionTheme(),
          home: const HomeScreen(),
        );
      },
    );
  }
}
