# API WebSocket do Recicla+

API para os dados em tempo real das telas 3 (coleta comum) e 4 (coleta seletiva). O aplicativo pode continuar lendo seus arquivos JSON e XML e salvando rua, filtro e score localmente. A análise da prova e das diferenças entre os anexos está em [docs/analise-requisitos.md](docs/analise-requisitos.md).

A API está implementada em Node.js com WebSocket padrão, usando `ws`. Não usa Socket.IO. Os arquivos originais não são modificados. O projeto inclui uma cópia **somente da frota e dos ecopontos** do JSON recebido, sem os usuários e PINs.

## Executar

Requisito: Node.js 22.13 ou superior.

```powershell
cd C:\Users\crisbrandao\Downloads\D\D\WebSocket
npm ci --ignore-scripts
npm start
```

WebSocket: `ws://127.0.0.1:8080/ws`. Verificação de funcionamento: `http://127.0.0.1:8080/health`.

Em outro terminal, na mesma pasta:

```powershell
npm run demo
```

O cliente acompanha ambos os canais e imprime os eventos. Encerre com `Ctrl+C`. Para rodar os testes de integração:

```powershell
npm test
```

## Simulação e arquivos originais

Por padrão, `data/pontos.json` fornece os dados cadastrados e `data/simulacao.json` fornece uma **geometria de vias reais obtida por OSRM/OpenStreetMap**. O circuito incluído tem 889,6 metros e 19 coordenadas. A cada 2 segundos o caminhão avança aproximadamente 10 metros sobre essa geometria. Velocidade de 18 km/h, categorias e ciclos de ocupação continuam simulados. O ponto 34 ultrapassa 90% para testar a animação de alerta.

A rota está salva no arquivo: `npm start` e `npm run demo` não consultam o serviço externo. Para recalcular, com internet:

```powershell
npm run route:generate
```

Depois, reinicie a API. O gerador liga a origem aos ecopontos na ordem do JSON e inclui o retorno pelas vias. A origem é ajustada para a via mais próxima; no cenário fornecido, o maior ajuste é 41,6 metros. Não é um itinerário oficial de coleta, e o perfil de automóvel não valida restrições específicas de caminhões. Detalhes em [docs/rotas-reais.md](docs/rotas-reais.md).

As coordenadas dos anexos correspondem a vias diferentes dos nomes cadastrados. No cenário roteado, o filtro de logradouro usa as vias efetivas do percurso, como `Rua Osvaldo Lelis`; os nomes originais ficam em `itinerario_ruas_cadastrado`. Os endereços dos ecopontos continuam iguais aos enviados.

Para consumir diretamente o JSON enviado, com alterações feitas por um simulador externo ou editor:

```powershell
$env:PONTOS_PATH = '..\JSON\pontos.json'
$env:SIMULATION = 'false'
npm start
```

Nesse modo, a API não inventa movimento: observa o arquivo a cada segundo e publica as novas posições/ocupações. Um arquivo estático produz um estado estático. Um JSON inválido mantém o último estado válido e gera aviso no terminal; a API volta a publicar quando o arquivo é corrigido. Alterações no arquivo de simulação exigem reinício da API.

O JSON original não informa os tipos de resíduo atendidos pelo caminhão. Sem simulação, o campo público `tipos_residuo` será `[]` e um filtro por tipo não encontrará esse caminhão. Para oferecer esse filtro com dados reais, acrescente ao caminhão uma lista `"tipos_residuo": ["Orgânico", "Rejeitos"]` na sua fonte de dados. Não é necessário alterar outros campos. Se usar uma base com outros IDs no modo simulado, adapte também as referências em `data/simulacao.json`.

Para voltar ao exemplo padrão, em uma nova execução:

```powershell
Remove-Item Env:PONTOS_PATH -ErrorAction SilentlyContinue
Remove-Item Env:SIMULATION -ErrorAction SilentlyContinue
npm start
```

| Variável | Padrão | Uso |
| --- | --- | --- |
| `HOST` | `127.0.0.1` | Interface de rede |
| `PORT` | `8080` | Porta HTTP e WebSocket |
| `PONTOS_PATH` | `data/pontos.json` | Fonte da frota e dos ecopontos |
| `SIMULACAO_PATH` | `data/simulacao.json` | Geometria viária e parâmetros simulados |
| `SIMULATION` | `true` | `false` para publicar somente alterações da fonte |
| `TICK_MS` | `2000` | Intervalo de atualização simulada, de 100 a 60000 ms |
| `WATCH_MS` | `1000` | Intervalo de leitura da fonte, de 100 a 60000 ms |
| `OSRM_URL` | `https://router.project-osrm.org` | Usada somente por `npm run route:generate`; aceita um servidor OSRM próprio |

Os caminhos informados por variável são relativos à pasta em que o comando é executado; os padrões são relativos ao projeto. As variáveis são lidas do ambiente; não há carregamento automático de `.env`.

## Flutter e emulador Android

