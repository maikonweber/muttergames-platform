# Requisitos não funcionais

| ID | Categoria | Meta verificável [HIPÓTESE] | Prioridade | Validação |
|---|---|---|---|---|
| RNF-001 | Desempenho | CPU média ≤ 2% em repouso e ≤ 5% com animação em máquina de referência. | Must | Perfil de 30 min. |
| RNF-002 | Memória | ≤ 250 MB no MVP após 30 min. | Must | Medição automatizada/manual. |
| RNF-003 | Inicialização | Janela funcional em até 3 s com save normal. | Should | Teste frio. |
| RNF-004 | Confiabilidade | Último save válido recuperável após interrupção durante escrita. | Must | Teste de falha injetada. |
| RNF-005 | Compatibilidade | Windows 10/11, DPI 100–200%, dois monitores. | Must | Matriz de dispositivos. |
| RNF-006 | Segurança | Importação não executa código; arquivos têm schema, limites e checksum. | Must | Teste de entradas malformadas. |
| RNF-007 | Privacidade | Jogo é utilizável offline; telemetria exige consentimento. | Must | Inspeção de rede/configuração. |
| RNF-008 | Acessibilidade | Escala de texto, reduzir movimento, contraste e navegação por teclado. | Should | Checklist manual. |
| RNF-009 | Manutenibilidade | TypeScript estrito, lint e testes no domínio. | Must | CI local/futura. |
| RNF-010 | Usabilidade | Sem roubo de foco; alertas podem ser silenciados. | Must | Teste de tarefas paralelas. |
