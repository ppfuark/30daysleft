# API VaptFood A1

## Atualização para A1 VaptFood rev1

A revisão acrescenta `available` (booleano) a todos os produtos, inclusive ao abrir bases existentes. Produtos indisponíveis não podem ser adicionados ao carrinho. A busca `q` ou `search` considera nome, descrição e palavras-chave (`keywords`, quando cadastradas), em conjunto com o filtro de categoria. O debounce pertence ao aplicativo.

`GET /orders/:id`, `GET /orders/:id/tracking` e `GET /tracking?orderId=:id` agora fornecem os itens, subtotal, desconto, taxa, total, entregador, coordenadas, previsão em `estimatedMin`/`estimatedMax` e `updatedAt`. A timeline mantém `completed` para compatibilidade e acrescenta `state` (`completed`, `current`, `pending`) e `current`, distinguindo a etapa atual. Use `state` para os indicadores da versão revisada. Novos pedidos simulam movimento gradual e redução da previsão até chegar a zero ao concluir a entrega.

Em bases novas, o pedido demonstrativo 8821 começa em “Saiu para Entrega”, conforme a tela revisada. Bases existentes conservam seu status. `GET /support` fornece orientações de acompanhamento; `channels` está vazio porque nenhum canal oficial foi fornecido. O telefone do entregador vem com `contactAuthorized: true` no cenário simulado. As mensagens de conectividade, retenção dos últimos dados, gestos e apresentação de estados vazios são implementadas no aplicativo.

**Divergência da prova:** o exemplo visual cita R$ 28,70. Os dados fornecidos resultam em R$ 55,50 − R$ 27,75 + R$ 1,00 = R$ 28,75. A API conserva R$ 28,75 e a regra financeira explícita na revisão. Os nomes e preços ilustrativos do catálogo também diferem do db.json; o catálogo conserva os dados fornecidos, sem substituir os produtos por exemplos visuais.

API para fornecer os dados e operações exigidos pela prova A1. Requer Node.js 22 ou superior. Não requer npm install nem banco externo.

## Executar

Abra um terminal nesta pasta e execute:

```powershell
npm start
```

No computador: `http://localhost:3000`. No emulador Android: `http://10.0.2.2:3000`. Em aparelho físico, use o IP do computador na mesma rede. O aplicativo Android precisa de permissão INTERNET e configuração para permitir HTTP local.

Login: `usuario@email.com`, senha `123456`.

```http
POST /auth/login
Content-Type: application/json

{"email":"usuario@email.com","password":"123456"}
```

A resposta contém `token`, `expiresIn` e `user`. Envie `Authorization: Bearer SEU_TOKEN` nas demais requisições. `/health`, login, recuperação e imagens são públicos. Todas as rotas também aceitam prefixo `/api`.

## Rotas

| Método | Rota | Uso e corpo JSON |
|---|---|---|
| GET | /health | Estado da API |
| POST | /auth/login | `{ "email": "usuario@email.com", "password": "123456" }` |
| POST | /auth/forgot-password | `{ "email": "usuario@email.com" }` |
| GET | /profile | Perfil sem senha |
| GET | /categories | Categorias |
| GET | /promotions | Promoções |
| GET | /restaurants | Filtros opcionais `?categoryId=1&q=Burger` |
| GET | /products | Filtros `?category=Hamburguers`, `?restaurantId=1`, `?featured=true`, `?q=burger` |
| GET | /products/102 | Produto com descrição e bebidas disponíveis |
| GET | /cart | Lista dos itens do usuário |
| GET | /cart/summary | Subtotal, desconto, taxa, total e talheres |
| POST | /cart | `{ "productId": 102, "quantity": 1, "drinkId": 1 }`; bebida opcional |
| PUT ou PATCH | /cart/1 | `{ "quantity": 2 }` |
| DELETE | /cart/1 | Remove item |
| PUT | /cart/preferences | `{ "cutlery": true }` |
| POST | /orders | `{ "cutlery": true }`; usa carrinho atual, salva pedido e esvazia carrinho |
| GET | /orders | Pedidos do usuário |
| GET | /orders/8821 | Itens e status do pedido |
| GET | /recentOrders | Histórico demonstrativo com itens para recompra |
| POST | /orders/1001/reorder | `{}`; adiciona itens ao carrinho aos preços atuais |
| GET | /orders/8821/tracking | Entregador, coordenadas e timeline |
| GET | /tracking | Informe `?orderId=8821` ou cabeçalho `X-Order-Id: 8821` |
| GET | /notifications | Estado `{ "active": true }` |
| PUT | /notifications | `{ "active": false }` |
| POST | /auth/logout | Orientação de encerramento local da sessão |
| GET | /media/avatar.png | Imagens fornecidas nos materiais |

