# Design System — TaskBar Planets Forger

> **Versão:** 1.0 · **Plataforma:** Windows 10/11 · **Engine:** Godot 4.7

## 1. Propósito

Este design system define a linguagem visual, os componentes e os comportamentos de interface do **TaskBar Planets Forger**. O jogo deve parecer um pequeno observatório vivo no desktop: calmo enquanto acompanha o trabalho do usuário, expressivo quando ele abre o painel e sempre legível em poucos segundos.

O sistema atende a dois contextos complementares:

- **Modo compacto:** presença discreta próxima à barra de tarefas, para consulta e ações rápidas.
- **Modo expandido:** oficina de criação planetária, planejamento e leitura do estado do sistema.

### Princípios

1. **O planeta é a informação principal.** Números e controles servem à leitura do sistema, nunca a escondem.
2. **Ação com consequência visível.** Toda operação mostra custo, resultado e mudança visual no planeta.
3. **Calma por padrão.** Movimento, alertas e brilho só aumentam quando existe motivo de jogo.
4. **Leitura em camadas.** O jogador entende o essencial na barra e aprofunda apenas quando abre a oficina.
5. **Acessível sem perder atmosfera.** Cor não é o único sinal; texto, ícone e forma comunicam estado.

---

## 2. Direção visual

### Personalidade

**"Oficina cósmica de pixel art"** — tecnologia analógica, observação astronômica e matéria em transformação. A interface usa superfícies azul-profundo, contornos suaves e acentos luminosos. O espaço negativo é tão importante quanto os painéis: ele deixa os planetas respirarem.

### Paleta de cor

| Token | Hex | Uso |
|---|---:|---|
| `space-950` | `#070B1F` | Fundo da janela e espaço profundo |
| `space-900` | `#0D1430` | Superfícies principais |
| `space-800` | `#162044` | Cards, abas e painéis secundários |
| `space-700` | `#263360` | Bordas, estados hover e divisores |
| `starlight` | `#EEF5FF` | Texto principal e estrelas |
| `mist` | `#AAB9D8` | Texto secundário e rótulos |
| `cosmic-cyan` | `#55D9FF` | Ação primária, foco e água |
| `nebula-violet` | `#A88CFF` | Pesquisa, conhecimento e itens raros |
| `solar-gold` | `#FFC857` | Energia, conquista e ênfase |
| `life-green` | `#62E6A7` | Biomassa, habitabilidade e sucesso |
| `magma-orange` | `#FF875C` | Vulcanismo, atenção e perigo moderado |
| `nova-red` | `#FF5D79` | Erro, ação irreversível e supernova |

**Regra de contraste:** texto em `starlight` sobre `space-900` ou `space-950`; `mist` é reservado a conteúdo secundário. Nunca use `cosmic-cyan`, `solar-gold` ou `life-green` como texto pequeno sobre fundo claro.

### Tipografia

| Papel | Família | Tamanho | Peso | Uso |
|---|---|---:|---:|---|
| Display | Oxanium / fallback sans-serif | 24–32 px | 700 | Títulos e números de progresso importantes |
| Título de painel | Oxanium / fallback sans-serif | 16–20 px | 700 | Seções e títulos de diálogo |
| Corpo | Inter / fallback sans-serif | 13–15 px | 400 | Leitura e descrições |
| Rótulo | Inter / fallback sans-serif | 11–12 px | 600 | Recursos, filtros e metadados |
| Numérico | JetBrains Mono / fallback monospace | 12–16 px | 600 | Custos, produção e seeds |

Em pixel art, use fonte bitmap somente dentro do mundo visual (placas, nomes de corpos); os controles permanecem em fontes de alta legibilidade.

### Espaçamento e forma

