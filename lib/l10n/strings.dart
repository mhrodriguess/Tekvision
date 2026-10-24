import '../state/app_preferences.dart';

/// Chaves de todos os textos traduzíveis do app.
///
/// Em vez de strings soltas espalhadas pelas telas, cada texto tem uma
/// chave aqui. Isso permite adicionar novos idiomas no futuro só
/// preenchendo mais uma coluna na tabela `_table`, sem tocar nas telas.
enum L {
  // Tela principal
  startSystem,
  startSystemHint,
  stopSystem,
  stopSystemHint,
  settings,
  settingsHint,
  help,
  helpHint,
  systemActive,
  systemStartedMsg,
  systemStoppedMsg,
  confirmStart,
  confirmStop,
  confirmOpenSettings,
  confirmOpenHelp,
  settingsOpenedMsg,
  helpOpenedMsg,

  // Navegação / voltar (compartilhado entre telas)
  back,
  backConfirmHint,
  backSelectPrompt,
  goingBackMsg,

  // Configurações
  settingsTitle,
  sectionVoiceAudio,
  sectionDisplay,
  sectionGeneral,
  voiceSpeed,
  speedSlow,
  speedNormal,
  speedFast,
  decrease,
  increase,
  decreaseConfirmedMsg,
  increaseConfirmedMsg,
  minSpeedReached,
  maxSpeedReached,
  highContrast,
  highContrastDesc,
  active,
  inactive,
  tapToConfirm,
  tapAgainToConfirm,
  tapAgainToListen,
  hcActivatePrompt,
  hcDeactivatePrompt,
  hcActivatedMsg,
  hcDeactivatedMsg,
  language,
  select,
  selectLanguagePrompt,
  footerVersion,

  // Seleção de idioma
  selectLanguageTitle,
  openingLanguageMsg,
  portugueseName,
  portugueseNative,
  englishName,
  englishNative,
  englishShortNative,
  languageChangedMsg,

  // Ajuda
  listenHint,
  welcomeTitle,
  welcomeBody,
  doubleTapTitle,
  firstTapTitle,
  firstTapDesc,
  secondTapTitle,
  secondTapDesc,
  cancelTapTitle,
  cancelTapDesc,
  mainFunctionsTitle,
  fnStartTitle,
  fnStartDesc,
  fnSettingsTitle,
  fnSettingsDesc,
  fnHelpTitle,
  fnHelpDesc,
  footerHelp,

  // Percepção / YOLO (Etapa 7)
  detectionAlert,
  posExtremeLeft,
  posLeft,
  posCenter,
  posRight,
  posExtremeRight,
  posAbove,
  posBelow,

  // Área de visualização da câmera (Home)
  cameraPreviewOff,
  cameraPreviewWaiting,
  espDisconnected,
  espConnecting,
  espConnected,
  espError,
}

