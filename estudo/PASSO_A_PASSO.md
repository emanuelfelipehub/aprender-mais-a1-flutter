# Como este app foi construído — sua sequência de aulas

Este projeto reúne recursos avançados porque o pedido foi implementar o A1 inteiro. Para aprender do zero, leia uma parte pequena, execute, altere um valor e explique o resultado com suas palavras.

## 1. Entender as ferramentas

**Dart** é a linguagem que descreve dados e regras. **Flutter** fornece os componentes visuais e o mecanismo que desenha o app. **Android Studio** é o editor e ambiente de desenvolvimento. **Emulador** simula um aparelho Android. **Gradle** organiza a compilação Android. **APK** é o pacote instalável resultante.

**Kotlin** aparece somente na integração Android: sensores, bateria, volume, fotos, áudio e widget externo. A tela Flutter continua escrita em Dart. MethodChannel leva pedidos Dart ao Android; EventChannel traz acontecimentos do aparelho ao Dart.

## 2. Transformar o PDF em comportamentos

Dividimos o A1 em demandas gerais, Home, quiz, Genius, memória e widget. Um requisito virou uma regra observável: “a cada duas partidas corretas incrementa-se a fase” virou a expressão score ~/ 2 + 1. A leitura de JSON foi mantida separada da tela para podermos conferir seu funcionamento por testes.

## 3. Começar pelo ponto de entrada