- Unidade-base: **4 px**. Escala: 4, 8, 12, 16, 24, 32, 48.
- Raio: 6 px para botões, 10 px para cards, 14 px para diálogos.
- Borda padrão: 1 px `space-700`; foco: 2 px `cosmic-cyan`.
- Sombra: `0 12px 32px rgba(0, 0, 0, .35)` apenas em sobreposições.
- Alvos clicáveis: mínimo de 36 × 36 px; 44 × 44 px para touch/escala ampliada.

---

## 3. Arquitetura de interface

### Modo compacto — visão de 1 segundo

Largura-alvo: **420–640 px**; altura: **72–96 px**. A janela segue a âncora configurada pelo usuário e não deve tomar foco sem clique explícito.

```text
┌──────────────────────────────────────────────────────────────────────┐
│ ✦  [Sol]  ○ Terra-02  ◌ Órbita livre     Matéria 124  ⚡ 48   ⏸  ⤢ │
│        +2.4/min             "Vida floresce em Terra-02"             │
└──────────────────────────────────────────────────────────────────────┘
```

| Área | Conteúdo | Ação |
|---|---|---|
| Sistema vivo | Estrela, até três órbitas e miniaturas dos planetas | Clique em corpo abre o inspetor |
| Recursos essenciais | Matéria e Energia, com taxa curta | Hover revela os demais recursos |
| Evento | Uma frase e ícone de severidade | Clique abre escolha de evento |
| Utilitários | Pausar e expandir | Sempre visíveis e navegáveis por teclado |

**Comportamento:** animações em velocidade baixa; eventos não bloqueiam a faixa. O modo de baixa atividade reduz partículas e atualizações visuais, mantendo o cálculo de recursos.

### Modo expandido — oficina orbital

Tamanho mínimo: **1120 × 680 px**; tamanho recomendado: **1280 × 760 px**.

```text
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│ TASKBAR PLANETS FORGER     Sistema: Helios-04      ☁ Offline: +18 min      ⚙  ⏸          │
├───────────────┬───────────────────────────────────────────────┬───────────────────────────┤
│ RECURSOS      │                  MAPA ORBITAL                  │ PLANETA SELECIONADO        │
│ ◈ Matéria 124 │                  ✦ Sol                         │ Terra-02 · Oceânico        │
│ ⚡ Energia 48 │           ○ Órbita I   ◌ Órbita II              │ [render do planeta]         │
│ ◉ Água 32     │               ◉ Terra-02     + Forjar           │ Habitabilidade 72%          │
│ ✤ Biomassa 9  │                                               │ ━━━━━━━━━━━━░░░░           │
│ ✧ Conhec. 14  │          [arraste para girar]                   │ [Terraformar] [Evoluir]     │
├───────────────┼───────────────────────────────────────────────┼───────────────────────────┤
│ ABA: Sistema | Forja | Pesquisa | Registros                     │ feed de efeitos / detalhes  │
└───────────────┴───────────────────────────────────────────────┴───────────────────────────┘
```

| Região | Função | Prioridade visual |
|---|---|---|
| Barra superior | Nome do sistema, resumo offline, pausa, configurações | Global |
| Rail de recursos | Estoque, capacidade e produção por minuto | Sempre disponível |
| Mapa orbital | Seleção, leitura espacial e órbitas livres | Área protagonista |
| Inspetor | Estado do planeta e próximas ações | Contextual |
| Barra inferior | Navegação de ferramentas: Sistema, Forja, Pesquisa, Registros | Persistente |

---

## 4. Componentes UI

### Botões

| Variante | Aparência | Uso |
|---|---|---|
| Primário | Fundo `cosmic-cyan`, texto `space-950` | Ação segura e principal: Forjar, Terraformar |
| Secundário | Fundo `space-800`, borda `space-700` | Ações alternativas: Ver detalhes, Cancelar |
| Destaque | Fundo `solar-gold`, texto `space-950` | Marco positivo: Reivindicar descoberta |
| Perigo | Fundo transparente, borda/texto `nova-red` | Supernova, apagar sistema |
| Ícone | 36 px quadrados, tooltip obrigatório | Pausar, configurar, fechar |