Para o emulador acessar a API no computador:

```powershell
$env:HOST = '0.0.0.0'
npm start
```

Use `ws://10.0.2.2:8080/ws` no emulador Android padrão. Em um aparelho físico, use o IP do computador na mesma rede. `0.0.0.0` é o endereço de escuta do servidor; use o IP do computador na URL do cliente.

Há um [cliente Dart reutilizável](examples/coleta_socket.dart) com reconexão, reassinatura e manutenção do último snapshot. As [instruções do exemplo](examples/README.md) explicam conexão, aviso offline e persistência no app.

## Ranking da Gamificação

O ranking da Gamificação pode ser gerado separadamente em `../JSON/ranking.json`, a partir de `../JSON/usuarios.json`:

```powershell
npm run ranking:generate
```

Cada entrada contém somente `usuario_id`, `nome` e `score`. O vínculo é `ranking.usuario_id = usuarios.id`, e o score vem de `score_persistente`. O arquivo preserva a ordem dos usuários na fonte, sem classificação pré-calculada. O programador deve implementar a ordenação, o critério de desempate, o cálculo das posições e o destaque dos sete primeiros. PINs e histórico de coletas não entram no ranking.

O comando gera um retrato dos scores atuais e deve ser executado novamente quando eles mudarem. Durante a gameplay, o aplicativo deve recalcular e salvar a classificação a cada alteração de score para atender à atualização em tempo real prevista na prova. `USUARIOS_PATH` configura a fonte; `RANKING_PATH` configura a saída. Por padrão, a saída fica ao lado do arquivo de usuários. `usuarios.json` permanece como a fonte das pontuações. Os tópicos WebSocket descritos a seguir continuam dedicados aos dados de coleta.

## Protocolo

Todas as mensagens são objetos JSON de texto. Após conectar, o servidor envia `connected` com a versão `1.0` e os dois tópicos disponíveis. Cada conexão pode manter uma assinatura por tópico. Enviar outro `subscribe` para o mesmo tópico substitui seus filtros e localização, sem afetar o outro tópico nem os outros clientes.

### Tela 3

```json
{
  "type": "subscribe",
  "requestId": "tela3-1",
  "topic": "coleta_comum",
  "filters": {
    "logradouro": "Rua Osvaldo Lelis",
    "turno": "Tarde",
    "tipo_residuo": "Orgânico"
  },
  "location": { "lat": -22.1085, "lng": -50.1742 },
  "notifyArrival": true
}
```

Filtros opcionais: `logradouro` (parte do nome da rua), `turno` (`Manhã`, `Tarde`, `Noite`) e `tipo_residuo` (`Orgânico`, `Rejeitos`, `Outros`). Busca e filtros ignoram diferenças de maiúsculas/minúsculas e acentuação. Os filtros são combinados por E.

O servidor envia um `snapshot` imediato; mudanças posteriores chegam como `update`. Ambos contêm `topic`, `revision`, `timestamp` ISO 8601 UTC, `simulation` e `data`:

```json
{
  "caminhoes": [{
    "caminhao_id": "CAM-01",
    "motorista": "Carlos Silva",
    "turno": "Tarde",
    "posicao_atual": { "lat": -22.107349, "lng": -50.173148 },
    "itinerario_ruas": ["Rua Osvaldo Lelis", "João da Costa Vieira", "Rua Durval de Carvalho e Silva", "Rua Doutor Luiz Miranda", "Rua Julio da Costa Barros", "Rua Senador Rodolfo Miranda"],
    "itinerario_ruas_cadastrado": ["R. Japão", "R. Manoel Rafael da Cruz", "R. Eng. Freire", "R. Joaquim de Almeida Pina"],
    "tipos_residuo": ["Orgânico", "Rejeitos", "Outros"],
    "velocidade_kmh": 18,
    "percurso_simulado": [{ "lat": -22.107349, "lng": -50.173148 }, { "lat": -22.107363, "lng": -50.173122 }],
    "distancia_metros": 208,
    "previsao_chegada": "2026-10-19T15:00:42.000Z",
    "previsao_simulada": true
  }],
  "mensagem": null
}
```

Esse trecho ilustra os campos principais e abrevia o percurso; a resposta contém todas as 19 coordenadas. O campo adicional `roteamento` traz provedor, perfil, vias, distância, duração calculada pelo provedor, pontos solicitados/ajustados e atribuição OpenStreetMap. Com localização, a distância usa Haversine. Mesmo com movimento pelas vias, `previsao_chegada` continua sendo uma aproximação em linha reta com velocidade configurada, e `previsao_simulada` é `true`. A previsão não considera ruas, paradas, trânsito, horários ou feriados. Sem simulação ou sem localização, a previsão é `null`. Converta o horário UTC para `America/Sao_Paulo` ao exibir no aplicativo.

Se nenhum caminhão atender aos filtros, `caminhoes` será `[]` e `mensagem` será exatamente `Nenhum caminhão em rota para este endereço`.

