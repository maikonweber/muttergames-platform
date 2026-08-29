# Roteiro — Episódio 1 · O fio vermelho

Nós: [`../data/episodes/ep01/nodes.json`](../data/episodes/ep01/nodes.json). Voz: [personagens](../personagens/README.md). Tokens: `{name}`, `{they}`.

Gancho final: mensagem *Se você começou a enxergar os fios, já está em perigo.*

## SC01 — Terminal de Miralume

**Objetivo:** chegar, ouvir a mãe, ver o mar, escolher postura.  
**Decisão:** aberta / cautelosa / desafiante (`ep01_posture_*`). Ousada: +1 coragem.

O ônibus desce a serra. Mar cinza. Celular: a mãe deseja sorte e não pergunta se `{name}` está com medo. O colar pesa. A protagonista segue para o campus.

## SC02 — Pátio Aurora

**Objetivo:** primeiro toque, fio vermelho, tutorial.  
**Personagem:** Theo (estojo no chão).  
**Decisão:** ajudar / confrontar / brincar. CG-01.

Tutorial após o CG: cor não é destino.

## SC03 — Secretaria

**Objetivo:** bolsa com inconsistência no sobrenome da mãe.  
**Decisão:** questionar (pista `ev_bolsa_inconsistente`) ou observar. Helena não precisa aparecer; a atendente basta. Se Helena cruzar, uma fala só.

## SC04 — Dormitório

Bia: cama da janela, festa à noite, personalização. Escolher tag de roupa e se confia em Bia (`ep01_confided_bia`).

## SC05 — Festa de recepção

Diamante: Theo / Gael / Noah / Luna. Conflito social leve (Caio pode passar com gravador). Todos os ramos → `EP01_SC06_N001`. CG-03 variante do escolhido (placeholder único no slice).

Micro-gancho se festa com Theo: menina que filmava o ensaio, uns dois anos atrás — sem nome, a jogadora pode ligar depois.

## SC06 — Corredor antigo

Foto de Íris com o colar. Pista `ev_colar_iris` + `ev_colar_protagonista` já no inventário. Hipótese possível no painel. **Crítica:** mostrar (a quem esteve na festa, senão Bia depois) ou esconder.

## SC07 — Quarto

Mensagem verbatim. **Crítica:** responder / bloquear / investigar número (+1 coragem se investigar). Define aliado. Resumo: mais próximo, pista, coragem, prévia sem spoiler (“Amanhã o campus vai parecer menor”).

## Continuidade EP02

Quem for `ep01_ally_*` espera no pátio ou no café. Foto recente ainda não existe.
