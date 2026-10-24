import 'package:flutter/material.dart';
/// Estado global de preferências do app: idioma e alto contraste.
///
/// Fica fora de qualquer tela porque afeta o app inteiro (spec seção 5:
/// "quando ativado, todo o aplicativo deve mudar para o tema de alto
/// contraste, e não somente a tela de configurações").
///
/// `main.dart` escuta essas notifiers e reconstrói toda a árvore de
/// widgets quando qualquer uma muda, então qualquer widget pode apenas
/// ler o valor atual em `build()` sem precisar de listeners próprios.
class AppPreferences {
  AppPreferences._internal();
  static final AppPreferences instance = AppPreferences._internal();

  /// 'pt-BR' ou 'en-US'.
  final ValueNotifier<String> localeCode = ValueNotifier<String>('pt-BR');

  final ValueNotifier<bool> highContrast = ValueNotifier<bool>(false);

  /// Índice de velocidade de voz: 0 = lenta, 1 = normal, 2 = rápida.
  final ValueNotifier<int> speedIndex = ValueNotifier<int>(1);

  /// Notifica todos os três de uma vez (usado pelo widget raiz do app e
  /// por cada tela via `PrefsReactive`). É calculado uma única vez e
  /// reutilizado sempre — se fosse recriado a cada acesso, um
  /// `addListener`/`removeListener` feito em instâncias diferentes do
  /// merge geraria vazamento de listener (e, por consequência, chamadas
  /// de `setState` em telas já destruídas).
  late final Listenable listenable = Listenable.merge([
    localeCode,
    highContrast,
    speedIndex,
  ]);
}

/// Mixin para qualquer `State` de tela: reconstrói automaticamente quando
/// idioma, alto contraste ou velocidade de voz mudam — mesmo que a tela
/// já estivesse empilhada na navegação antes da mudança acontecer.
mixin PrefsReactive<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    AppPreferences.instance.listenable.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    AppPreferences.instance.listenable.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }
}
