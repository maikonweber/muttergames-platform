# ADR-002 — Persistência local

**Status:** [PROPOSTA]. JSON versionado é a escolha do MVP: auditável, exportável e simples de migrar. Escrita atômica, checksum e backups mitigam corrupção. SQLite será avaliado quando volume, consultas ou múltiplos slots tornarem o JSON inadequado. IndexedDB não é a fonte de verdade desktop; binário reduz transparência sem benefício comprovado.
