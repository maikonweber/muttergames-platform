# Regras de negócio

| ID | Regra | Definição inicial |
|---|---|---|
| RN-001 | Produção | `produção/s = base × multiplicadores`; nenhum recurso fica negativo. |
| RN-002 | Capacidade | Inventário começa com limite; excesso é descartado com feedback. Limites são [HIPÓTESE] de balanceamento. |
| RN-003 | Fusão | Dois ou mais asteroides compatíveis e Matéria adicional formam um planeta; órbita deve estar vaga. |
| RN-004 | Habitabilidade | Vida requer planeta rochoso/oceânico, atmosfera estável, água e temperatura na faixa do tipo. |
| RN-005 | Offline | Produção é calculada por `min(tempo real, limite configurado)` e reduzida se houver suspeita de relógio regressivo. |
| RN-006 | Eventos | Evento respeita pré-condições, tempo de recarga por categoria e seed armazenada. |
| RN-007 | Prestígio | Supernova só é habilitada após marco do sistema; reinicia estado transitório, preserva Essência e upgrades. |
| RN-008 | Destruição | Corpos destruídos liberam fração configurável de Matéria; nunca removem upgrades de prestígio. |
