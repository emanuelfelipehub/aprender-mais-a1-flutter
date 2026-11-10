# Decisões verificáveis

1. **Questão 501:** o JSON original foi copiado sem modificação. O gabarito fornecido inclui o índice 3 para uma lista de três conceitos. O aluno autorizou corrigir a leitura para Sprint → período de desenvolvimento; Product Backlog → lista priorizada; Daily Scrum → reunião diária. A correção está em Question.matchingAnswer.
2. **Outros gabaritos:** foram preservados como estão no JSON, inclusive perguntas cuja redação pode gerar discussão. O app não inventa um novo gabarito.
3. **Relacione:** o botão se chama Avançar, seguindo o requisito funcional. A lista de componentes também menciona Próximo; essa divergência consta no próprio PDF.
4. **Pontuação do quiz:** pergunta correta soma o peso inteiro uma única vez. Relacione só conta como correta quando todos os pares estão corretos. Encerrar contabiliza a pergunta atual se já houver resposta completa, mostra o total e volta à Home.
5. **Memória:** quatro pares significam pontuação de 0 a 4. O widget guarda os acertos da última partida; o placar na tela volta a zero depois do resultado. A tela usa paisagem, de acordo com o wireframe do MemoCheck.
6. **Genius:** uma nova sequência aleatória é sorteada por rodada, com tamanho igual ao nível. Cada rodada correta vale um ponto; o nível é score ~/ 2 + 1. Stop guarda o último resultado e zera a tela; voltar de uma tela já parada não sobrescreve esse resultado.
7. **Idioma inicial:** Português, Inglês ou Espanhol conforme o idioma do sistema. Outros idiomas usam Português. O seletor fica bloqueado durante uma partida para evitar trocar de idioma no meio da fala.
8. **Alerta de bateria:** uma vez por execução do app, ao iniciar ou ao receber atualização com bateria <=20%. Fechar o alerta evita repetições na mesma execução.
9. **Fone com fio:** o Android possui passos discretos de volume. É escolhido o passo inteiro mais próximo de 50% do volume de mídia; não se altera o volume de chamadas ou alarmes.
10. **Fotos:** o seletor Android dá acesso somente às imagens escolhidas. É necessário selecionar exatamente quatro; cancelar preserva o tema anterior. As cópias ficam no cache privado e não são enviadas a nenhum servidor.
11. **Widget externo:** é um AppWidgetProvider Android, com três cartões e as últimas pontuações em SharedPreferences privadas. Pode ser adicionado pelo launcher; tocar nele abre o app.
12. **Implementação nativa:** a interface e as regras são Dart/Flutter. Uma ponte Kotlin usa APIs padrão do Android para recursos do aparelho e o widget. Não há dependência de serviço pago ou de pacote externo em execução.
13. **Ambiente:** desenvolvido com Flutter 3.47.5, Dart 3.13.4 e emulador Android API 37. O material de exemplo cita Flutter 3.32.6 e Pixel 9/API 35. A compilação no ambiente exato do PDF não foi alegada.
14. **Assinatura e Git:** APK de treino assinado com a chave debug. Nenhum Git remoto foi publicado.

