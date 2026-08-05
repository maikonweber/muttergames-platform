# Roadmap de implementação — do protótipo ao lançamento

## Estado atual

| Marco | Estado | Evidência |
|---|---|---|
| Núcleo idle | Concluído | `GameState`, inventário, planetas, offline e prestígio. |
| Janela desktop | Concluído com validação pendente | compacto/expandido, bandeja, âncora e configurações. |
| UI base | Em andamento | tema, cartões de recurso e referência visual aplicados. |
| Arte procedural | Em andamento | geração de planetas e VFX existentes; cobertura de arquétipos pendente. |
| Qualidade | Em andamento | estratégia definida; automação de testes deve crescer. |

## Próximo incremento: vertical slice

### VS-01 — leitura do sistema

- **Código:** mapa orbital com seleção de planeta, cartões de órbita e inspector contextual.
- **Design:** miniaturas procedurais para Rochoso, Oceânico e Vulcânico; barras de atmosfera, água e habitabilidade.
- **Aceite:** é possível identificar, em até cinco segundos, a órbita livre, o próximo bloqueio e a ação possível.

**Progresso:** seleção por órbita, inspetor contextual, mapa orbital clicável, miniaturas procedurais determinísticas e valores/barras de Atmosfera e Água estão implementados. Resta a barra explícita de habitabilidade e a validação visual em resoluções alvo.

### VS-02 — ações explicáveis

- **Código:** requisitos e custos visíveis em CTAs; tooltip de recurso faltante; confirmação de supernova.
- **Aceite:** uma ação desabilitada informa exatamente qual recurso falta e uma supernova não ocorre por clique acidental.

**Progresso:** custos, recursos faltantes e requisitos de órbita são exibidos nos CTAs e tooltips. A supernova exige confirmação e apresenta a recompensa prevista.

### VS-03 — eventos e registros

- **Código:** feed persistente dos últimos eventos, estados de severidade e retorno do modo compacto após decisão.
- **Aceite:** cada evento é rastreável por seed e resolução; nenhuma decisão fica invisível no modo compacto.

### VS-04 — segurança do save

- **Código:** versão explícita do schema, checksum, migração e tela de recuperação de backup.
- **Aceite:** save interrompido ou corrompido não remove a última sessão válida.

## Saída para MVP

O MVP só avança quando VS-01 a VS-04 estiverem aprovados em Windows 10/11, 100–200% DPI e dois monitores. A conexão MutterGames continua bloqueada até o núcleo offline cumprir esse critério.

## Pós-MVP ordenado

1. Observabilidade local e diagnóstico exportável.
2. Conexão MutterGames com OAuth/OIDC, PKCE e escopo mínimo.
3. Entitlements cosméticos e catálogo somente leitura.
4. Marketplace externo da plataforma, sem pay-to-win e sem dependência do game loop.
