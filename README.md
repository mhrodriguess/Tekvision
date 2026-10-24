# TekVision — Sistema Assistivo Inteligente

> Sistema assistivo em desenvolvimento que combina visão computacional, alertas por voz e um alerta tátil independente para apoiar a segurança e a autonomia de pessoas com deficiência visual.

---

## 📌 Informações Gerais

- **Nome do Projeto:** TekVision
- **Equipe:** Matheus Henrique, Lavínia Mendonça, Kauã Felipe, Davi Lopes, Rodrigo Caliari e Gabriela Avelar
- **Curso:** Técnico em Informática
- **Instituição:** FUNEC Riacho
- **Ano/Semestre:** 2026
- **Professor Orientador:** Ronaldo Brito
- **Cliente/Setor Solicitante:** Projeto acadêmico desenvolvido para a Mostra de Tecnologia da FUNEC Riacho
- **Categoria:** Tecnologia assistiva / acessibilidade

---

## 🎯 Objetivo do Projeto

Desenvolver um protótipo de tecnologia assistiva para apoiar a segurança e a autonomia de pessoas com deficiência visual durante a locomoção e a exploração de ambientes. A proposta combina sensores físicos, visão computacional executada localmente no celular e retorno por áudio, priorizando primeiro as funções essenciais de alerta e evoluindo de forma incremental.

O TekVision é um projeto em desenvolvimento. Seu desempenho e sua utilidade para situações reais precisam ser avaliados por meio de testes controlados e validação apropriada antes de qualquer uso como recurso de segurança.

---

## 👥 Público-Alvo

- Pessoas com deficiência visual que possam se beneficiar de recursos assistivos complementares.
- Profissionais, educadores e estudantes interessados em acessibilidade e tecnologia assistiva.
- Comunidade escolar e visitantes da Mostra de Tecnologia, para conhecer a proposta e a evolução do protótipo.

> O TekVision não substitui bengala, cão-guia, treinamento de orientação e mobilidade ou outros recursos de segurança. A proposta deve ser validada antes de ser utilizada em situações reais de locomoção.

---

## 🧩 Problema a Ser Resolvido

Pessoas com deficiência visual podem enfrentar dificuldades para perceber objetos e elementos do ambiente durante a locomoção. Recursos tradicionais são importantes, mas existe espaço para investigar tecnologias complementares que forneçam informações adicionais sobre objetos próximos e sua posição relativa.

O desafio é desenvolver uma solução acessível e portátil que ofereça informações úteis sem depender continuamente de conexão com a internet e sem fazer com que as funções de inteligência artificial sejam o único mecanismo de alerta.

---

## 💡 Solução Proposta

O TekVision propõe integrar dois caminhos complementares:

1. **Alerta físico de proximidade:** um sensor ultrassônico mede a proximidade de obstáculos e aciona um motor vibratório. Esse caminho deve funcionar de forma independente da câmera, da inteligência artificial e do aplicativo.
2. **Percepção visual por inteligência artificial:** uma câmera ESP32-CAM transmite imagens ao celular por Wi-Fi local. O aplicativo móvel deverá processar as imagens com um modelo YOLO executado offline, identificar objetos compatíveis com o modelo e estimar sua posição relativa no enquadramento — esquerda, centro ou direita.
3. **Retorno por voz:** o aplicativo deverá transformar as detecções em mensagens curtas por meio de síntese de voz (TTS).
4. **Evolução futura:** após a implementação e avaliação do núcleo inicial, poderão ser estudadas funções de descrição de cena e perguntas em linguagem natural sobre o ambiente, sem substituir o sistema básico de alerta.

A arquitetura prioriza o funcionamento local e reduz a dependência de internet nas funções essenciais previstas.

---

## ⚙️ Funcionalidades do Sistema

### Funcionalidades previstas para a primeira versão (MVP)

- [ ] Captura de imagens pela ESP32-CAM.
- [ ] Transmissão das imagens ao celular por Wi-Fi local.
- [ ] Recepção e processamento local das imagens no aplicativo.
- [ ] Detecção de objetos com modelo YOLO offline.
- [ ] Estimativa da posição relativa dos objetos no quadro: esquerda, centro ou direita.
- [ ] Emissão de alertas curtos por voz usando TTS.
- [ ] Medição de proximidade por sensor ultrassônico.
- [ ] Acionamento do motor vibratório de acordo com a proximidade, conforme os parâmetros definidos durante o desenvolvimento.
- [ ] Funcionamento independente do alerta tátil em relação à câmera e à IA.

> As caixas acima descrevem funcionalidades planejadas, não uma declaração de que todas já estão implementadas ou testadas. Atualize as marcações conforme o estado real do protótipo.

### Evoluções planejadas

- [ ] **V2 — Assistente visual:** descrição do ambiente quando solicitada pelo usuário, após avaliação de viabilidade e desempenho.
- [ ] **V3 — Assistente conversacional:** permitir perguntas em linguagem natural sobre o ambiente, com respostas baseadas em análise visual.
- [ ] Testes adicionais de usabilidade, desempenho, latência, autonomia e confiabilidade.

