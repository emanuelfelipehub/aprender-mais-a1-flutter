# A1 — requisitos, implementação e evidências

Referência: enunciado A1 de 16 páginas, guia visual fornecido e linhas A1 da CIS. As escolhas diante de divergências estão em DECISOES.md.

## Resultado da verificação

- Analisador Dart/Flutter: **No issues found**.
- Testes locais de regras e interface: **22 aprovados**.
- Testes de integração Android: **2 aprovados**.
- APK release: compilado, instalado e executado no emulador.
- 15 falas (5 cores × 3 idiomas) e efeito de clique: reprodução concluída no Android.
- Condições de rede, energia e sensores: verificadas por comandos do emulador e pela interface.
- Galeria: quatro imagens selecionadas pelo seletor Android e tema Personalizado exibido.
- Widget: inclusão pelo menu Widgets, opção Widgets pelo long press no ícone, exibição de inteiros e abertura do app confirmadas.
- **Limite de verificação:** conexão de fone físico e sensação da vibração precisam de aparelho real. O código trata fone analógico/USB; a simulação do emulador não produziu o evento esperado de fone. A mensagem do fone foi verificada em teste de interface.
- Git remoto: não publicado, por ser treino sem servidor de entrega.

## Demandas gerais — PDF p. 4

| Requisito | Implementação | Verificação |
|---|---|---|
| Interface intuitiva, textos, cores, acessibilidade | Home, theme.dart, Semantics, áreas de toque e fontes Montserrat locais | Inspeção visual das telas e testes de interface |
| Orientação de acordo com a tela | Retrato em Home, ME, VF e Genius; paisagem em REL e MemoCheck | Fluxo no Android, screenshots e chamadas SystemChrome |
| Bateria <=20%, imagem bateria.png, texto exato e sem repetição | Fila em main.dart e receiver Android | 20% ao iniciar e 19% depois de fechar; não repetiu |
| Sem internet ao iniciar, mensagem exata | snapshot Android e fila da raiz | Rede do emulador desligada; aviso confirmado |
| Economia de energia ao iniciar, mensagem exata | PowerManager.isPowerSaveMode e fila | Modo economia ativado no emulador; aviso confirmado |
| Fone com fio mostra SnackBar e define volume de mídia em 50% | BroadcastReceiver + AudioDeviceCallback; arredondamento para passo inteiro disponível | Mensagem em teste de widget; conexão/volume físicos pendentes |

## Home — PDF p. 6

| Requisito | Implementação | Verificação |
|---|---|---|
| Menu com perfil, voltar, Home, QuizMyBrain, GeniusPLay, MemoCheck e Sair | Drawer e ListTile em home_page.dart | Teste de abertura/fechamento; inspeção do menu |
| Logotipo e Bem-vindo ao Aprender+ | Imagens originais e texto exato | Screenshot final; versão de logo correta para fundo claro |
| Abrir cada jogo | Navigator.push e retorno à Home | Integração com os três jogos |
| Sair fecha o app | SystemNavigator.pop | Verificação pela Activity/launcher no APK final |

## Quiz — PDF pp. 7–10

| Requisito | Implementação | Verificação |
|---|---|---|
| Ler JSON e adaptar a tela a ME/VF/REL | parseQuestions, Question e QuizPage | Sete questões do arquivo original lidas; fluxo completo |
| Pontuação pelo peso, sem duplicação | QuizSession.grade e graded | Soma completa 39; testes de erro e múltiplos toques |
| ME: quatro alternativas com letras, seleção única, Encerrar/Próximo | _choice e _next | Interface e integração |
| ME: primeiro Próximo revela terceira cor; segundo avança | revealed e grade | Teste específico mantém a mesma questão antes de avançar |
| VF: caixas Falso/Verdadeiro, toque ou giro | _choices e eventos do acelerômetro | Giro à direita/esquerda confirmado por seleção semântica |
| VF: animação 2D instrutiva | TiltTutorial com AnimationController | Presente na tela; animação revisada no código |
| REL: três termos/conceitos, drag-and-drop e concatenação | Draggable/DragTarget e _matching | Todos os pares ligados no fluxo de integração |
| REL em paisagem | _orient | Executado no Android |
| Encerrar/finalizar mostra score e retorna à Home | _finish, diálogo e saveScore | Quiz completo e encerramento antecipado |
| Gabarito inválido na questão 501 | Correção autorizada na leitura | Teste de índices e soma; original preservado |