Abra lib/main.dart e acompanhe as linhas no guia CODIGO_EXPLICADO.html.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(AprenderApp(device: AndroidDeviceBridge()));
}
```

- **Future<void>** descreve uma operação que terminará no futuro sem devolver um valor útil.
- **main** é o nome especial do ponto de entrada.
- **()** reúne parâmetros. Aqui a lista está vazia.
- **async** permite usar await dentro da função.
- **{ e }** delimitam as instruções pertencentes à função.
- **WidgetsFlutterBinding** é a ligação entre o motor Flutter e os serviços usados pelo código.
- **.** acessa um membro de uma classe ou objeto.
- **ensureInitialized()** garante que essa ligação exista antes de chamar serviços.
- **await** espera a tarefa terminar sem travar o fluxo de eventos da interface.
- **SystemChrome.setPreferredOrientations** pede a orientação permitida.
- **[ e ]** delimitam uma lista.
- **DeviceOrientation.portraitUp** representa retrato com o topo do aparelho para cima.
- **runApp** entrega a árvore principal de componentes ao Flutter.
- **AprenderApp(...)** cria o componente principal do nosso projeto.
- **device:** é um argumento nomeado: informa qual objeto será usado para falar com o aparelho.
- **AndroidDeviceBridge()** cria a nossa implementação da ponte Android.
- **;** termina uma instrução.

Exercício: localize o lugar onde o quiz troca para paisagem. Por que travar todo o aplicativo em retrato impediria cumprir o A1?

## 4. Entender um widget antes de montar uma tela

Widget é uma descrição de um pedaço da interface. Text descreve texto; Image descreve imagem; Row organiza horizontalmente; Column organiza verticalmente; Padding cria espaço interno. child recebe um filho; children recebe vários filhos.

StatelessWidget usa os valores recebidos para descrever a interface. StatefulWidget tem um objeto State que guarda informações que podem mudar. setState registra uma mudança e pede que Flutter reconstrua a interface correspondente; ele não reinicia o app inteiro.

Comece por lib/theme.dart, depois HomePage em lib/screens/home_page.dart.

## 5. Aprender dados e regras com o quiz

Em lib/core/game_logic.dart, Question transforma campos JSON em um objeto Dart. List guarda itens em ordem; Map associa uma chave a um valor. O índice de uma lista começa em zero: na primeira pergunta, resposta 3 indica a quarta alternativa, Insert.

QuizSession guarda índice da pergunta, alternativa escolhida, pares e pontuação. grade soma o peso apenas se a resposta estiver completa e ainda não tiver sido corrigida. O sinal = atribui; == compara; += soma e guarda; ! nega uma condição; && exige que duas condições sejam verdadeiras.

O primeiro toque em Próximo no ME revela o gabarito. O segundo avança. Em VF o sensor e o toque chamam a mesma regra select. Em REL, Draggable transporta o número do termo; DragTarget recebe esse número e registra a associação.

Exercício: a primeira questão vale 5. Acertar e tocar duas vezes em Próximo deve dar 5 ou 10? Aponte a variável que impede a duplicação.

## 6. Lidar com tempo e cancelamento no Genius

GeniusGame sorteia cores e calcula o nível. GeniusPage mostra botões, aguarda áudio e mede tempo.

Stopwatch mede o tempo decorrido. Timer.periodic pede atualizações do texto do cronômetro. Future.delayed agenda continuação futura. _epoch é um número de geração: quando paramos uma partida, ele muda; uma continuação antiga compara o número e não pode reativar a partida encerrada.

A expressão score ~/ 2 faz divisão inteira. Com score 0 ou 1, o nível é 1. Com score 2 ou 3, o nível é 2. Random.nextInt(5) sorteia de 0 a 4, os cinco índices das cores.

Exercício: por que os botões precisam ficar desabilitados enquanto a sequência é falada?

## 7. Construir a memória sem misturar imagem e identidade

MemoryCardData tem um id único para cada carta e um pair compartilhado pelas duas cartas iguais. Embaralhar muda posições, mas não esses identificadores.

Uma primeira carta aguarda a segunda. Se o pair coincidir, ambas ficam abertas e hits aumenta. Se forem diferentes, errors aumenta, o Android vibra e Timer espera um segundo antes de escondê-las. busy bloqueia uma terceira carta enquanto o erro é mostrado.

TweenAnimationBuilder interpola o ângulo do flip. Matrix4 descreve a transformação em perspectiva. Image.asset mostra imagem empacotada; Image.file mostra foto escolhida.

Exercício: se usássemos somente a posição da carta como identidade, o que poderia dar errado depois de chacoalhar o aparelho?

## 8. Conectar ao aparelho

Leia device_bridge.dart antes de MainActivity.kt. O contrato DeviceBridge permite usar um aparelho falso nos testes. AndroidDeviceBridge envia uma mensagem com nome e argumentos; MainActivity escolhe o tratamento com when e responde com result.success ou result.error.

O Android envia eventos de bateria e fone por BroadcastReceiver; sensores por SensorEventListener. O Dart assina uma Stream e cancela a assinatura em dispose. Fechar timers, áudio e assinaturas evita trabalho de uma tela que não está mais aberta.

## 9. Guardar o placar e desenhar o widget externo

SharedPreferences guarda três inteiros privados. saveScore escreve antes de atualizar os widgets. ScoresWidget lê esses valores e preenche RemoteViews. O XML determina o desenho visível no launcher. PendingIntent permite que o launcher abra a Activity quando o usuário toca no widget.

O widget do launcher e os widgets Flutter são conceitos diferentes: o primeiro pertence à tela inicial Android; os segundos descrevem partes da interface Flutter.

## 10. Verificar e entregar

flutter analyze verifica problemas estáticos. flutter test executa regras e interfaces simuladas. O teste em integration_test usa o Android real do emulador, incluindo a ponte e o áudio.

Confira manualmente a condição offline, bateria baixa, economia, fone, sensores, quatro fotos e widget. O relatório REQUISITOS_E_TESTES.md identifica evidências e limites. Compile com flutter build apk --release e copie o APK para a raiz com o nome exigido.

O guia linha a linha acompanha o código real desta entrega. Escolha um arquivo, selecione uma linha e consulte os termos e sinais usados nela. Os scripts de Gradle e arquivos gerados são explicados como infraestrutura; o foco inicial deve ser o código Dart.

