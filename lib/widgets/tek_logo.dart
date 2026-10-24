import 'package:flutter/material.dart';

/// Logo oficial do TekVision.
///
/// Usa o arquivo de imagem fornecido (`assets/images/tekvision_logo.png`),
/// que já contém o emblema, o nome "TÉKVISION" e a fileira em Braille
/// desenhados como uma única peça de arte.
///
/// Pré-requisito no pubspec.yaml:
/// ```yaml
/// flutter:
///   assets:
///     - assets/images/tekvision_logo.png
/// ```
class TekLogo extends StatelessWidget {
  final double width;

  const TekLogo({super.key, this.width = 260});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/tekvision_logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
