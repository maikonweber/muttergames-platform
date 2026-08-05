# Estratégia de testes

Pirâmide: testes unitários do domínio > integração de persistência/adaptadores > testes E2E da interface desktop.

| ID | Nível | Cobertura |
|---|---|---|
| T-UNIT-02 | Unitário | fusão, custos, habitabilidade e prestígio com seeds fixas |
| T-INT-04 | Integração | cálculo offline, limite e relógio regressivo |
| T-INT-05 | Integração | save atômico, backup, checksum e migração |
| T-E2E-03 | Desktop | alternar compacto/expandido, monitor, DPI e foco |
| T-PERF-01 | Desempenho | CPU/memória em repouso e segundo plano |
| T-SEC-01 | Segurança | importação corrompida/maliciosa e tokens revogados |

Eventos e economia usam seeds reprodutíveis. A matriz de regressão cobre Windows 10/11, escalas DPI e múltiplos monitores. Integrações MutterGames devem usar sandbox e dublês de contrato.
