"""Gera um guia de leitura com as linhas reais dos fontes, sem dependencia de internet."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]
LEX={}
def add(keys,description):
 for key in keys.split():LEX[key]=description
TEXT="""
import package|Importa uma biblioteca ou define o namespace/pacote do arquivo.
class|Declara um tipo que reúne dados e comportamentos.
extends|Herda o comportamento de uma classe base.
implements|Obriga a classe a implementar o contrato de uma interface.
abstract|Define um contrato que não é instanciado diretamente.
with|Acrescenta um mixin: conjunto reutilizável de comportamentos.
factory fromJson|Construtor que converte os dados recebidos em uma instância do modelo.
final val|Referência atribuída uma vez. O objeto guardado ainda pode mudar internamente.
var|Declara uma variável, com tipo normalmente inferido pelo valor inicial.
late lateinit|Adia a inicialização; ler antes de inicializar é erro.
const|Valor/construção constante quando os argumentos permitem avaliação constante.
required|Exige que um argumento nomeado seja fornecido.
this|Refere-se ao objeto atual; em construtores Dart, this.campo recebe o argumento no campo.
super|Acessa a classe base ou repassa parâmetros ao construtor dela.
override|Indica a implementação de um membro da classe/interface base.
static companion|Permite acessar membros relacionados à classe, sem criar uma instância dela.
private|Restringe a visibilidade no Kotlin. Em Dart, nomes com _ são privados à biblioteca.
fun|Declara uma função Kotlin.
void|A função não fornece resultado útil.
async|Permite usar await dentro de uma função assíncrona.
await|Espera uma operação assíncrona sem bloquear os demais eventos da interface.
Future|Representa o resultado futuro de uma operação; o tipo entre < > descreve o resultado.
Stream|Sequência de acontecimentos recebidos ao longo do tempo.
StreamSubscription|Assinatura de um fluxo, que pode ser cancelada ao fechar a tela.
return|Devolve o resultado indicado e encerra a execução atual da função.
if else when switch|Escolhe uma expressão/bloco conforme uma condição ou valor.
for while until in|Repetição/iteração: percorre uma coleção ou intervalo indicado.
try catch throw|Trata uma operação que pode falhar; catch recebe o erro e throw sinaliza uma falha.
as|Interpretação/conversão para o tipo indicado; falha se o valor não corresponder.
is|Verifica se o valor possui o tipo indicado.
get|Getter: calcula um valor quando o nome é acessado como propriedade.
true false bool Boolean|Valores e tipos lógicos: verdadeiro/falso.
null|Ausência de valor; tipos Dart com ? podem conter null.
assert require check requireNotNull|Confere uma condição esperada e sinaliza erro se não for satisfeita.
int Int IntArray|Inteiro, como 0 ou 5. IntArray é um vetor de inteiros Kotlin.
double num toDouble|Número com parte fracionária, tipo numérico ou conversão para double.
String|Texto; um literal de texto fica entre aspas.
List Map|Coleções: List guarda itens ordenados; Map associa chaves a valores.
dynamic Object Any|Tipos gerais de valores; dynamic adia verificações de membros no Dart.
Widget|Descrição de um pedaço da interface Flutter.
StatefulWidget State|Widget com estado mutável e o objeto State que mantém esse estado.
StatelessWidget|Widget sem State próprio, construído a partir dos valores recebidos.
createState|Cria o State associado ao widget.
initState|Inicializa o State uma vez quando ele entra na árvore.
dispose|Libera recursos antes de o State ser removido, evitando trabalho de telas fechadas.
build|Descreve a árvore visual conforme os dados atuais; pode ser chamado muitas vezes.
BuildContext context|Localização na árvore de widgets, usada para tema, diálogos e navegação.
mounted|Indica se o State ainda está conectado à árvore; é conferido depois de operações assíncronas.
setState|Altera dados da tela e agenda a reconstrução da interface correspondente.
widget|Configuração atual do StatefulWidget ao qual este State pertence.
key ValueKey GlobalKey|Identidade de widgets; GlobalKey também dá acesso a State/contexto.
main runApp|main é o ponto de entrada; runApp entrega o componente principal ao Flutter.
WidgetsFlutterBinding WidgetsBinding ensureInitialized instance|Ligação entre o framework e o motor Flutter; ensureInitialized a prepara antes dos serviços.
addPostFrameCallback|Executa após o quadro atual, quando já existe interface para abrir os avisos.
platformDispatcher locale languageCode|Consulta o idioma do sistema para escolher a língua inicial do Genius.
MaterialApp|Configura os serviços principais do app: tema, navegação e título.
AprenderApp _AprenderAppState|Componente raiz deste projeto e seu State; cuida dos avisos e da configuração.
HomePage _HomePageState|Tela inicial: marca, menu lateral, jogos e pontuações.
QuizPage _QuizPageState|Apresentação do quiz, seleção de respostas, correção e encerramento.
GeniusPage _GeniusPageState|Interface de áudio, cronômetro e controles do Genius.
MemoryPage _MemoryPageState|Interface de cartas, fotos, contagem regressiva e placar da memória.
Question|Modelo dos campos de uma pergunta do JSON.
QuizSession|Estado e regras de uma tentativa de quiz.
GeniusGame|Regras de sequência aleatória, pontuação e nível do Genius.
MemoryGame MemoryCardData|Regras da memória e identificação/estado de cada carta.
DeviceBridge AndroidDeviceBridge|Contrato e implementação da comunicação entre Dart e recursos Android.
MainActivity|Entrada nativa Android que hospeda o Flutter e atende os pedidos do aparelho.
ScoresWidget|Widget Android da tela inicial com as três últimas pontuações.
StatChip|Componente deste projeto para mostrar um rótulo e um valor.
FlipCard|Widget que anima a carta girando entre imagem e verso.
TiltTutorial _TiltTutorialState|Animação 2D de instrução sobre girar o celular.
PentagonSegment|Recorta um dos cinco setores de cores do pentágono.
SystemChrome DeviceOrientation setPreferredOrientations portraitUp landscapeLeft landscapeRight|Controla a orientação permitida: retrato ou uma das duas paisagens.
SystemNavigator|Serviço Flutter para sair da Activity quando o usuário escolhe Sair.
Navigator NavigatorState MaterialPageRoute push pop|Serviços de navegação: push abre uma rota; pop fecha a rota atual.
PopScope canPop onPopInvokedWithResult didPop|Intercepta o botão Voltar para encerrar a partida corretamente.
Scaffold|Estrutura de tela com barra superior, corpo, menu e região inferior.
ScaffoldMessenger ScaffoldMessengerState scaffoldMessengerKey SnackBar showSnackBar|Serviço, chave e mensagem temporária usada para feedback, como o fone conectado.
AlertDialog showDialog barrierDismissible|Janela modal e controle para permitir/impedir fechá-la tocando fora.
AppBar AppBarTheme appBar appBarTheme|Barra superior e sua configuração visual.
Drawer drawer|Menu lateral da Home.
Column Row Wrap Stack|Organiza filhos em coluna, linha, linha que quebra ou camadas sobrepostas.
Expanded Spacer|Distribui o espaço livre do organizador; Spacer ocupa espaço entre os elementos.
Center Align Alignment alignment center centerLeft|Alinha/centraliza um componente no espaço disponível.
Padding padding EdgeInsets all only symmetric fromLTRB|Define espaçamento interno: todos os lados, lados específicos, simetria ou esquerda/topo/direita/baixo.
SizedBox Size BoxConstraints constraints width height maxWidth maxHeight minHeight shortestSide|Dimensões e limites do layout usados para evitar transbordamento.
SafeArea|Evita áreas ocupadas por recortes da tela, status e navegação do sistema.
Container BoxDecoration decoration|Combina tamanho, espaço, alinhamento e aparência de um elemento.
ListView GridView count crossAxisCount|Lista ou grade; crossAxisCount determina a quantidade de colunas.
SingleChildScrollView NeverScrollableScrollPhysics physics|Rolagem de conteúdo ou bloqueio de rolagem quando a grade já cabe na área.
LayoutBuilder builder|Constrói widgets conhecendo os limites disponíveis. builder é a função que devolve a construção.
Text TextStyle TextTheme textTheme|Texto e suas características visuais.
Theme ThemeData appTheme theme|Tema compartilhado e função deste projeto que o configura.
Color Colors ColorScheme fromSeed colorScheme seedColor|Cor e paleta Material produzida a partir de uma cor de origem.
ink purple violet paper|Cores do guia de estilos: roxo escuro, roxo, violeta e fundo claro.
fontFamily fontSize FontWeight fontWeight w700 w900|Família, tamanho e peso da fonte; 700 é bold e 900 é black.
titleLarge headlineSmall bodyMedium titleTextStyle textStyle|Estilos nomeados para títulos e corpo do texto.
TextAlign textAlign MainAxisAlignment MainAxisSize CrossAxisAlignment WrapAlignment|Configuração de alinhamento, distribuição e tamanho no eixo do organizador/texto.
mainAxisAlignment mainAxisSize crossAxisAlignment spaceBetween stretch|Argumentos e valores de alinhamento: distribuir nos extremos ou esticar os filhos.
child children|child recebe um filho; children recebe uma lista de filhos.
primary onPrimary surface onSurface foregroundColor backgroundColor scaffoldBackgroundColor|Cores dos componentes; onPrimary/onSurface são as cores do conteúdo sobre a superfície.
Border BorderRadius border borderRadius circular|Bordas e cantos arredondados.
Image AssetImage File fit BoxFit cover cacheWidth backgroundImage|Imagem de asset/arquivo; cover preenche com recorte e cacheWidth limita a resolução decodificada.
Icon Icons IconData icon|Ícone do catálogo Material e o identificador do desenho.
IconButton FilledButton OutlinedButton TextButton|Botões de ícone, preenchido, contornado ou de texto.
FilledButtonThemeData filledButtonTheme styleFrom minimumSize|Tema/estilo dos botões, incluindo a área mínima de toque.
CircleAvatar CircleBorder Card|Avatar circular, formato circular e superfície de cartão.
ListTile leading trailing subtitle actions|Linha interativa e suas regiões de início, fim, subtítulo e ações.
onPressed onTap onChanged onAcceptWithDetails|Callback: função executada no acontecimento indicado; null desabilita ações de botões.
GestureDetector InkWell Material|Recebe gestos e fornece a superfície Material com feedback de toque.
Draggable DragTarget data feedback childWhenDragging candidates rejected details|Transporte de dados por arraste, destino, visual provisório e informações da aceitação.
DropdownButton DropdownButtonFormField DropdownMenuItem InputDecoration OutlineInputBorder|Campo de seleção, itens e decoração utilizados no idioma e no tema.
items value initialValue labelText|Itens disponíveis, valor selecionado/inicial e rótulo do campo.
Semantics semanticLabel excludeFromSemantics label selected enabled button tooltip|Informações acessíveis: nome, seleção, habilitação, papel de botão e texto auxiliar.
AnimatedBuilder AnimatedContainer AnimationController animation vsync SingleTickerProviderStateMixin|Animações; o controller produz valores e vsync sincroniza com os quadros.
Tween TweenAnimationBuilder tween begin end duration reverse repeat|Interpola entre valores de início/fim; repeat repete a animação e reverse alterna o sentido.
Transform Matrix4 transform identity setEntry rotateY rotationY rotate angle|Transformações geométricas e perspectiva do flip 3D.
CustomClipper Path getClip shouldReclip clipper ClipPath ClipRRect addPolygon points|Caminho e recorte de formas; usados no pentágono e nos cantos das cartas.
Positioned fill Opacity opacity transparent white|Posicionamento, preenchimento e transparência no desenho.
Random random nextInt generate shuffle|Sorteios e embaralhamento; nextInt(5) retorna de zero até quatro.
Stopwatch Timer periodic elapsed inSeconds inMilliseconds Duration milliseconds seconds|Medição de tempo e agendamento de ações; Stopwatch mede e Timer agenda.
delayed unawaited|delayed agenda uma continuação; unawaited indica que a Future não será aguardada naquele ponto.
DateTime now difference fromMillisecondsSinceEpoch|Datas e intervalos; usados para limitar a frequência dos giros.
start stop reset cancel|Inicia, interrompe, reinicia ou cancela o recurso que aparece antes do ponto.
jsonDecode fromJson parseQuestions loadString rootBundle|Lê texto de assets, interpreta JSON e converte os dados em perguntas.
cast map toList entries every where firstWhere firstOrNull first containsKey removeWhere clear remove length isEmpty isNotEmpty|Operações em coleções: converter, transformar, percorrer, consultar, filtrar ou remover.
toString padLeft fromCharCode|Formatação de texto, preenchimento com zeros e conversão do código de uma letra.
id index weight type text options answer choices terms concepts matchingAnswer|Dados da pergunta: identificador, posição, peso, tipo, enunciado, alternativas e gabarito.
questions current score revealed graded matches canSubmit isCorrect|Estado do quiz e verificações para permitir enviar/corrigir sem duplicar pontos.
select match grade next|Ações do quiz: escolher, associar, pontuar uma vez e revelar/avançar.
inputIndex sequence level newRound press|Estado/regras Genius: posição da entrada, sequência, nível, nova rodada e verificação da cor.
cards card pair faceUp matched hits errors firstId busy prepare hideAll reveal hideMismatch complete|Dados e regras da memória: pares, visibilidade, acertos/erros, bloqueio e conclusão.
formatTime|Converte segundos para MM:SS, como 65 → 01:05.
StateError PlatformException Exception|Falhas; PlatformException comunica erro da implementação Android ao Dart.
MethodChannel EventChannel invokeMethod invokeListMethod receiveBroadcastStream asBroadcastStream|Canais: pedidos com resposta e fluxo de eventos do aparelho para vários ouvintes.
listen onError|Assina um fluxo e trata os erros que ele emitir.
snapshot scores saveScore play stopAudio vibrate pickPhotos events|Contrato do aparelho: consulta, placar, áudio, vibração, fotos e eventos.
navigator messenger alerts batteryWarned|Controle da raiz: navegação, mensagens, fila de avisos e bloqueio de alerta repetido.
inspectDevice checkBattery enqueue event|Consulta estado, aplica o limite de bateria, enfileira aviso e processa evento do aparelho.
refresh open menu|Funções da Home para atualizar placar, abrir jogo e montar menu.
load orient finish choice choices matching matchBox|Funções da tela de quiz: carregar, orientar, concluir e montar alternativas/associações.
running speaking lit language epoch watch timer flash mismatch countdown customImages images theme|Estado da tela; epoch cancela continuações antigas e lit identifica a cor acesa.
speakRound restart back end|Ações da tela: reproduzir sequência, reiniciar, voltar ou concluir uma partida.
animalImages carImages audioNames geniusColors colorLabels|Listas de arquivos, falas, cores e rótulos fornecidos/configurados no projeto.
token previous hadGame played locked wide front correct active|Controle local: geração, índice anterior, existência de partida, áudio tocado, bloqueio, formato e destaque.
min max abs cos sin sqrt pi Offset radius point|Funções matemáticas e geometria do pentágono, giro e intensidade de movimento.
i j k x y z term concept entry pair copy scale half|Variáveis locais: contadores, coordenadas, índices ou medidas; a expressão da linha indica qual.
source expected message asset effect result error game device status|Valores de trabalho: fonte/gabarito/texto, caminho de áudio, efeito, resultado, erro, jogo e aparelho.
Activity FlutterActivity FlutterEngine FlutterInjector dartExecutor binaryMessenger flutterLoader getLookupKeyForAsset|Infraestrutura Android do Flutter e resolução do caminho dos assets empacotados.
Context getSystemService AUDIO_SERVICE CONNECTIVITY_SERVICE POWER_SERVICE SENSOR_SERVICE VIBRATOR_SERVICE VIBRATOR_MANAGER_SERVICE|Consulta os serviços Android de áudio, rede, energia, sensores e vibração.
Intent IntentFilter addAction addCategory BroadcastReceiver onReceive registerReceiver unregisterReceiver|Mensagens Android e receptor de eventos registrados por filtro.
ACTION_BATTERY_CHANGED ACTION_HEADSET_PLUG ACTION_OPEN_DOCUMENT ACTION_PICK_IMAGES CATEGORY_OPENABLE|Constantes de evento do sistema e de abertura de documentos/fotos.
EXTRA_LEVEL EXTRA_SCALE EXTRA_ALLOW_MULTIPLE EXTRA_PICK_IMAGES_MAX|Chaves do Intent para carga, escala e múltipla seleção de imagens.
BatteryManager batteryLevel getIntExtra|Lê e converte os dados de bateria para percentual.
ConnectivityManager NetworkCapabilities activeNetwork getNetworkCapabilities hasCapability capabilities NET_CAPABILITY_INTERNET NET_CAPABILITY_VALIDATED|Consulta a rede e verifica internet disponível/validada pelo sistema.
PowerManager isPowerSaveMode|Serviço de energia e consulta ao modo de economia.
AudioManager STREAM_MUSIC getStreamMaxVolume setStreamVolume roundToInt|Consulta/ajuste de volume de mídia, arredondando para um passo disponível.
MediaPlayer AudioAttributes setAudioAttributes setUsage setContentType setDataSource prepareAsync setOnPreparedListener setOnCompletionListener setOnErrorListener release|Preparo, reprodução e liberação de áudio com callbacks.
USAGE_GAME CONTENT_TYPE_SONIFICATION CONTENT_TYPE_SPEECH|Classificação do som como jogo, efeito ou fala.
voice voiceResult effectResult player callback completed isEffect playSound finishSound|Players/callbacks de fala e clique; finishSound libera e responde uma única vez.
assets openFd descriptor fileDescriptor startOffset|Acesso a um trecho de arquivo de áudio empacotado como asset.
Sensor SensorManager SensorEvent SensorEventListener registerListener unregisterListener onSensorChanged onAccuracyChanged TYPE_ACCELEROMETER SENSOR_DELAY_GAME|Acelerômetro e ciclo de recebimento das leituras.
SystemClock elapsedRealtime lastMotion lastShake|Relógio monotônico e instantes usados para evitar excesso/repetição de eventos.
Vibrator VibratorManager VibrationEffect defaultVibrator createOneShot DEFAULT_AMPLITUDE|Serviços e efeito de vibração no erro do jogo da memória.
Build VERSION SDK_INT RECEIVER_NOT_EXPORTED isInitialStickyBroadcast|Versão do Android, registro privado de receiver e identificação de broadcast inicial retido.
getSharedPreferences MODE_PRIVATE edit putInt commit getInt prefs scoreValues|Preferências privadas com os três placares; commit confirma a gravação antes da atualização do widget.
EventSink StreamHandler Result setMethodCallHandler setStreamHandler onListen onCancel success notImplemented argument arguments call method sink|Atendimento nativo dos canais: entrada, resposta e publicação dos eventos.
MediaStore contentResolver openInputStream cacheDir absolutePath outputStream copyTo photoResult uris uri paths selectionId requestCode resultCode onActivityResult startActivityForResult clipData itemCount getItemAt putExtra RESULT_OK|Seletor Android de fotos, leitura autorizada, cópia para cache e devolução dos caminhos ao Dart.
onResume onPause onDestroy configureFlutterEngine receiverRegistered receiver|Ciclo de vida da Activity e controle de canais, sensores e receivers.
AppWidgetManager AppWidgetProvider RemoteViews PendingIntent ComponentName getInstance getAppWidgetIds updateAppWidget getActivity setTextViewText setOnClickPendingIntent onUpdate updateAll update|Widget externo: lê instâncias, atualiza o layout/textos e permite abrir o app.
FLAG_ACTIVITY_NEW_TASK FLAG_ACTIVITY_CLEAR_TOP FLAG_UPDATE_CURRENT FLAG_IMMUTABLE flags|Configura como a Activity é aberta e protege a ação pendente do widget.
R layout widget_root quiz_score genius_score memo_score scores_widget|IDs de recursos Android gerados a partir dos arquivos XML.
apply let use it to or mapOf listOf listOfNotNull emptyList associateWith mapIndexed forEach|Construções Kotlin para configurar objetos, lidar com nulos, fechar recursos e montar/percorrer coleções.
Deprecated Suppress|Anotações que documentam APIs antigas ou suprimem avisos conhecidos.
FakeDevice RecordingDevice IntegrationTestWidgetsFlutterBinding|Aparelho simulado, adaptador de registro e infraestrutura de testes no Android.
test testWidgets group expect findsOneWidget findsNothing findsNWidgets isA inInclusiveRange greaterThanOrEqualTo|Declara cenários de teste e compara resultado com o esperado.
tester pump pumpWidget pumpAndSettle tap tapAt ensureVisible getCenter getRect startGesture moveTo up evaluate byKey byType byTooltip find|Ferramentas de teste para montar interface, localizar elementos, avançar quadros e simular ações.
br com aprendermais aprender_a1 dart async convert math io flutter material services android app content hardware media net os provider plugin common java kotlin plugins|Parte de um caminho de biblioteca/namespace; identifica a origem dos símbolos.
"""
for record in TEXT.strip().splitlines():
 keys,description=record.split('|',1);add(keys,description)

EXTRA="""
_finishing finishing|Bloqueia chamadas duplicadas enquanto uma partida está sendo encerrada.
_lastTilt lastTilt|Instante do último giro aceito, para evitar leituras repetidas rápidas.
_methods methods _events _stream stream _subscription subscription|Canal de pedidos, fluxo de eventos e assinatura que conecta o Dart ao Android.
_quiz quiz|Sessão atual do quiz com seu índice, resposta e pontuação.
CircularProgressIndicator|Indicador de carregamento enquanto as perguntas são lidas.
AudioDeviceCallback AudioDeviceInfo addedDevices removedDevices getDevices GET_DEVICES_OUTPUTS isSink registerAudioDeviceCallback unregisterAudioDeviceCallback|Monitor Android de entrada/saída de dispositivos de áudio. Filtra fones analógicos e USB para ajustar o volume uma vez por conexão.
Array out|Vetor Kotlin e variância de saída, que permite receber elementos do tipo indicado ou subtipo.
Handler Looper getMainLooper|Executa callbacks na fila da thread principal Android, usada pela ponte e pela interface.
Builder|Objeto construtor para configurar passo a passo um valor Android, antes de chamar build.
VoidCallback|Tipo de função Dart que não recebe argumentos e não devolve resultado útil.
System currentTimeMillis|Serviço Java que consulta o instante do relógio, usado no nome das cópias de fotos.
StreamController broadcast add close|Produz eventos em testes; broadcast permite múltiplas assinaturas e close encerra o fluxo.
accuracy|Informação de precisão do sensor; este app não precisa alterar sua lógica em resposta a ela.
addAll any contains endsWith indexWhere last startsWith toSet|Operações de coleção/texto: adicionar vários, testar condição/ocorrência, buscar índice, último item e conjunto sem repetição.
body bottomNavigationBar bottom actions title home navigatorKey debugShowCheckedModeBanner systemAlerts|Áreas/configurações da tela ou do app: corpo, barra inferior, ações, título, Home e ativação dos avisos.
centerTitle isExpanded useMaterial3|Centraliza o título, expande o seletor ou ativa a aparência Material 3.
margin elevation shape style horizontal vertical runSpacing spacing crossAxisSpacing mainAxisSpacing minVerticalPadding childAspectRatio|Estilo/layout: margens, relevo, forma, eixos, espaçamento e proporção dos itens.
hovering|Indica que há um item arrastado sobre o destino; muda seu destaque.
currentContext currentState|Contexto ou State acessível pela chave global, quando já existe na árvore.
input output item clip oldClipper ids packageName flutterEngine engine sensor sensors connected|Nomes de trabalho locais: recurso de entrada/saída, item, dados de seleção, recorte anterior, IDs, pacote, motor, sensores ou conectividade. Leia a operação associada para distinguir o uso.
of from|Método que busca um serviço pelo contexto ou cria uma coleção a partir de outra; depende do tipo antes do ponto.
infinity zero|Valor sem limite máximo específico ou valor zero da classe indicada.
isInitialized|Verifica se uma propriedade lateinit Kotlin já recebeu valor.
object|Declara um objeto Kotlin, aqui uma implementação anônima de interface/callback.
on|Em Dart seleciona a classe de exceção tratada; em configuração XML pode fazer parte de um atributo.
showResult|Define se o encerramento da partida deve abrir o diálogo de resultado.
timeStamp|Instante relativo usado pelo gesto simulado no teste de drag-and-drop.
then|Encadeia uma continuação quando uma Future termina; aqui mantém os diálogos em fila.
run|Executa um bloco Kotlin e fornece seu resultado.
xml xmlns encoding manifest application activity receiver exported configChanges hardwareAccelerated launchMode taskAffinity windowSoftInputMode permission uses feature meta resource category intent filter action|Metadados do Android: descrevem formato/namespace, permissões, componentes e como a Activity se integra ao sistema.
LinearLayout TextView|Componentes nativos Android: organizador linear e texto, usados no widget do launcher.
layout_width layout_height layout_weight layout_marginTop layout_marginStart layout_marginEnd orientation padding gravity maxLines background textColor textSize textStyle fontFamily|Atributos de aparência e organização no XML Android: dimensões, distribuição, alinhamento, texto, fonte e cor.
shape solid stroke corners colorBackground drawable bitmap parent resources string style name item|Recursos de aparência Android: forma, preenchimento, contorno, cantos, desenho, texto e herança de estilo.
appwidget initialLayout previewLayout minWidth minHeight minResizeWidth minResizeHeight resizeMode targetCellWidth targetCellHeight updatePeriodMillis widgetCategory description|Configuração do widget: layout inicial/prévia, dimensões mínimas, redimensionamento, células e atualizações.
namespace applicationId compileSdk compileSdkVersion targetSdk targetSdkVersion minSdk minSdkVersion ndkVersion versionCode versionName|Configura o identificador do app e as versões da plataforma/ferramentas Android utilizadas na compilação.
compileOptions sourceCompatibility targetCompatibility compilerOptions jvmTarget JavaVersion VERSION_17 JvmTarget JVM_17|Configura a compatibilidade Java/Kotlin usada pelo Gradle para produzir o código Android.
pluginManagement plugins include includeBuild repositories google mavenCentral gradlePluginPortal dependencies buildTypes defaultConfig signingConfig signingConfigs getByName getProperty Properties inputStream load source org jetbrains dsl gradle util setup|Infraestrutura Gradle/Kotlin: plugins, repositórios, dependências, variantes, propriedades e assinatura de treino.
flutter_test integration_test flutter_lints environment sdk publish_to version fonts family Regular Bold Black Montserrat ttf en es pt animals cars|Configuração YAML ou caminho de recurso. Identifica ferramentas de teste, versão, fonte, idioma ou pasta de imagens.
L|Sufixo Kotlin de literal Long, inteiro de 64 bits.
"""
for record in EXTRA.strip().splitlines():
 keys,description=record.split('|',1);add(keys,description)

add('keys', 'Coleção das chaves de um Map, como os códigos pt/en/es do mapa de áudios.')
add('readAsStringSync', 'Lê um arquivo de texto de forma síncrona; usado apenas nos testes locais para carregar o JSON.')
add('getDefaultSensor', 'Obtém o sensor padrão Android do tipo pedido, ou null se o aparelho não o possui.')
add('c', 'Nome curto de parâmetro local em uma função de coleção; nestes testes representa uma carta.')
add('dev_dependencies', 'Dependências de desenvolvimento/testes, separadas das dependências do app em execução.')
add('embedding', 'Namespace da infraestrutura Flutter que hospeda o app no Android.')
add('layer list launch_background', 'Elemento/recurso XML Android: compõe as camadas do fundo inicial do aplicativo.')
add('in', 'Verifica participação em uma coleção ou introduz os itens percorridos em um laço, conforme o contexto.')
add('or', 'OU bit a bit Kotlin: combina flags de configuração em uma máscara.')
add('design', 'Parte da configuração uses-material-design, que inclui os ícones Material no aplicativo.')
SYMBOLS={'=':'Atribui um valor.','==':'Compara igualdade.','!=':'Compara diferença.','+=':'Soma e guarda.','++':'Incrementa em um.',
'!':'Negação ou afirmação de não nulo, conforme a posição.','?':'Tipo anulável ou parte de condição.','??':'Usa alternativa quando o valor é nulo.',
'?.':'Acessa somente se o objeto não for nulo.','&&':'E lógico.','||':'OU lógico.','~/':'Divisão inteira.','=>':'Função de expressão curta.',
'..':'Cascata: encadeia operações no mesmo objeto.','.':'Acessa um membro.',';':'Encerra uma instrução.',
':':'Separa nome e valor, tipo Kotlin ou partes de uma expressão. ', ',':'Separa itens ou argumentos.',
'(':'Abre argumentos/parâmetros/agrupamento.',')':'Fecha argumentos/parâmetros/agrupamento.',
'{':'Abre bloco, mapa ou argumentos nomeados.','}':'Fecha bloco, mapa ou grupo.','[':'Abre lista ou acesso por índice.',']':'Fecha lista/acesso.',
'<':'Menor que ou abertura de tipo genérico.','>':'Maior que ou fechamento de tipo genérico.','<=':'Menor ou igual.','>=':'Maior ou igual.',
'+':'Adição, concatenação de texto ou deslocamento.','-':'Subtração/sinal negativo.','*':'Multiplicação ou importação de membros.',
'/':'Divisão ou trecho de caminho.','%':'Resto da divisão.','@':'Início de anotação.','_':'Nome ignorado ou prefixo privado Dart.'}
SYMBOLS.update({'::':'Referência de membro/propriedade Kotlin; aqui verifica a inicialização de lateinit.', '->':'Separa condição/argumentos e resultado/corpo no Kotlin.', '...':'Espalha os itens de uma coleção dentro de outra coleção Dart.', '?:':'Operador Kotlin: usa o valor da direita quando o da esquerda é nulo.'})
TOKEN=re.compile(r"""//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b0x[\dA-Fa-f]+\b|\d+(?:\.\d+)?|[A-Za-z_$][\w$]*|=>|::|->|\.\.\.|\?:|\.\.|\?\.|\?\?|~/|==|!=|<=|>=|&&|\|\||\+\+|\+=|[^\s]""")
META={'lib/main.dart':'Entrada do app, tema e fila de avisos de bateria/rede/economia.',
'lib/core/game_logic.dart':'Modelos e regras puras dos jogos; comece aqui para estudar pontuação.',
'lib/theme.dart':'Paleta e tipografia Montserrat.',
'lib/services/device_bridge.dart':'Contrato testável de comunicação Dart–Android.',
'lib/screens/home_page.dart':'Menu lateral, marca, cartões dos jogos e últimos placares.',
'lib/screens/quiz_page.dart':'Apresentação e interação ME/VF/REL.',
'lib/screens/genius_page.dart':'Sequência de áudio, relógio e pentágono do Genius.',
'lib/screens/memory_page.dart':'Pares, flip, contagem regressiva, shake e fotos.'}
def why(line,path):
 s=line.strip()
 if not s:return 'Separa visualmente blocos. Não executa uma ação.'
 if s.startswith(('//','/*','*')):return 'Comentário/documentação. Ajuda a ler o código e não é executado.'
 if path.endswith('.xml'):return 'Configuração/layout Android XML. A tag declara um elemento e os atributos configuram seu papel/aparência.'
 if path.endswith('.yaml'):return 'Configuração YAML: a indentação define os grupos e o valor à direita configura a propriedade.'
 if s.startswith(('import ','package ')):return 'Declara a origem dos símbolos usados no arquivo ou o namespace do arquivo Kotlin.'
 if s.startswith('@'):return 'Anotação sobre o membro declarado a seguir.'
 if re.match(r'(abstract )?class ',s):return 'Declara uma classe e suas relações com uma classe base/interface.'
 if s.startswith(('if ','if(','else ','} else','when ','switch ')):return 'Escolhe a próxima ação conforme uma condição/valor.'
 if s.startswith(('for ','for(')):return 'Percorre uma coleção ou intervalo e repete o corpo.'
 if s.startswith('return'):return 'Entrega esta expressão ao chamador e encerra a execução desta função.'
 if 'setState(' in s:return 'Altera o estado da tela e agenda sua reconstrução pelo Flutter.'
 if 'await ' in s:return 'Espera a conclusão da operação antes de continuar. Outros eventos da interface podem ocorrer durante a espera.'
 if re.fullmatch(r'[\s\}\]\);,]+',s):return 'Fecha blocos, listas ou chamadas abertas nas linhas anteriores. A indentação indica o contexto.'
 if re.match(r'(final|var|val|late|private val|private var)\b',s):return 'Declara/atribui uma referência ou variável. A expressão à direita mostra seu valor inicial.'
 if ':' in s:return 'Configura parte da construção em andamento: parâmetro nomeado, propriedade, mapa ou expressão condicional.'
 return 'Continuação da expressão, declaração ou chamada deste bloco. Veja os termos e as linhas vizinhas para acompanhar o fluxo completo.'
