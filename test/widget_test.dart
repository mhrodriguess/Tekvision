// Teste de smoke do TekVision.
//
// O teste padrão gerado pelo `flutter create` (contador "0"/"1") não se
// aplica a este app — o TekVision não tem contador, e o widget raiz se
// chama `TekVisionApp` (não `MyApp`), por isso o teste original não
// compilava. Este teste só garante que o app sobe e a tela principal
// mostra o botão de iniciar o sistema.

import 'package:flutter_test/flutter_test.dart';

import 'package:tekvision/main.dart';
import 'package:tekvision/l10n/strings.dart';

void main() {
  testWidgets('App inicializa e mostra a tela principal', (WidgetTester tester) async {
    await tester.pumpWidget(const TekVisionApp());

    // A tela principal deve mostrar o botão de iniciar o sistema.
    expect(find.text(t(L.startSystem)), findsOneWidget);
  });
}