Estados obrigatórios: padrão, hover, pressionado, desabilitado, foco por teclado e carregando. Ao desabilitar por falta de recursos, o tooltip deve exibir **o que falta**.

### Cartão de recurso

```text
┌─────────────────────────┐
│ ◉ ÁGUA              32  │
│ +0.8/min   32 / 80 cap. │
│ ████████░░░░░░░░░░░░    │
└─────────────────────────┘
```

- Ícone, nome, saldo e taxa sempre juntos.
- Barra de capacidade aparece apenas quando há limite.
- Taxa negativa usa `magma-orange`, sem depender apenas da cor: prefixo `−` e ícone de queda.

### Cartão de planeta

Exibe miniatura procedural, nome, tipo, etapa, 1 atributo dominante e estado. Seleção usa aro `cosmic-cyan` de 2 px e não apenas mudança de fundo.

```text
┌──────────────────────────┐
│       ◉                  │
│ Terra-02 · Oceânico      │
│ Vida inicial · 72% hab.  │
│ Produz: Água +0.4/min    │
└──────────────────────────┘
```

### Barras de estágio

Representam **Habitabilidade**, **Atmosfera**, **Água**, **Biosfera** e **Civilização**. Cada uma combina percentagem, rótulo textual e marcador de próximo marco. Não use uma barra sem valor numérico.

### Modais e eventos

- Um único modal bloqueante por vez.
- Eventos de risco usam ícone, prazo (se houver), impacto provável e duas ou três escolhas claras.
- A escolha recomendada é indicada pelo menor risco, não por cor verde automática.
- `Esc` fecha apenas modais sem decisão pendente; o evento pode ser minimizado para o feed se o design de jogo permitir.

### Feedback

| Situação | Feedback |
|---|---|
| Forja concluída | Explosão de poeira curta, nome do planeta e alteração no mapa |
| Recurso insuficiente | Botão treme 2 px uma vez; tooltip mostra a diferença |
| Produção offline | Cartão no topo com duração, ganhos e botão `Aplicar` |
| Marco de vida/civilização | Confete de partículas reduzido + entrada permanente em Registros |
| Erro de salvamento | Banner persistente com `Tentar novamente` e caminho local, sem perder a sessão |

---

## 5. Fluxos principais

### A. Forjar um planeta

1. Jogador abre **Forja** ou seleciona uma órbita vazia.
2. O painel mostra receita, custo, prévia procedural e resultado provável.
3. Alterar seed ou arquétipo atualiza a prévia sem gastar recursos.
4. `Forjar planeta` apresenta custo final e anima a formação na órbita.
5. O inspetor abre no novo planeta com uma ação de continuação: `Terraformar`.

**Regra:** se não houver recursos, o CTA permanece visível e desabilitado; a interface informa o recurso faltante e sua fonte conhecida.

### B. Terraformar e evoluir

1. Selecionar planeta abre seus estágios e gargalos.
2. Cada ação declara: custo, duração (se aplicável), efeito e requisito.
3. Ao atingir um marco, o próximo estágio aparece desbloqueado no mesmo local, evitando caça à interface.
4. Mudanças visuais são incrementais: água, nuvens, vegetação, luzes e satélites refletem o estado do modelo.

### C. Supernova / prestígio

1. Ação fica no painel de Sistema, separada das ações cotidianas.
2. Prévia mostra Essência a ganhar, bônus permanentes e o que será reiniciado.
3. A confirmação exige frase curta (`NOVA`) ou botão pressionado por 1 s.
4. A transição apresenta resumo do sistema anterior antes do novo começo.

---

## 6. Gerador procedural de planetas

### Objetivo

Criar planetas reconhecíveis, únicos e coerentes com os dados de jogo, sem exigir assets desenhados manualmente para cada variação. A seed deve permitir reprodução idêntica para salvamento, captura e depuração.

### Contrato de seed