Aliases: `/login`, `/forgotPassword`, `/users/me`, `/users/me/notifications`, `/productDetails/102`, `/cartSummary`, `/cart/items`, `/cart/items/1`.

GET de listas retorna um array diretamente. Detalhes e perfil retornam um objeto. Adição ao carrinho retorna `{message,item,summary}`; alteração e remoção retornam `{items,summary}`. Erros retornam `{success:false,message}` com HTTP 400 (JSON), 401 (sessão), 404 (ausência), 413 (corpo muito grande) ou 422 (validação). Criações retornam 201.

As imagens são caminhos relativos: monte a URL como `BASE_URL + '/media/' + image`. Os ícones de categorias usam o campo `icon`.

## Regras da base de demonstração

Os cálculos são feitos no servidor a partir dos preços cadastrados. Uma bebida pode ser escolhida por produto; o valor unitário soma produto e bebida, multiplicado pela quantidade. O mesmo produto com a mesma bebida incrementa o item existente. Quantidades aceitas: inteiros entre 1 e 999. A recompra preserva a quantidade e usa preços atuais.

Para reproduzir o resumo fornecido (R$ 55,50 de subtotal e R$ 28,75 de total), a demonstração aplica 50% de desconto e taxa fixa de R$ 1,00 em carrinhos não vazios. O enunciado não define a elegibilidade do cupom nem restrição de restaurantes por carrinho; a API permite itens de vários restaurantes. Esses critérios são decisões de demonstração.

Novos pedidos têm status simulado: Preparando, Saiu para Entrega após 15 segundos e Entregue após 30 segundos. Consulte o rastreamento a cada 3 segundos para testar polling. O pedido demonstrativo 8821 mantém seu status fixo; em bases novas, começa em Saiu para Entrega. Não existe integração de mapas ou GPS real. A recuperação de senha simula sucesso para e-mail cadastrado; nenhum e-mail é enviado. Biometria, gestos, conectividade, animações e remoção do token no logout são responsabilidades do aplicativo.

O JSON original tinha uma vírgula final inválida em notifications e referenciava o produto 301 sem cadastrá-lo. A cópia foi corrigida e o produto Batata Frita foi acrescentado. Os históricos 1001 e 1002 receberam itens demonstrativos para viabilizar recompra, pois a origem não continha seus itens. Os arquivos originais foram preservados.

## Persistência e testes

Os dados de trabalho são gravados atomicamente em `data/db.json` após alterações. Para restaurar a base, pare o servidor e exclua apenas esse arquivo; a próxima execução usa `data/seed.json`. A senha é convertida para hash scrypt na inicialização. O seed mantém a credencial pública da prova.

```powershell
npm test
```

Configurações opcionais: `PORT` (3000), `HOST` (0.0.0.0), `DB_FILE` e `JWT_SECRET`. Para preservar tokens após reiniciar, defina um JWT_SECRET fixo e privado. Sem configuração, uma chave aleatória é gerada por processo. Tokens HS256 expiram em 24 horas; o logout remove a sessão no aplicativo, sem revogação no servidor.

Esta API foi preparada para execução local da prova, em um único processo. O enunciado não especifica um contrato de endpoints; o contrato adotado está documentado acima.

