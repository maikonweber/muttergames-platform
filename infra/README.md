# Infra — observabilidade local

Configs usadas pelo Docker Compose / `scripts/init-all.sh` para desenvolvimento.

| Serviço | Path | URL local típica |
|---|---|---|
| Prometheus | `prometheus/prometheus.yml` | http://localhost:9090 |
| Grafana | `grafana/provisioning/` | http://localhost:3002 (`admin`/`admin`) |
| Loki | `loki/loki-config.yml` | via Compose |
| Alloy | `alloy/config.alloy` | http://localhost:12345 |

## Spec

[`Ecosystem/projects/10-infra.md`](../Ecosystem/projects/10-infra.md)  
Guia: [`outputs/MutterGames-SRE-Infrastructure-Guide.md`](../outputs/MutterGames-SRE-Infrastructure-Guide.md)

Credenciais são **somente locais**. Não expor a rede pública.
