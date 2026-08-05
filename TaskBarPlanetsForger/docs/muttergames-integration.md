# Integração com MutterGames

## Limites arquiteturais

A integração é um adaptador externo atrás de `MutterGamesPort`. O domínio recebe somente capacidades normalizadas: identidade de exibição, catálogo e entitlements. Se a plataforma estiver indisponível, o adaptador retorna estado degradado e o jogo continua offline.

| Capacidade futura | Uso permitido | Estado |
|---|---|---|
| Perfil | Mostrar nome/avatares opcionais | [PENDENTE] |
| Biblioteca | Abrir página do jogo e descoberta cruzada | [PENDENTE] |
| Entitlements | Desbloquear cosméticos não competitivos | [PENDENTE] |
| Cloud save | Nunca sobrescrever local sem resolução explícita | [FORA DO ESCOPO do MVP] |

## Segurança e privacidade

Validar emissor, audiência, expiração e escopos do token. Guardar apenas identificador pseudônimo quando estritamente necessário. Documentar cada dado transmitido e disponibilizar desconexão/remoção local.

## Critérios para habilitar

Contrato versionado, ambiente sandbox, testes de revogação, UX de consentimento, política de incidentes e revisão de segurança concluídos.