```gdscript
PlanetSeed = {
  "id": "helios-04/orbit-2/planet-01",
  "seed": 428771,
  "archetype": "oceanic",
  "stage": "life_early",
  "palette_variant": 3,
  "feature_flags": ["rings", "polar_caps"]
}
```

- A seed é criada uma única vez na forja e persistida no save.
- `archetype` e `stage` são dados de jogo; nunca devem ser inferidos apenas pela cor.
- O gerador é determinístico: mesma seed + versão do gerador = mesma composição.
- Alterações futuras usam `generator_version` para preservar saves antigos.

### Camadas de renderização

| Ordem | Camada | Regra procedural |
|---:|---|---|
| 1 | Silhueta | Disco, achatamento leve ou forma gasosa conforme arquétipo |
| 2 | Base | Gradiente/dither da paleta do tipo planetário |
| 3 | Relevo | Noise em baixa frequência: continentes, crateras, faixas ou fissuras |
| 4 | Bioma | Água, gelo, vegetação, lava, nuvens e tempestades conforme estágio |
| 5 | Marcas | Crateras, polos, anéis, satélites e cicatrizes de evento |
| 6 | Iluminação | Terminador solar, brilho atmosférico e sombra de anel |
| 7 | Vida/civilização | Luzes noturnas, ruínas, megaestruturas; somente quando o modelo liberar |
| 8 | Partículas | Poeira, faíscas, nuvens e orbitais, reduzíveis por acessibilidade |

### Arquétipos e parâmetros

| Arquétipo | Paleta-base | Relevo | Assinatura visual | Dados relacionados |
|---|---|---|---|---|
| Rochoso | Cinza, ocre, ferrugem | Crateras + planaltos | Superfície seca e poeirenta | Matéria, baixa Água |
| Oceânico | Azul, ciano, branco | Continentes suaves | Oceanos e nuvens | Água, habitabilidade |
| Vulcânico | Carvão, laranja, vermelho | Fissuras e caldeiras | Lava emissiva | Energia, risco |
| Desértico | Areia, âmbar, violeta | Dunas e bacias | Faixas de poeira | Matéria, baixa Biomassa |
| Congelado | Azul-gelo, branco | Rachaduras polares | Calotas e aurora | Água sólida, baixa energia |
| Gasoso | Índigo, rosa, ouro | Bandas fluidas | Grande mancha/tempestade | Energia e satélites |
| Vivo | Verde, turquesa, azul | Continentes ricos | Vegetação e nuvens densas | Biomassa, vida |
| Máquina | Grafite, ciano, magenta | Painéis geométricos | Luzes e linhas artificiais | Conhecimento, civilização |

### Regras de consistência

- **Água baixa:** oceanos não podem ocupar mais de 25% da máscara do planeta.
- **Atmosfera baixa:** sem nuvens densas ou halo luminoso.
- **Vida inicial:** manchas verdes discretas; nunca cidades luminosas.
- **Civilização avançada:** luzes, satélites ou estruturas aparecem em quantidade limitada para manter leitura.
- **Evento destrutivo:** produz uma marca persistente na seed de estado (cratera, cinza, fissura), não uma variação aleatória esquecida.

---

## 7. Gerador procedural de assets

O gerador produz assets leves para a interface e para o mundo, usando paletas, ruído e composição modular. O objetivo é diversidade com linguagem visual consistente, não realismo fotográfico.

### Catálogo

| Família | Saídas | Parâmetros | Uso |
|---|---|---|---|
| Ícones de recurso | 16, 20 e 24 px | tipo, raridade, estado | Rail, custos, notificações |
| Asteroides | 24–64 px | seed, massa, metal, gelo | Órbitas, forja, eventos |
| Planetas | 96, 160 e 320 px | seed, arquétipo, estágio | Compacto, painel, detalhes |
| Estrelas | 48–256 px | classe, intensidade, idade | Centro do sistema e fundos |
| Partículas | 4–32 px | material, velocidade, duração | Forja, coleta, supernova |
| Estruturas | 16–96 px | nível tecnológico, facção | Civilização e marcadores |
| Fundos | 512–2048 px | densidade estelar, nebulosa, seed | Mapa orbital e telas vazias |

