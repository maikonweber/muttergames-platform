# Planejamento de marketplace

> [FORA DO ESCOPO do MVP] O marketplace não é requisito para o loop do jogo e não deve criar dependência econômica ou técnica antes da validação do produto.

## Objetivo posterior

Permitir descoberta e aquisição de cosméticos opcionais, como paletas de planetas, trilhas, molduras da janela e efeitos visuais. Sem itens que alterem produção, prestígio ou competitividade.

## Modelo de integração

1. O jogo consulta catálogo assinado/versionado da MutterGames.
2. O jogador inicia qualquer compra no ambiente oficial da plataforma.
3. Após confirmação, o jogo consulta entitlement e aplica apenas conteúdo local permitido.
4. Falhas ou indisponibilidade mantêm cosméticos padrão; não bloqueiam saves.

## Requisitos futuros

- Catálogo com SKU, versão, preço exibido pela plataforma, elegibilidade e integridade.
- Entitlement verificável no servidor/plataforma; cache local com expiração curta.
- Registro de aplicação de item idempotente e reversível.
- Política de reembolso e remoção de conteúdo definida pela MutterGames.

[RISCO] Evitar economia pay-to-win, dependência de blockchain e compra dentro de fluxo crítico. Revisar legislação e classificação indicativa antes de habilitar compras.
