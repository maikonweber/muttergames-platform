# ADR-003 — Game loop

**Status:** [PROPOSTA]. Modelo híbrido: renderização variável limitada; simulação em ticks determinísticos; cálculo agregado em segundo plano/offline. Isso mantém animação suave sem atrelar economia à taxa de quadros e torna testes reprodutíveis.