### Pipeline recomendado

```text
Dados de jogo + seed
        ↓
Seleção de arquétipo e paleta
        ↓
Composição por camadas (noise + máscaras + decals)
        ↓
Render em resolução-mestre
        ↓
Variações de escala / atlas / cache por seed
        ↓
Sprite, textura ou miniatura de UI
```

1. **Dados primeiro:** gerar a definição (`PlanetSeed`), depois a aparência.
2. **Paleta limitada:** 5–8 cores por asset normal; emissivos podem acrescentar 1–2 cores.
3. **Render mestre:** 320 px para planeta detalhado; reduções nítidas para 160/96 px.
4. **Cache:** chave por `generator_version + seed + tamanho + estado`; invalidar apenas quando dados visuais mudarem.
5. **Fallback:** se o render assíncrono atrasar, usar silhueta e cor do arquétipo, nunca placeholder genérico por mais de um frame de interface.

### Estrutura sugerida em Godot

```text
scripts/procedural/
├── planet_generator.gd       # orquestra seed e camadas
├── planet_palette.gd         # paletas e contraste
├── planet_noise.gd           # máscaras e noise determinístico
├── asset_generator.gd        # ícones, asteroides, estrelas, partículas
├── asset_cache.gd            # cache de ImageTexture por chave
└── generator_version.gd      # compatibilidade com saves
```

**Limite de desempenho:** nunca renderizar todas as texturas no `_process`. Pré-gerar ao forjar/carregar e reutilizar cache. No modo compacto, preferir a textura de 96 px e limitar partículas. A qualidade visual deve degradar de forma graciosa no modo de baixa atividade.

---

## 8. Acessibilidade e preferência do usuário

| Preferência | Comportamento |
|---|---|
| Texto ampliado | Escala de UI em 100%, 115%, 130% e 150%, sem truncar saldos |
| Reduzir movimento | Desativa orbitais contínuas, parallax, tremor e confete; mantém transições simples |
| Alto contraste | Eleva bordas, troca `mist` por `starlight` e reforça ícones de estado |
| Densidade compacta | Oculta descrições auxiliares, nunca custos ou CTAs |
| Atalhos | `Espaço`: pausa; `E`: expandir; `F`: forja; `Esc`: fechar painel seguro |
| Notificações | Controle independente para alertas internos e toast do Windows |

Todo tooltip precisa abrir por foco de teclado. Estados de planeta devem comunicar ao menos por texto curto e ícone, além da paleta.

---

## 9. Critérios de aceitação para implementação

- O modo compacto mostra recurso, taxa, estado de pausa e expansão sem abrir o painel.
- Um planeta recém-forjado recebe seed persistente e mantém a mesma aparência após reiniciar.
- Mudanças de terraformação alteram dados e pelo menos uma camada visual do planeta.
- Cada CTA mostra custo e requisito antes da confirmação.
- Os três estados de acessibilidade — texto ampliado, movimento reduzido e alto contraste — funcionam em compacto e expandido.
- O modo de baixa atividade reduz efeitos visuais sem alterar a produção de recursos.
- Falhas de save, geração ou cache não bloqueiam a sessão e apresentam recuperação compreensível.

## 10. Próximos entregáveis

1. Implementar tokens em um tema Godot (`Theme`) e estilos reutilizáveis.
2. Construir biblioteca de componentes: botão, recurso, planeta, barra de estágio, evento e modal.
3. Prototipar `planet_generator.gd` com Rochoso, Oceânico e Vulcânico — os três arquétipos do MVP.
4. Validar o painel em 1280 × 720, 1366 × 768 e escala de UI de 150%.
5. Criar capturas de referência para cada estágio planetário e revisar a legibilidade no modo compacto.