Com `notifyArrival: true` e `location`, ao encontrar um caminhão filtrado a **menos de 200 metros**, o servidor envia:

```json
{
  "type": "arrival_alert",
  "topic": "coleta_comum",
  "timestamp": "2026-10-19T15:00:00.000Z",
  "data": { "caminhao_id": "CAM-01", "distancia_metros": 180, "limite_metros": 200 }
}
```

O aplicativo toca o áudio ao receber o evento. O alerta sai uma vez por aproximação; é rearmado quando o caminhão sai da área. Se já estiver próximo ao assinar, o alerta sai após o snapshot. A comparação usa a distância exata, antes do arredondamento exibido. Atualize a assinatura quando a localização do usuário mudar. Uma conexão nova inicia um novo ciclo de alertas.

### Tela 4

```json
{
  "type": "subscribe",
  "requestId": "tela4-1",
  "topic": "coleta_seletiva",
  "filters": { "material": "Plástico", "busca": "Japão" },
  "location": { "lat": -22.109, "lng": -50.175 }
}
```

`material` é opcional e aceita `Metal`, `Plástico`, `Papel` ou `Vidro`. `busca` consulta parte do endereço ou do nome `Ponto de coleta - 34`. O snapshot/update contém:

- `data.pontos`: pontos filtrados com `id`, `logradouro`, `material`, `nivel_ocupacao`, `coordenadas`, `ocupacao_critica` e `distancia_metros`;
- `data.ponto_mais_proximo`: ponto mais próximo entre os que passaram pelos filtros; `null` sem localização ou sem resultados;
- `data.destino_rota`: `{ponto_id, origem, destino}`, para o aplicativo solicitar/traçar a rota com seu provedor de mapas. Não representa um caminho calculado sobre ruas.

`ocupacao_critica` é `true` somente para ocupação **maior que 90%**, conforme a prova. O app usa esse campo para pulsar o marcador. Sem localização, as distâncias são `null`.

### Controle e erros

```json
{ "type": "unsubscribe", "requestId": "sair", "topic": "coleta_comum" }
```

Retorna `unsubscribed` e interrompe os eventos desse tópico.

```json
{ "type": "ping", "requestId": "heartbeat-1" }
```

Retorna `pong`. Além disso, há ping/pong nativo WebSocket a cada 30 segundos para detectar conexões perdidas.

Erros de comando retornam `{"type":"error","code":"INVALID_MESSAGE","message":"..."}` com `requestId`, se válido, sem derrubar a conexão. Limites: mensagens de 16 KiB, 60 comandos por segundo por conexão e fila de saída de 1 MiB. Excesso de tamanho/frequência ou cliente que não acompanha o fluxo pode encerrar a conexão.

## Responsabilidade do aplicativo

O app faz interpolação visual dos marcadores, mapa/zoom/gestos, áudio, voz, permissões de localização/câmera, leitura de QR, PIN, bloqueio de captura, minigame e exibição das mensagens por pelo menos 5 segundos. Também salva localmente score, último filtro, última rua e último estado recebido. Ao perder conexão, mantém os marcadores no último estado e mostra a faixa vermelha; ao reconectar, reassina os tópicos e recebe snapshots atuais.

Gamificação não grava score pela API: a prova exige persistência local. O app deve salvar o horário dos descartes aceitos para impedir duplicações no mesmo minuto, inclusive após reiniciar. Nenhum comando desta API permite alterar pontos do usuário, validar PIN ou obter dados de autenticação.

O serviço foi preparado para simulação local da prova. Para disponibilização pública, configure autenticação e TLS (`wss://`) no serviço/reverse proxy. A API não lê nem publica o XML ambiental.

## Estrutura

```text
src/index.js           Inicialização e variáveis de ambiente
src/server.js          HTTP, WebSocket, conexões e heartbeat
src/protocol.js        Contrato, validação, filtros e alertas
src/data-store.js      Fonte JSON, simulação e recarga
src/geo.js             Distância e interpolação geográfica
src/route-generator.js Consulta OSRM e validação da geometria viária
src/ranking.js         Dados dos usuários para calcular a classificação no aplicativo
scripts/gerar-rota.js   Geração e gravação atômica do circuito
scripts/gerar-ranking.js Geração de JSON/ranking.json a partir dos usuários
data/pontos.json       Cópia da frota e ecopontos recebidos
data/simulacao.json    Geometria viária e parâmetros de simulação
examples/             Cliente de terminal e cliente Dart
test/api.test.js      Testes de integração com conexões reais
docs/                 Análise dos requisitos e anexos
```

Referências de implementação: [documentação oficial do ws](https://github.com/websockets/ws/blob/master/doc/ws.md), [WebSocket do Node.js 22](https://nodejs.org/download/release/v22.15.0/docs/api/globals.html#websocket) e [serviço Route do OSRM](https://project-osrm.org/docs/v5.24.0/api/#route-service).