## Genius — PDF pp. 11–12

| Requisito | Implementação | Verificação |
|---|---|---|
| Idiomas Português/Inglês/Espanhol e idioma do sistema | locale.languageCode e seletor | Código revisado; todas as 15 falas reproduzidas |
| Nível, cronômetro MM:SS, pentágono, Start/Stop, Restart e score | GeniusPage e PentagonSegment | Interface e integração |
| Nova sequência aleatória de tamanho igual ao nível | GeniusGame.newRound | Testes determinísticos com Random controlado |
| Cores bloqueadas durante fala | _speaking controla ações | Fluxo só aceita jogada na fase Sua vez |
| Sobe nível a cada dois acertos, +1 só por rodada correta | score ~/ 2 + 1 e press | Testes de seis rodadas e erro |
| Erro mostra resultado/tempo e reseta | _stop(showResult: true) | Regra e código revisados |
| Stop zera estado da partida; Restart reinicia automaticamente | _stop, _restart e _epoch | Teste de interface específico |
| Toque acende a cor e toca clique | _lit, AnimatedContainer e play(effect:true) | Integração e reprodução do efeito |
| Voltar encerra e retorna à Home | _back e dispose | Integração; pontuação anterior não é sobrescrita ao voltar parado |

## MemoCheck — PDF pp. 12–14

| Requisito | Implementação | Verificação |
|---|---|---|
| Tema inicial Animais da Amazonia, 8 cartas/4 pares aleatórios visíveis | prepare e assets originais | Testes e screenshots |
| Flip ao mostrar e esconder | TweenAnimationBuilder, Matrix4 e perspectiva | Integração e inspeção da animação |
| START → 3,2,1 → STOP, esconde e inicia cronômetro | _start, _countdown e Stopwatch | Teste específico dos três segundos |
| Tema desabilitado durante jogo | locked e onChanged:null | Código e interface |
| Um par igual fica aberto; diferente fecha em 1 segundo | reveal e _mismatch | Unidade e integração com erro intencional |
| Contadores separados e vibração no erro | hits/errors e ponte vibrate | Unidade e chamada Android; sensação física não aferida |
| Fim ou STOP mostra resultado/tempo e zera contadores | _end | Conclusão dos quatro pares e teste de STOP |
| Chacoalhar embaralha | SensorEventListener e MemoryGame.shuffle | Evento de aceleração e ordem das cartas confirmados |
| Trocar tema usa imagens de animais/carros | _images e _theme | Assets e código revisados |
| Configurações abre galeria, seleciona quatro fotos e exibe nos cards | pickPhotos e Image.file | Seleção real de quatro imagens; Personalizado confirmado |

## Widget e entrega — PDF pp. 15–16

| Requisito | Implementação | Verificação |
|---|---|---|
| Frase, três cards, números inteiros e nomes dos jogos | scores_widget.xml, cores e fonte Montserrat | Prévia e widget adicionado no launcher |
| Última pontuação, ou zero quando ainda não jogou | SharedPreferences privadas | Valores iniciais 0 e atualização da pontuação do quiz |
| Long press no ícone → Widgets | Receiver AppWidgetProvider registrado no manifesto | Menu Widgets confirmado |
| Tocar abre o app | PendingIntent para MainActivity | App reaberto pelo widget |
| Pasta/APK 08_Modulo_A1_XX | Projeto isolado e APK na raiz | Entrega de treino |
| Publicar no Git remoto | Não executado | Treino; servidor não fornecido |

## Evidências reproduzíveis

- evidencias/analyze.txt
- evidencias/unit_widget_tests.txt
- evidencias/integration_tests.txt
- evidencias/build_release.txt
- evidencias/android_system_checks.json
- evidencias/final_android_checks.json
- evidencias/guide_checks.json
- Imagens numeradas na pasta evidencias.

## Ambiente e limites

Flutter 3.47.5 / Dart 3.13.4, SDK compilação e destino 36, mínimo Android API 24, teste em emulador API 37. O exemplo da prova cita outras versões. Não foi alegada validação em Flutter 3.32.6/API 35 nem uma recompilação com a rede física do PC desligada. As dependências foram resolvidas do cache com pub get --offline; a execução sem internet foi testada no emulador.

O APK é de treino, com assinatura debug. Não é uma entrega enviada a um servidor oficial nem um pacote assinado para Play Store.

