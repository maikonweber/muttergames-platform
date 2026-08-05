# Modelo de dados

| Entidade | Campos essenciais |
|---|---|
| SaveGame | schemaVersion, id, savedAt, checksum, profileId |
| Universe | id, seed, sistemas, recursos, prestígio |
| StarSystem | id, estrela, órbitas, estado de conclusão |
| Planet | id, tipo, raridade, órbita, atmosfera, água, vida, civilização |
| ResourceInventory | quantidades, capacidades, multiplicadores |
| GameEvent | id, tipo, seed, iniciadoEm, estado, efeitos |
| PrestigeState | essência, upgrades adquiridos, contagem |
| GameSettings | janela, áudio, acessibilidade, idle, privacidade |

IDs são UUIDs locais. Índices lógicos: planeta por sistema/órbita, evento por estado e save por `savedAt`. O schema deve suportar migrações sem perda de dados desconhecidos.