paths=[ROOT/'lib/main.dart']
paths+=sorted(p for p in (ROOT/'lib').rglob('*.dart') if p not in paths)
paths+=sorted((ROOT/'android/app/src/main/kotlin').rglob('*.kt'))
paths+=sorted((ROOT/'android/app/src/main/res').rglob('*.xml'))
paths+=[ROOT/'android/app/src/main/AndroidManifest.xml',ROOT/'pubspec.yaml',ROOT/'android/app/build.gradle.kts',ROOT/'android/settings.gradle.kts']
paths+=sorted((ROOT/'test').glob('*.dart'))+sorted((ROOT/'integration_test').glob('*.dart'))
# Índice de declarações: um nome não descrito não recebe uma definição inventada.
declarations={}
for p in paths:
 for number,line in enumerate(p.read_text(encoding='utf-8-sig').splitlines(),1):
  for name in re.findall(r'\b(?:final|var|val|class|fun)\s+(?:[A-Z]\w*(?:<[^>]+>)?\s+)?([A-Za-z_]\w*)',line):
   declarations.setdefault(name,(p.relative_to(ROOT).as_posix(),number,line.strip()))
files=[];unmapped=set()
for p in paths:
 path=p.relative_to(ROOT).as_posix();lines=[]; block_comment=False
 for n,code in enumerate(p.read_text(encoding='utf-8-sig').splitlines(),1):
  terms=[]
  stripped=code.strip()
  comment=block_comment or stripped.startswith(('//','/*','*','<!--'))
  if stripped.startswith(('/*','<!--')):block_comment=True
  if '*/' in stripped or '-->' in stripped:block_comment=False
  word_list=[] if comment else TOKEN.findall(code)
  if p.suffix=='.xml' and not comment:
   inner=re.findall(r'>([^<]+)<',code)
   word_list=TOKEN.findall(re.sub(r'>([^<]+)<','><',code))+[chr(34)+text+chr(34) for text in inner if text.strip()]
  if p.suffix=='.yaml' and ':' in code and code.split(':',1)[1].strip():
   prop,scalar=code.split(':',1)
   word_list=TOKEN.findall(prop+':')+[chr(34)+scalar.strip()+chr(34)]
  for word in dict.fromkeys(word_list):
   if word.startswith('//'):continue
   definition=LEX.get(word) or LEX.get(word.lstrip('_')) or SYMBOLS.get(word)
   if word.startswith(('"',"'")):definition='Texto literal: mensagem, caminho, chave ou nome. No Dart e no Kotlin, $nome insere um valor dentro do texto.'
   elif re.fullmatch(r'\d+(\.\d+)?|0x[\dA-Fa-f]+',word):definition='Número literal.'+(' Cor hexadecimal no formato opacidade/vermelho/verde/azul.' if word.startswith('0x') else '')
   if not definition:
    if word in declarations:
     origin=declarations[word];definition='Identificador declarado em '+origin[0]+':'+str(origin[1])+'. Declaração: '+origin[2]
    elif word.startswith(('ACTION_','EXTRA_','FLAG_','TYPE_','STREAM_','CONTENT_','NET_','SENSOR_')):
     definition='Constante Android. Nomeia o evento, dado extra, tipo ou opção indicado pelo nome e pelo serviço usado nesta linha.'
    elif word in ['arrow_back','arrow_forward','check_circle','home_outlined','grid_view_rounded','music_note_outlined','quiz_outlined','logout','settings_outlined','screen_rotation','psychology_outlined','circle']:
     definition='Nome do desenho no catálogo de ícones Material.'
    else:
     definition='Nome técnico/propriedade deste contexto. Use a busca para acompanhar os usos e a declaração. O papel geral é descrito no arquivo e nos termos relacionados.'
     if word.isidentifier():unmapped.add(word)
   terms.append([word,definition])
  lines.append({'n':n,'code':code,'why':why(code,path),'terms':terms})
 purpose=META.get(path,'Infraestrutura Android, recurso de layout ou teste automatizado. Leia o nome e o contexto da declaração.')
 files.append({'path':path,'purpose':purpose,'lines':lines})
payload=json.dumps(files,ensure_ascii=False).replace('</','<\\/')
template=(ROOT/'scripts/study_template.html').read_text(encoding='utf-8')
output=ROOT/'estudo/CODIGO_EXPLICADO.html'
output.write_text(template.replace('__SOURCE_DATA__',payload),encoding='utf-8')
(ROOT/'estudo/TERMOS_A_COMPLEMENTAR.txt').write_text('\n'.join(sorted(unmapped)),encoding='utf-8')
print(json.dumps({'arquivos':len(files),'linhas':sum(len(f['lines']) for f in files),'bytes':output.stat().st_size,'termos_genericos':len(unmapped)},ensure_ascii=False))
