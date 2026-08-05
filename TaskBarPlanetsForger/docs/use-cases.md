# Casos de uso

## UC-02 — Criar planeta

- **Ator:** jogador.
- **Pré-condições:** sessão válida, recursos suficientes, asteroides elegíveis e órbita vaga.
- **Gatilho:** jogador confirma fusão no painel expandido.
- **Fluxo:** validar RN-003 → debitar recursos → criar planeta/atributos com seed → registrar evento → autosave → atualizar cena.
- **Alternativas:** órbita ocupada ou recursos insuficientes mostram causa sem alterar estado.
- **Pós-condição:** planeta persistido e disponível para evolução.

## UC-08 — Retorno offline

- **Ator:** jogador; **secundário:** relógio do SO.
- **Fluxo:** carregar último save válido → comparar tempo → aplicar RN-005 → resolver eventos elegíveis → gravar → mostrar relatório.
- **Exceção:** checksum inválido abre fluxo de backup; relógio regressivo produz zero offline e aviso neutro.

## UC-10 — Alterar modo da janela

- **Ator:** jogador.
- **Fluxo:** acionar clique/atalho → preservar estado → alternar compacto/expandido → aplicar preferência de foco e tamanho → salvar configuração.
