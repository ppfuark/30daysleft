# Movimento sobre vias reais

A simulação usa um circuito calculado pelo serviço OSRM a partir da malha OpenStreetMap. A geometria foi salva em `data/simulacao.json`; a API percorre os segmentos consecutivos dessa geometria e repete o circuito. Não há requisição de roteamento por atualização nem necessidade de internet para reproduzir o cenário já salvo.

O circuito fornecido tem 889,6 metros, 19 coordenadas e inclui a origem, passagem perto dos dois ecopontos e retorno à origem pelas vias. A 18 km/h, uma volta dura aproximadamente três minutos, sem paradas. A duração de 142,4 segundos registrada pelo provedor é uma estimativa distinta e não controla a velocidade simulada.

As vias retornadas pelo serviço foram:

- Rua Osvaldo Lelis;
- João da Costa Vieira;
- Rua Durval de Carvalho e Silva;
- Rua Doutor Luiz Miranda;
- Rua Julio da Costa Barros;
- Rua Senador Rodolfo Miranda.

Os nomes acima vêm da resposta do provedor. Eles não coincidem com os nomes cadastrados em `pontos.json`, como R. Japão. Foram priorizadas as **coordenadas fornecidas** para gerar a rota. No snapshot simulado, `itinerario_ruas` contém as vias efetivas e `itinerario_ruas_cadastrado` conserva os nomes da fonte. O arquivo original e os endereços dos ecopontos não foram alterados. Para demonstrar um itinerário que obrigatoriamente passe pelas ruas cadastradas, será necessário corrigir/confirmar as coordenadas de passagem dessas ruas.

## Ajuste dos pontos à via

O serviço associa cada coordenada à via roteável mais próxima. No cenário incluído:

| Referência | Ajuste informado pelo provedor |
| --- | --- |
| Origem/retorno | 41,6 m |
| Ecoponto 34 | 18,3 m |
| Ecoponto 31 | 16,4 m |

O caminhão começa na coordenada ajustada. Não é criado um segmento em linha reta entre a coordenada original e a rua. O gerador limita ajustes a 200 metros e rejeita geometria aberta em vez de inventar uma ligação de retorno. O campo `roteamento.waypoints` permite conferir as coordenadas solicitadas, as ajustadas e a distância de ajuste.

## Recalcular

```powershell
npm run route:generate
```

O comando lê a frota e os ecopontos de `PONTOS_PATH` ou `data/pontos.json`, consulta o serviço para cada caminhão presente no cenário e substitui `SIMULACAO_PATH` ou `data/simulacao.json` somente depois de receber e validar todos os resultados. Os pontos de passagem são a posição original do caminhão, os ecopontos na ordem do arquivo e a origem novamente. São suportados de 1 a 23 ecopontos por circuito nesse gerador demonstrativo.

Se o serviço falhar, não houver rota, a geometria for aberta ou o ajuste superar o limite, o cenário existente permanece. Depois de gerar, reinicie a API para carregar o arquivo. O serviço público pode estar indisponível; `OSRM_URL` permite indicar uma instância própria compatível. Não é preciso instalar pacotes adicionais nem configurar chave para usar o endpoint público incluído.

## Limites da demonstração

`simulation` permanece `true`: não existe GPS de caminhão real conectado. A geometria é viária; velocidade constante, ocupações e categorias continuam demonstrativas. O perfil `driving` é de automóvel e não certifica altura, peso ou permissões específicas de um caminhão de coleta. O circuito não é uma rota oficial da prefeitura. A previsão de chegada da API ainda é uma aproximação pela distância direta, identificada como simulada.

Dados cartográficos: [© OpenStreetMap contributors](https://www.openstreetmap.org/copyright). O aplicativo que exibir a rota deve manter a atribuição dos dados. Referência técnica: [serviço Route do OSRM](https://project-osrm.org/docs/v5.24.0/api/#route-service), com `geometries=geojson` e `overview=full`.