const Map<L, Map<String, String>> _table = {
  L.startSystem: {'pt-BR': 'INICIAR SISTEMA', 'en-US': 'START SYSTEM'},
  L.startSystemHint: {
    'pt-BR': 'Toque duas vezes para iniciar',
    'en-US': 'Double tap to start',
  },
  L.stopSystem: {'pt-BR': 'PARAR SISTEMA', 'en-US': 'STOP SYSTEM'},
  L.stopSystemHint: {
    'pt-BR': 'Toque duas vezes para parar',
    'en-US': 'Double tap to stop',
  },
  L.settings: {'pt-BR': 'CONFIGURAÇÕES', 'en-US': 'SETTINGS'},
  L.settingsHint: {
    'pt-BR': 'Toque duas vezes para abrir',
    'en-US': 'Double tap to open',
  },
  L.help: {'pt-BR': 'AJUDA', 'en-US': 'HELP'},
  L.helpHint: {
    'pt-BR': 'Toque duas vezes para abrir',
    'en-US': 'Double tap to open',
  },
  L.systemActive: {'pt-BR': 'Sistema ativo', 'en-US': 'System active'},
  L.systemStartedMsg: {'pt-BR': 'Sistema iniciado.', 'en-US': 'System started.'},
  L.systemStoppedMsg: {'pt-BR': 'Sistema parado.', 'en-US': 'System stopped.'},
  L.confirmStart: {
    'pt-BR': 'Toque novamente para iniciar o sistema',
    'en-US': 'Tap again to start the system',
  },
  L.confirmStop: {
    'pt-BR': 'Toque novamente para parar o sistema',
    'en-US': 'Tap again to stop the system',
  },
  L.confirmOpenSettings: {
    'pt-BR': 'Toque novamente para abrir configurações',
    'en-US': 'Tap again to open settings',
  },
  L.confirmOpenHelp: {
    'pt-BR': 'Toque novamente para abrir a ajuda',
    'en-US': 'Tap again to open help',
  },
  L.settingsOpenedMsg: {
    'pt-BR': 'Configurações abertas.',
    'en-US': 'Settings opened.',
  },
  L.helpOpenedMsg: {
    'pt-BR': 'Ajuda aberta.',
    'en-US': 'Help opened.',
  },

  L.back: {'pt-BR': 'Voltar', 'en-US': 'Back'},
  L.backConfirmHint: {
    'pt-BR': 'toque novamente para voltar',
    'en-US': 'tap again to go back',
  },
  L.backSelectPrompt: {
    'pt-BR': 'Voltar. Toque novamente para confirmar.',
    'en-US': 'Back. Tap again to confirm.',
  },
  L.goingBackMsg: {'pt-BR': 'Voltando.', 'en-US': 'Going back.'},

  L.settingsTitle: {'pt-BR': 'Configurações', 'en-US': 'Settings'},
  L.sectionVoiceAudio: {'pt-BR': 'Voz e áudio', 'en-US': 'Voice & Audio'},
  L.sectionDisplay: {'pt-BR': 'Exibição', 'en-US': 'Display'},
  L.sectionGeneral: {'pt-BR': 'Geral', 'en-US': 'General'},
  L.voiceSpeed: {'pt-BR': 'Velocidade da voz', 'en-US': 'Voice Speed'},
  L.speedSlow: {'pt-BR': 'Lenta', 'en-US': 'Slow'},
  L.speedNormal: {'pt-BR': 'Normal', 'en-US': 'Normal'},
  L.speedFast: {'pt-BR': 'Rápida', 'en-US': 'Fast'},
  L.decrease: {'pt-BR': 'Diminuir', 'en-US': 'Decrease'},
  L.increase: {'pt-BR': 'Aumentar', 'en-US': 'Increase'},
  L.decreaseConfirmedMsg: {
    'pt-BR': 'Velocidade {level}.',
    'en-US': '{level} speed.',
  },
  L.increaseConfirmedMsg: {
    'pt-BR': 'Velocidade {level}.',
    'en-US': '{level} speed.',
  },
  L.minSpeedReached: {
    'pt-BR': 'Velocidade mínima.',
    'en-US': 'Minimum speed.',
  },
  L.maxSpeedReached: {
    'pt-BR': 'Velocidade máxima.',
    'en-US': 'Maximum speed.',
  },
  L.highContrast: {'pt-BR': 'Alto contraste', 'en-US': 'High Contrast'},
  L.highContrastDesc: {
    'pt-BR': 'Aumentar contraste das cores',
    'en-US': 'Increase color contrast',
  },
  L.active: {'pt-BR': 'Ativo', 'en-US': 'Active'},
  L.inactive: {'pt-BR': 'Inativo', 'en-US': 'Inactive'},
  L.tapToConfirm: {'pt-BR': 'toque p/ confirmar', 'en-US': 'tap to confirm'},
  L.tapAgainToConfirm: {
    'pt-BR': 'Toque novamente para confirmar.',
    'en-US': 'Tap again to confirm.',
  },
  L.tapAgainToListen: {
    'pt-BR': 'toque novamente para ouvir',
    'en-US': 'tap again to listen',
  },
  L.hcActivatePrompt: {
    'pt-BR': 'Alto contraste: ativar. Toque novamente para confirmar.',
    'en-US': 'High contrast: turn on. Tap again to confirm.',
  },
  L.hcDeactivatePrompt: {
    'pt-BR': 'Alto contraste: desativar. Toque novamente para confirmar.',
    'en-US': 'High contrast: turn off. Tap again to confirm.',
  },
  L.hcActivatedMsg: {
    'pt-BR': 'Alto contraste ativado.',
    'en-US': 'High contrast turned on.',
  },
  L.hcDeactivatedMsg: {
    'pt-BR': 'Alto contraste desativado.',
    'en-US': 'High contrast turned off.',
  },
  L.language: {'pt-BR': 'Idioma', 'en-US': 'Language'},
  L.select: {'pt-BR': 'Selecionar', 'en-US': 'Select'},
  L.selectLanguagePrompt: {
    'pt-BR': 'Selecionar idioma. Toque novamente para confirmar.',
    'en-US': 'Select language. Tap again to confirm.',
  },
  L.footerVersion: {'pt-BR': 'TÉKVISION v1.0.0', 'en-US': 'TÉKVISION v1.0.0'},

  L.selectLanguageTitle: {
    'pt-BR': 'Selecionar Idioma',
    'en-US': 'Select Language',
  },
  L.openingLanguageMsg: {
    'pt-BR': 'Abrindo seleção de idioma.',
    'en-US': 'Opening language selection.',
  },
  L.portugueseName: {'pt-BR': 'PORTUGUÊS', 'en-US': 'PORTUGUÊS'},
  L.portugueseNative: {
    'pt-BR': 'Português (Brasil)',
    'en-US': 'Português (Brasil)',
  },
  L.englishName: {'pt-BR': 'ENGLISH', 'en-US': 'ENGLISH'},
  L.englishNative: {
    'pt-BR': 'English (United States)',
    'en-US': 'English (United States)',
  },
  L.englishShortNative: {'pt-BR': 'English (US)', 'en-US': 'English (US)'},
  L.languageChangedMsg: {
    'pt-BR': 'Idioma alterado para {language}.',
    'en-US': 'Language changed to {language}.',
  },

  L.listenHint: {'pt-BR': '2x para ouvir', 'en-US': '2x to listen'},
  L.welcomeTitle: {
    'pt-BR': 'Bem-vindo ao TÉKVISION',
    'en-US': 'Welcome to TÉKVISION',
  },
  L.welcomeBody: {
    'pt-BR':
        'O TÉKVISION é um sistema de acessibilidade para pessoas com deficiência visual. Todos os botões usam o sistema de toque duplo para maior segurança.',
    'en-US':
        'TÉKVISION is an accessibility system for people with visual impairment. All buttons use the double tap system for greater safety.',
  },
  L.doubleTapTitle: {
    'pt-BR': 'Sistema de Toque Duplo',
    'en-US': 'Double Tap System',
  },
  L.firstTapTitle: {'pt-BR': 'Primeiro toque', 'en-US': 'First tap'},
  L.firstTapDesc: {
    'pt-BR': 'Pré-seleciona e lê a função em voz alta.',
    'en-US': 'Pre-selects and reads the function aloud.',
  },
  L.secondTapTitle: {'pt-BR': 'Segundo toque', 'en-US': 'Second tap'},
  L.secondTapDesc: {
    'pt-BR': 'Confirma e executa a ação.',
    'en-US': 'Confirms and executes the action.',
  },
  L.cancelTapTitle: {'pt-BR': 'Cancelar', 'en-US': 'Cancel'},
  L.cancelTapDesc: {
    'pt-BR': 'Toque em outro botão para cancelar.',
    'en-US': 'Tap another button to cancel.',
  },
  L.mainFunctionsTitle: {
    'pt-BR': 'Funções Principais',
    'en-US': 'Main Functions',
  },
  L.fnStartTitle: {
    'pt-BR': 'Iniciar / Parar Sistema',
    'en-US': 'Start / Stop System',
  },
  L.fnStartDesc: {
    'pt-BR': 'Ativa e desativa o sistema de assistência visual.',
    'en-US': 'Turns the visual assistance system on and off.',
  },
  L.fnSettingsTitle: {'pt-BR': 'Configurações', 'en-US': 'Settings'},
  L.fnSettingsDesc: {
    'pt-BR': 'Ajuste voz, contraste e idioma.',
    'en-US': 'Adjust voice, contrast and language.',
  },
  L.fnHelpTitle: {'pt-BR': 'Ajuda', 'en-US': 'Help'},
  L.fnHelpDesc: {
    'pt-BR': 'Esta tela com instruções de uso.',
    'en-US': 'This screen with usage instructions.',
  },
  L.footerHelp: {
    'pt-BR': 'TÉKVISION v1.0.0 — Acessibilidade para todos',
    'en-US': 'TÉKVISION v1.0.0 — Accessibility for all',
  },

  // Percepção / YOLO (Etapa 7)
  L.detectionAlert: {'pt-BR': '{object} {position}.', 'en-US': '{object} {position}.'},
  L.posExtremeLeft: {'pt-BR': 'à esquerda extrema', 'en-US': 'on the far left'},
  L.posLeft: {'pt-BR': 'à esquerda', 'en-US': 'on the left'},
  L.posCenter: {'pt-BR': 'no centro', 'en-US': 'in the center'},
  L.posRight: {'pt-BR': 'à direita', 'en-US': 'on the right'},
  L.posExtremeRight: {'pt-BR': 'à direita extrema', 'en-US': 'on the far right'},
  L.posAbove: {'pt-BR': 'acima', 'en-US': 'above'},
  L.posBelow: {'pt-BR': 'abaixo', 'en-US': 'below'},

  // Área de visualização da câmera (Home)
  L.cameraPreviewOff: {'pt-BR': 'Câmera desligada', 'en-US': 'Camera off'},
  L.cameraPreviewWaiting: {
    'pt-BR': 'Aguardando imagem da câmera...',
    'en-US': 'Waiting for camera image...',
  },
  L.espDisconnected: {
    'pt-BR': 'ESP32-CAM: desconectada',
    'en-US': 'ESP32-CAM: disconnected',
  },
  L.espConnecting: {
    'pt-BR': 'ESP32-CAM: conectando...',
    'en-US': 'ESP32-CAM: connecting...',
  },
  L.espConnected: {
    'pt-BR': 'ESP32-CAM: recebendo frames',
    'en-US': 'ESP32-CAM: receiving frames',
  },
  L.espError: {
    'pt-BR': 'ESP32-CAM: erro ao buscar frame',
    'en-US': 'ESP32-CAM: error fetching frame',
  },
};

/// Retorna o texto de [key] no idioma atualmente selecionado.
String t(L key) {
  final code = AppPreferences.instance.localeCode.value;
  return _table[key]?[code] ?? _table[key]?['pt-BR'] ?? key.toString();
}

/// Retorna o texto de [key] em um idioma específico (usado para o preview
/// falado na tela de seleção de idioma, que soa no idioma de destino
/// mesmo antes de confirmar a troca).
String tFor(L key, String code) {
  return _table[key]?[code] ?? _table[key]?['pt-BR'] ?? key.toString();
}

/// Substitui `{placeholder}` em um texto já resolvido por [value].
String fill(String text, String placeholder, String value) {
  return text.replaceAll('{$placeholder}', value);
}
