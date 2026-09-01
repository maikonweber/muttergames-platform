# Roteiro — Episódio 1 · O fio vermelho

Nós: [`../data/episodes/ep01/nodes.json`](../data/episodes/ep01/nodes.json). Voz: [personagens](../personagens/README.md). Tokens: `{name}`, `{they}`.

Gancho final: mensagem *Se você começou a enxergar os fios, já está em perigo.*

## Como o episódio prende

| Recurso | Onde | Função |
| --- | --- | --- |
| Abertura fria | SC00 | A ameaça é a primeira coisa que a jogadora lê; o episódio inteiro corre para alcançá-la |
| Nome plantado | SC01 cartaz → SC04 Bia → SC05 Caio → SC06 foto | Íris deixa de ser revelação solta e vira pagamento |
| Custo do poder | SC02, SC06 | Ver fio dói: gosto de cobre, tempo perdido. Poder com preço gera tensão |
| Regra quebrada | SC06 | O fio cinza da foto termina em parede nenhuma — a primeira coisa que a lore não explica |
| Vigia | SC01 percevejo → SC05 clique no escuro → SC06 passos → SC07 foto | Presença antagonista antes do vilão existir |
| Micropagamento | SC05 Caio assume o percevejo | A jogadora fecha um mistério pequeno dentro do episódio |
| Laço fechado | SC00 ↔ SC07 | Reconhecimento: a frase agora tem hora e lugar |

## SC00 — Abertura fria

Quarto escuro, tela acesa, a mensagem verbatim. Corta para doze horas antes. Sem escolha, sem retrato. Três nós.

## SC01 — Terminal de Miralume

**Objetivo:** chegar, ouvir a mãe, ver o mar, escolher postura.  
**Decisão:** aberta / cautelosa / desafiante (`ep01_posture_*`). Ousada: +1 coragem.

O ônibus desce a serra. Mar cinza. Celular: a mãe deseja sorte e não pergunta se `{name}` está com medo. A protagonista liga de volta e cai na caixa — **a mãe não retorna em nenhum momento do episódio** (laço aberto da temporada).

No mural, cartaz desbotado: sobrou o nome ÍRIS, e a foto está gasta no lugar do pescoço. O papel é velho, o percevejo é novo. Semente do vigia; explicada por Caio na SC05.

## SC02 — Pátio Aurora

**Objetivo:** primeiro toque, fio vermelho, tutorial.  
**Personagem:** Theo (estojo no chão).  
**Decisão:** ajudar / confrontar / brincar. CG-01.

Ordem: colisão → fio + CG → **custo** (cobre na boca, tempo perdido) → tutorial → **pátio inteiro costurado**, incluindo um cinza fugindo por janela do segundo andar → só o vermelho fica.

Tutorial após o CG: cor não é destino.

## SC03 — Secretaria

**Objetivo:** bolsa com inconsistência no sobrenome da mãe.  
**Decisão:** questionar (pista `ev_bolsa_inconsistente`) ou observar.

Não é erro de digitação: é um campo que não existia nos formulários. **Fio cinza** sai pelo balcão para alguém que a protagonista não pode ver — ensina a cor e acusa a instituição sem nomear ninguém. Helena fala, cita o colar como “parecido”, e o narrador registra que ela não conferiu duas vezes.

## SC04 — Dormitório

Bia: cama da janela, festa à noite, personalização. Escolher tag de roupa e se confia em Bia (`ep01_confided_bia`).

Bia também faz duas coisas de estrutura: brinca com a **lenda das Tecelãs** (a jogadora ganha a palavra que a ameaça vai usar na SC07) e nomeia **Íris** com afeto, não com dossiê. Na saída, a protagonista percebe que **Bia não tem fio nenhum** — tema do episódio em uma linha.

## SC05 — Festa de recepção

Caio abre a cena: nomeia Íris e **assume o percevejo do terminal**. Fecha a única pergunta que a jogadora pode responder sozinha neste episódio.

Diamante: Theo / Gael / Noah / Luna. Todos os ramos → `EP01_SC05_N050` → `EP01_SC06_N001`. CG-03 variante do escolhido.

`N050` é o nó compartilhado: lanternas piscam juntas, clique de câmera no escuro, ninguém com câmera na mão. Também é o motivo diegético de entrar no corredor (ar frio com cheiro de papel).

Micro-gancho se festa com Theo: menina que filmava o ensaio, uns dois anos atrás — sem nome, a jogadora pode ligar depois.

## SC06 — Corredor antigo

Foto de Íris com o colar. Pista `ev_colar_iris` + `ev_colar_protagonista` já no inventário. **Crítica:** mostrar (a quem esteve na festa, senão Bia depois) ou esconder.

Escada de revelação, um nó por degrau: quadro torto → **falha limpa na poeira** (alguém mexeu há pouco) → foto e colar → **“não era lenda” escrito à mão, tinta fresca** → o colar esquenta → **fio cinza sem pulso terminando na parede**.

Se `ep01_questioned_grant`, um nó extra conecta o campo da secretaria à foto: é o momento em que a jogadora é recompensada por ter perguntado.

Cada personagem da festa reage à foto com a própria voz e o próprio medo. Depois: os passos recuam sem pressa e o celular vibra pela primeira vez.

## SC07 — Quarto

Mensagem verbatim, agora reconhecida (`SC00`). **Crítica:** responder / bloquear / investigar número (+1 coragem se investigar). Define aliado.

Depois da resposta do aliado, o pico: uma **foto do corredor tirada esta noite, com as costas de `{name}`**, e a assinatura *boa noite, Tecelã* — a palavra que Bia usou como piada. Quem manda estava lá e sabe o que ela é.

Resumo: nomes do campus, o colar, o fio que acaba em nada, a mãe que não retornou, e a palavra na boca de quem ameaça.

## Continuidade EP02

Quem for `ep01_ally_*` espera no pátio ou no café. Foto recente ainda não existe.
