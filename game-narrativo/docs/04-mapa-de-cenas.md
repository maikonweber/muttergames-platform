# Mapa de cenas

Estrutura de diamante: variações locais convergem em marcos. Nenhuma rota do MVP tranca as outras até o EP05 (fora do recorte).

## Temporada 1 — episódios

| Ep. | Título | Objetivo | Gancho | No MVP |
| ---: | --- | --- | --- | --- |
| 1 | O fio vermelho | Campus, primeiro interesse, foto de Íris | Mensagem anônima | Sim |
| 2 | Retratos apagados | Alianças; laboratório fotográfico secreto | Foto recente de Íris | Sim |
| 3 | O algoritmo dos encontros | App de Noah; em quem confiar | O app prevê a morte de uma conexão | Sim |
| 4 | Canção para quem sumiu | Gravação de Íris revelada por Theo | Segunda voz no áudio | Não |
| 5 | A noite das lanternas | Festival; primeira grande ruptura; **consolida rota** | Um fio é cortado | Não |
| 6 | Arquivos da reitoria | Registros; mãe estudou com Íris | — | Não |
| 7 | Maré baixa | Túneis; objeto de Íris intacto | — | Não |
| 8 | Nós e mentiras | Segredos das rotas em conflito | Aliado trai o grupo | Não |
| 9 | Observatório Aurora | Experimento das Tecelãs | Mensagem de Íris | Não |
| 10 | Quem segura o fio | Confronto e decisão afetiva | Final por provas e relações | Não |

## EP01 — fluxo detalhado

Roteiro jogável: [`../narrativa/roteiro-ep01.md`](../narrativa/roteiro-ep01.md). Nós: [`../data/episodes/ep01/nodes.json`](../data/episodes/ep01/nodes.json).

```text
SC01 Terminal ── decisão: como reagir à nova vida
        │
SC02 Pátio ──── decisão: ajudar / confrontar / brincar  (primeiro fio)
        │
SC03 Secretaria ── decisão: questionar ou silêncio
        │
SC04 Dormitório ── estilo + confidente (Bia)
        │
SC05 Festa ────── com quem passar mais tempo  (diamante → marco SC06)
        │
SC06 Corredor ── mostrar a foto ou esconder
        │
SC07 Quarto ── responder / bloquear / investigar o número
        │
   Aliado investigativo (confiança +; romances abertos)
```

### Cenas

| Cena | ID prefixo | Local | Acontecimento | Decisão | Tipo |
| --- | --- | --- | --- | --- | --- |
| 1 | `EP01_SC01` | Terminal | Chegada, mensagem da mãe, mar | Postura inicial | personalidade |
| 2 | `EP01_SC02` | Pátio | Esbarra no primeiro personagem; fio vermelho | Ajudar, confrontar, brincar | relacional + fios |
| 3 | `EP01_SC03` | Secretaria | Bolsa inconsistente no sobrenome da mãe | Questionar ou observar | investigativa |
| 4 | `EP01_SC04` | Dormitório | Bia; visual para a festa | Estilo e confidente | expressão + relacional |
| 5 | `EP01_SC05` | Festa | Rotas e conflito social | Com quem passar tempo | relacional (diamante) |
| 6 | `EP01_SC06` | Corredor antigo | Foto de Íris com o mesmo colar | Mostrar ou esconder | crítica |
| 7 | `EP01_SC07` | Quarto | Ameaça anônima | Responder, bloquear, investigar | crítica + aliado |

### Quem é o “primeiro personagem” (SC02)

Premissa de produção: a jogadora **não escolhe** quem esbarra no pátio. O GDD diz “o primeiro personagem”. Usar **Theo** como contato físico do fio vermelho (músico no pátio, estojo caído). Os outros aparecem na festa. Se o teste de slice pedir outro, só o `speaker` e o retrato de SC02 mudam; o grafo permanece.

### Encerramento

A última decisão define o primeiro **aliado investigativo** do EP02. Concede confiança ao escolhido. Não bloqueia rota romântica. Resumo: personagem mais próximo, pista encontrada, coragem, prévia sem spoiler.

## EP02 — marcos (ainda sem roteiro linha a linha)

1. Recap com o aliado (varia o diálogo, mesmo objetivo).
2. Café Farol: Marta menciona Tecelãs.
3. Biblioteca ou pátio: formar grupo frouxo.
4. Laboratório fotográfico: Luna ou descoberta conjunta.
5. Foto recente de Íris (gancho). Pista `ev_iris_foto_recente`.

## EP03 — marcos

1. Convite ou invasão leve ao laboratório de Noah.
2. Demo do app **Nexo**.
3. Escolha de confiança: cobrir Noah, denunciar, ou investigar em silêncio.
4. Previsão de morte de uma conexão (CG-04).

## Tipos de escolha (GDD 6.2)

| Tipo | Impacto | Sinal na UI |
| --- | --- | --- |
| Personalidade | Voz da protagonista, leve | Nenhum |
| Relacional | Afinidade e/ou confiança | Nenhum |
| Investigativa | Pista, suspeita, consequência | Ícone de pista se coletar |
| Crítica | Cenas ou finais; flag permanente | Sinal discreto (não só cor) |
| Tempo | Tensão; desligável | Timer visível só se ativo |

## Diamante

Três visitas na festa (SC05) convergem em `EP01_SC06_N001`. Diálogos posteriores leem `ep01_festa_theo|gael|noah|luna`. Não clone a cena do corredor.