---

## 🛠️ Tecnologias e Componentes

- **Linguagem do aplicativo:** Dart.
- **Framework do aplicativo:** Flutter.
- **Visão computacional:** modelo YOLO executado localmente no celular (versão e formato final a definir/confirmar).
- **Síntese de voz:** Text-to-Speech (TTS).
- **Microcontrolador/câmera:** ESP32-CAM.
- **Sensor de proximidade:** sensor ultrassônico.
- **Alerta tátil:** motor vibratório controlado pelo microcontrolador.
- **Comunicação entre câmera e celular:** Wi-Fi local.
- **Ambiente de desenvolvimento:** Android Studio.
- **Controle de versão:** Git e GitHub.
- **Banco de dados:** não previsto para o MVP atual.

> Os modelos específicos, versões de bibliotecas, protocolo de comunicação e parâmetros de operação ainda devem ser registrados quando forem definidos e testados pela equipe.

---

## 🗂️ Estrutura do Projeto

A estrutura final depende dos arquivos efetivamente presentes no repositório. A organização esperada para o aplicativo Flutter inclui:

```text
TekVision/
├── README.md
├── pubspec.yaml
├── lib/                  # Código-fonte Dart do aplicativo
├── android/              # Configuração da plataforma Android
├── test/                 # Testes automatizados, se existentes
├── docs/                 # Documentação, diagramas e materiais do projeto
└── ...                   # Outros arquivos gerados pelo Flutter e arquivos do projeto
```

O firmware da ESP32-CAM e os arquivos de circuitos devem ser documentados em pastas próprias caso sejam adicionados ao repositório. Esta árvore é ilustrativa; mantenha-a alinhada aos arquivos reais do projeto.

---

## 🧪 Requisitos Funcionais

- **RF01 — Captura de imagens:** o sistema deverá obter imagens da ESP32-CAM.
- **RF02 — Comunicação local:** o sistema deverá permitir o envio das imagens da câmera ao aplicativo por Wi-Fi local.
- **RF03 — Detecção de objetos:** o aplicativo deverá executar localmente o modelo de visão computacional selecionado.
- **RF04 — Posição relativa:** quando houver uma detecção válida, o aplicativo deverá estimar a posição do objeto no enquadramento da câmera.
- **RF05 — Alertas por voz:** o aplicativo deverá comunicar detecções selecionadas por mensagens de áudio curtas.
- **RF06 — Medição de proximidade:** o sensor ultrassônico deverá medir a proximidade de obstáculos dentro das condições de operação definidas.
- **RF07 — Alerta vibratório:** o microcontrolador deverá acionar o motor vibratório conforme a lógica de proximidade implementada.
- **RF08 — Independência do alerta físico:** o alerta vibratório deverá operar sem depender da câmera, da IA ou do aplicativo.
- **RF09 — Evolução funcional:** as versões futuras poderão oferecer descrição de cena e perguntas sobre o ambiente, após a validação das funções prioritárias.

---

## 🚫 Requisitos Não Funcionais

- **RNF01 — Operação offline:** as funções essenciais previstas deverão operar sem internet, usando comunicação Wi-Fi local entre os componentes.
- **RNF02 — Acessibilidade:** os alertas por voz deverão ser curtos, claros e relevantes, evitando excesso de mensagens.
- **RNF03 — Segurança:** a IA deverá ser tratada como auxílio de percepção, não como detector universal de riscos.
- **RNF04 — Independência:** o alerta tátil de proximidade deverá permanecer separado do processamento de visão computacional.
- **RNF05 — Portabilidade:** a solução deverá considerar o uso conjunto de câmera, microcontrolador, sensor, motor, alimentação portátil e celular.
- **RNF06 — Privacidade:** o processamento local deverá ser priorizado para evitar o envio de imagens a serviços externos na versão inicial.
- **RNF07 — Confiabilidade a validar:** latência, falsos alertas, autonomia, precisão e usabilidade deverão ser avaliados em testes apropriados.
- **RNF08 — Limites documentados:** não se deverá prometer detecção confiável de escadas, buracos, paredes, desníveis ou faixas de pedestres sem soluções específicas e testes que sustentem essa capacidade.

---

## 📅 Cronograma do Projeto

As datas e os responsáveis por cada etapa devem ser preenchidos pela equipe conforme o planejamento real.

| Etapa | Descrição | Responsável | Data |
|---|---|---|---|
| 1 | Levantamento do problema e requisitos | Todos | 26/03/2026 |
| 2 | Planejamento da arquitetura e dos componentes | Matheus, Lavínia | 20/04/2026 |
| 3 | Desenvolvimento do aplicativo e integração dos componentes | Matheus | 30/07/2026 |
| 4 | Testes técnicos e ajustes do protótipo | Matheus | 30/09/2026 |
| 5 | Documentação e preparação para a Mostra de Tecnologia | Todos | 20/11/2026 |
| 6 | Apresentação do projeto | Todos | 28/11/2026 |

