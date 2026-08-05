# Salvamento e progresso offline

Formato inicial: JSON versionado, validado por schema e gravado em arquivo temporário seguido de troca atômica. Um backup rotativo é preservado antes de substituir o arquivo principal.

Estrutura mínima: versão, `savedAt`, relógio monotônico disponível, universo, inventário, eventos, prestígio, configurações e checksum. Importação valida tamanho, schema, versão e checksum; save corrompido oferece backup, exportação de diagnóstico ou nova sessão sem apagar o original.

Migrações são puras e encadeadas por versão. Progresso offline compara timestamps, limita ganhos e registra anomalias de relógio; não há punição destrutiva ao jogador.
