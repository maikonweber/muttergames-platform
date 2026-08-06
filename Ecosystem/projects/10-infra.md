# PRJ-10 — Infra de observabilidade (local)

**Pasta:** `infra/`  
**Status:** Config local via Docker Compose  
**Owner:** SRE / Eng plataforma

## 1. Objetivo

Stack de métricas, logs e dashboards para desenvolvimento local da API e serviços.

## 2. Componentes

| Componente | Config | Porta típica |
|---|---|---|
| Prometheus | `infra/prometheus/prometheus.yml` | `9090` |
| Grafana | `infra/grafana/provisioning/*` | `3002` |
| Loki | `infra/loki/loki-config.yml` | (Compose) |
| Alloy | `infra/alloy/config.alloy` | `12345` |

Dashboard exemplo: `infra/grafana/provisioning/dashboards/json/api-overview.json`.

## 3. Requisitos

| ID | Requisito | Aceite |
|---|---|---|
| INF-RF-01 | Subir com `init-all` / Compose | Containers healthy |
| INF-RF-02 | Scrape da API metrics | Prometheus lista target |
| INF-RF-03 | Grafana com datasource provisionado | Login local `admin`/`admin` |
| INF-RF-04 | Sem exposição pública | Somente localhost / rede Compose |

## 4. Docs

- Guia: [`outputs/MutterGames-SRE-Infrastructure-Guide.md`](../../outputs/MutterGames-SRE-Infrastructure-Guide.md)
- README local: [`infra/README.md`](../../infra/README.md)
- Toolchain: [`../tools/05-local-dev-toolchain-spec.md`](../tools/05-local-dev-toolchain-spec.md)

## 5. Fora de escopo

Produção (HA, retenção, SSO, alertas PagerDuty) — apenas esboçado no guia SRE.