---

## 🧑‍💻 Integrantes da Equipe

As responsabilidades abaixo são sugestões de organização e precisam ser confirmadas pela equipe.

| Nome | Função/área | Responsabilidade |
|---|---|---|
| Matheus Henrique | Desenvolvimento / integração | Administrar a equipe e entregar o sistema |
| Lavínia Mendonça | Apresentação / Briefing | Apresentar o projeto e orientar a execução |
| Kauã Felipe | Brainstorming / Logística | Contribuir no processo criativo e na mão de obra |
| Davi Lopes | Brainstorming / Logística | Contribuir no processo criativo e na mão de obra |
| Rodrigo Caliari | Documentação / Design | Documentar as etapas do projeto |
| Gabriela Avelar | Documentação | A definir com a equipe |

---

## 🔐 Controle de Acesso

O protótipo atual não prevê cadastro de usuários, login ou perfis de acesso como funcionalidade do MVP. O repositório do projeto é público para fins de documentação e apresentação acadêmica; isso não significa que qualquer pessoa possa enviar alterações diretamente ao repositório original.

Não devem ser publicados no repositório senhas, tokens, chaves privadas, credenciais de serviços ou dados pessoais desnecessários.

---

## 📷 Protótipos / Telas / Diagramas

Adicionar nesta seção, quando estiverem disponíveis:

- Link para o protótipo do aplicativo no Figma.
- Capturas de tela reais do aplicativo.
- Diagrama da arquitetura eletrônica e da comunicação entre componentes.
- Fotografias do protótipo físico, com autorização das pessoas retratadas.
- Vídeo demonstrativo dos testes, quando disponível.

**Links:** a preencher pela equipe.

---

## 📦 Como Executar o Projeto

As instruções abaixo se aplicam ao aplicativo Flutter e pressupõem que o código correspondente esteja presente no repositório.

### Pré-requisitos

- Git instalado.
- Flutter instalado e configurado.
- Android Studio e ferramentas de desenvolvimento Android configuradas.
- Um dispositivo Android ou emulador compatível.
- Os componentes físicos e o firmware da ESP32-CAM serão necessários para testar a integração completa com o hardware.

### Passos

1. Clone o repositório:

   ```bash
   git clone <URL_DO_REPOSITORIO>
   ```

2. Entre na pasta do projeto:

   ```bash
   cd <PASTA_DO_PROJETO>
   ```

3. Verifique a configuração do Flutter:

   ```bash
   flutter doctor
   ```

4. Instale as dependências declaradas no projeto:

   ```bash
   flutter pub get
   ```

5. Conecte um dispositivo Android ou inicie um emulador e execute:

   ```bash
   flutter run
   ```

> Substitua `<URL_DO_REPOSITORIO>` e `<PASTA_DO_PROJETO>` pelos valores reais. Os comandos só funcionarão se a estrutura Flutter estiver completa e configurada. A integração com a ESP32-CAM e os sensores também depende do firmware, das conexões físicas e da implementação correspondente.

---

## 🧭 Limitações e Segurança

- A posição esquerda/centro/direita é estimada a partir da imagem e não representa uma medição confiável de distância.
- Uma detecção YOLO não garante que todos os obstáculos ou riscos sejam reconhecidos.
- Escadas, buracos, desníveis, paredes e sinalização viária podem exigir modelos, sensores ou métodos específicos e validação própria.
- O alerta ultrassônico depende da instalação, do alcance e das condições de funcionamento do sensor.
- O protótipo não deve ser considerado um dispositivo médico certificado nem um substituto para recursos tradicionais de orientação e mobilidade.
- Qualquer alegação de segurança exige testes representativos, avaliação de falhas e validação adequada antes de uso real.

---

## 🔜 Próximas Etapas

1. Consolidar o funcionamento do MVP de alerta tátil e visão computacional.
2. Definir e documentar o modelo YOLO, o formato de execução e as classes de objetos utilizadas.
3. Definir o protocolo de comunicação, resolução das imagens, latência e tratamento de falhas de conexão.
4. Ajustar e avaliar os padrões de vibração para as faixas de proximidade definidas.
5. Realizar testes documentados de desempenho e usabilidade em condições controladas.
6. Avaliar, em etapas posteriores, a viabilidade de descrição de cena e interação por perguntas.
7. Atualizar esta documentação à medida que as funções forem implementadas e verificadas.

---

## 📄 Referência Técnica

Este README resume a arquitetura e as decisões técnicas previstas para o TekVision. A documentação deve ser atualizada conforme o desenvolvimento evoluir e as decisões forem confirmadas.

---

## 🏫 Mostra de Tecnologia — FUNEC Riacho

Projeto acadêmico desenvolvido pela equipe TekVision no curso Técnico em Informática da FUNEC Riacho.
