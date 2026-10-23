# Análise da prova e dos arquivos

É possível manter os arquivos JSON e XML separados e acrescentar WebSocket apenas aos dados dinâmicos das telas 3 e 4. Isso preserva a arquitetura híbrida e a persistência local solicitadas pela prova. WebSocket é uma escolha para distribuir atualizações: o texto da prova não exige esse protocolo nominalmente; pede coordenadas/ocupação em tempo real a partir de arquivos e um endpoint simulado.

Foram analisados `D1_Coleta_Revisado.docx`, `JSON/pontos.json` e `XML/config.xml` fornecidos junto ao pedido. As instruções de nomear APK, publicar no Git e organizar a entrega são regras para o participante da prova; não foram tratadas como autorização para alterar outros projetos ou publicar arquivos.

## Divisão recomendada

| Dados ou comportamento | Onde ficam | Motivo |
| --- | --- | --- |
| Coordenadas iniciais, endereços e ocupação inicial | `pontos.json` | Fonte expressamente prevista no enunciado |
| Posição atualizada dos caminhões e ocupação atualizada | API WebSocket, lendo JSON | Atualização contínua para as telas 3 e 4 |
| Categorias, gamificação, horários e feriados | Arquivo(s) XML de configuração | Requisito da prova, mas ausente no XML recebido |
| Relatório de impacto ambiental | XML de relatório | Exportação independente da transmissão em tempo real |
| Score, última rua, último material e histórico antirrepetição | Armazenamento local do app | Devem sobreviver ao fechamento do aplicativo |
| Áudio, gestos, PIN, câmera, QR e avisos | App | Dependem da interface e dos recursos do dispositivo |

O aplicativo pode usar a semente local para abrir offline e substituir os dados exibidos pelos snapshots recebidos. O JSON não precisa ser transmitido inteiro pelo socket: a API publica somente os campos da frota e dos ecopontos, filtrados por assinatura.

## Conteúdo recebido

O JSON é válido e contém parâmetros de sistema, mensagens, um usuário, um caminhão e dois pontos de coleta. O caminhão tem posição atual, turno e uma lista textual de quatro ruas; não há geometria geográfica do percurso, velocidade, categorias de resíduo, timestamp nem fluxo de atualizações. Os pontos são 34 (Plástico, 85%) e 31 (Papel, 30%).

O XML também é válido, mas sua raiz é `relatorio_impacto_ambiental`: ele tem metadados, pesos coletados, pontos gerados e indicadores ambientais. A soma dos materiais é 450,25 kg e coincide com o total reciclado informado. Ele não é a configuração que o enunciado descreve. O score do usuário e o total de pontos do relatório têm escopos distintos; não foram igualados.

## Lacunas e ambiguidades da prova

1. **XML incompatível com o nome/uso esperado:** `config.xml` contém relatório, enquanto a prova pede parâmetros de gamificação, categorias, horários e feriados. Para cumprir esses itens no aplicativo, será necessário fornecer XML de configuração com valores definidos. Não há base nos anexos para inferir esses valores.
2. **Outros nomes de arquivo:** o enunciado também cita `game_config.xml` e `dados.json`, que não foram enviados. Para o PIN, a tela de login já permite o `pontos.json`, que contém o usuário de exemplo. A prova precisa padronizar os nomes se exigir leitura literal dos arquivos.
3. **Duas descrições da tela 4:** uma descreve busca/lista/mapa e outra acrescenta ocupação e gamificação. A API atende o conjunto dos dados de mapa/ocupação das duas descrições. A implementação do aplicativo continua responsável pelas interações e pelo score.
4. **Tempo real a partir de arquivo:** sem alguém atualizar o arquivo, a fonte permanece estática. O cenário separado resolve essa necessidade durante a demonstração; desligar a simulação permite que um produtor externo atualize o JSON.
5. **Rota e previsão:** a lista de ruas não permite calcular um caminho viário nem uma previsão de chegada real. O cenário agora contém geometria viária gerada por OSRM/OpenStreetMap, a partir das coordenadas enviadas. As vias retornadas são diferentes dos nomes cadastrados; os dois conjuntos ficam identificados separadamente. A previsão demonstrativa ainda usa linha reta e velocidade, sem horários, feriados ou trânsito.
6. **Lixeiras públicas de coleta comum:** não há esse conjunto de dados no JSON. Os ecopontos seletivos não foram reclassificados como lixeiras públicas comuns.
7. **Metadados visuais:** foto, imagem, descrição longa e QR dos pontos não estão no JSON. O app precisa associá-los aos recursos de mídia citados na prova ou receber um cadastro complementar.
8. **Mensagens de login divergentes:** a descrição da tela e os casos de teste usam textos diferentes. O caso automatizado e o JSON usam `Dados de acesso inválidos`; a interface deve padronizar esse texto antes da avaliação.
9. **Quantidade de testes:** a tabela fornecida enumera 13 passos, mas a pontuação menciona 50. A API inclui testes de integração próprios; eles não equivalem aos testes E2E Flutter da prova.

## Cobertura da API desenvolvida

| Item | Entrega |
| --- | --- |
| Posição do caminhão em tempo real | Snapshot inicial, updates simulados ou recarga da fonte |
| Logradouro e turno | Filtros por assinatura |
| Tipo de resíduo do caminhão | Filtro; cenário complementa esse dado ausente na semente |
| Distância e chegada a menos de 200 m | Haversine e evento opt-in `arrival_alert` |
| Previsão Datetime | Estimativa explicitamente simulada; `null` com fonte real sem dados suficientes |
| Endereços, materiais e coordenadas seletivos | Dados originais publicados sem usuários/PINs |
| Busca e ponto mais próximo | Filtros e destino para o provedor de mapas do app |
| Ocupação e aviso acima de 90% | Atualizações e campo `ocupacao_critica` |
| Queda e retorno da conexão | Snapshots ao reassinar; exemplo Dart conserva o último estado e reconecta |
| Persistência de score e preferências | Mantida como responsabilidade local do app |
| Configuração e relatório XML | Independentes da API; anexo preservado |

## Dados simulados

`data/pontos.json` replica apenas os valores de frota e ecopontos recebidos. `data/simulacao.json` contém um circuito demonstrativo com geometria de vias reais obtida por OSRM/OpenStreetMap, velocidade de 18 km/h, categorias e ciclos de ocupação simulados. A geometria não representa um itinerário oficial de coleta. Os pontos iniciais foram ajustados à malha viária sem alterar a fonte original. O campo `simulation` continua verdadeiro nos snapshots/updates: a posição é sintética, embora siga ruas. O campo `previsao_simulada` acompanha cada caminhão. Veja [as informações da rota](rotas-reais.md).

Nenhum arquivo enviado pelo usuário foi editado. A API permite apontar `PONTOS_PATH` para o original e não inclui escrita na fonte, autenticação de usuários, descarte remoto ou saldo de pontos compartilhado.
