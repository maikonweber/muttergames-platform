# Plano de execução

## Caminho crítico

```text
modelo piloto + máscaras
        ↓
canvas de maquiagem e gestos
        ↓
desfazer / antes-depois
        ↓
desafio + avaliação + resultado
        ↓
save + desbloqueios + modo livre
        ↓
conteúdo dos 4 modelos e 20 desafios
        ↓
testes Android + publicação
```

## Sequência de implementação

### 1. Fundação

1. Criar o projeto Godot em retrato e configurar a cena inicial.
2. Criar pastas para cenas, scripts, recursos, assets e testes.
3. Importar `model_01` provisório e as máscaras de lábios e olhos.
4. Criar `ModelData` e `CosmeticData` como Resources com IDs estáveis.

**Pronto quando:** o rosto aparece centralizado, com áreas de lábios e olhos verificadas por uma visualização interna de máscaras.

### 2. Protótipo de pintura

1. Implementar `MakeupCanvas` para toque, arraste e amostragem de pontos.
2. Aplicar batom e sombra em camadas separadas e limitadas por máscara.
3. Adicionar intensidade, apagar a etapa, desfazer/refazer e antes/depois.
4. Testar em pelo menos um Android físico.

**Pronto quando:** o jogador consegue criar e corrigir um look sem travamento, sem vazamento de pintura e sem perder o estado ao trocar a ferramenta.

### 3. Vertical slice

1. Criar um `ChallengeData` de festa com objetivos claros.
2. Implementar leitura de objetivos, cálculo de pontuação e tela de resultado.
3. Conceder moedas e salvar o progresso localmente.
4. Criar tutorial de uma sessão com no máximo 5 instruções.

**Pronto quando:** uma sessão completa — selecionar, maquiar, avaliar, receber recompensa e voltar ao início — funciona offline.

### 4. MVP completo

1. Adicionar base, blush, delineador, máscara, cabelo e acessórios.
2. Implementar coleção, desbloqueios e modo livre.
3. Produzir os modelos 02–04, 20 desafios e catálogo do GDD.
4. Adicionar áudio, configurações e captura de antes/depois conforme permissões Android.

**Pronto quando:** todos os fluxos do GDD marcados como MVP têm dados reais, não placeholders.

### 5. Qualidade e lançamento

1. Executar testes de regressão em aparelhos básicos e intermediários.
2. Medir FPS, memória, abandono por etapa e conclusão do tutorial, com consentimento quando houver telemetria.
3. Integrar somente anúncios recompensados opcionais e política de privacidade revisada.
4. Preparar página da loja, classificação indicativa e build de publicação.

## Definição de pronto para qualquer item

- Tem critério de aceite verificável no aparelho Android alvo.
- Não introduz arte fora da máscara, bloqueio de navegação ou perda de save.
- Tem ID de dados/documentação atualizado se criar conteúdo.
- Foi testado com toque; mouse no editor não é validação suficiente.
- Não depende de compra, anúncio ou conta para concluir o fluxo principal.
