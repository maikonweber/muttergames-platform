# Publicação Android e pagamentos no Google Play

> Checklist de execução para o **Lira Studio**. Revisado em 28/08/2026, com links somente para fontes oficiais Google, Android e Godot.

## Situação atual do projeto

- [x] Projeto em Godot 4.7; compatível com o plugin oficial de faturamento (requer Godot 4.2+).
- [ ] Criar o preset de exportação Android: `export_presets.cfg` ainda não existe no projeto.
- [ ] Definir um identificador definitivo de pacote, por exemplo `com.seuestudio.lirastudio`. Ele não deve mudar após a publicação.
- [ ] Criar e guardar com segurança a chave de assinatura *release*; ela é necessária para toda atualização futura.
- [ ] Implementar e testar compras antes de solicitar produção.

## 1. Gerar um AAB assinado

### Preparar o computador

- [ ] Instalar **OpenJDK 17** e Android Studio/SDK.
- [ ] No Godot, configurar `Java SDK Path` e `Android SDK Path` em **Editor Settings > Export > Android**.
- [ ] Instalar no SDK pelo menos Platform Tools, Build Tools e a plataforma do `targetSdk` exigido.
- [ ] Criar uma chave de produção fora do repositório e manter cópia segura de arquivo, alias e senhas:

  ```text
  keytool -v -genkey -keystore lira-studio-release.keystore -alias lira-studio -keyalg RSA -validity 10000
  ```

- [ ] Em **Project > Export > Android**, preencher pacote, chave/usuário/senha de *Release* e desmarcar **Export With Debug**.
- [ ] Habilitar **Gradle Build**: ele é obrigatório tanto para gerar AAB quanto para usar o plugin de Billing.
- [ ] Exportar **AAB** assinado. Apps novos enviados ao Play devem usar AAB; APK serve apenas para instalação/local QA.

Referência: [exportação Android no Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) e [build Gradle para Android](https://docs.godotengine.org/en/latest/tutorials/export/android_gradle_build.html).

### Compatibilidade Play

- [ ] Configurar `targetSdkVersion` **36 (Android 16)** para submissões de aplicativo novo e atualizações a partir de 31/08/2026. A exigência pode mudar; conferir a política antes de cada envio.
- [ ] Instalar o AAB em um aparelho real e validar orientação retrato, toque, desempenho, pausa/retorno e salvamento.

Referência: [política de nível de API do Google Play](https://support.google.com/googleplay/android-developer/answer/11926878) e [requisitos de target SDK](https://developer.android.com/google/play/requirements/target-sdk).

## 2. Preparar a distribuição no Play Console

- [ ] Criar/verificar a conta de desenvolvedor e cadastrar o app com o mesmo `package name` usado no AAB.
- [ ] Completar listagem: nome, descrição curta/completa, ícone, capturas de tela, categoria, e-mail de suporte e política de privacidade publicada em URL acessível.
- [ ] Preencher **App content**: Data safety, anúncios, público-alvo, classificação de conteúdo e instruções de acesso para a revisão, se aplicável.
- [ ] Publicar primeiro na faixa de **teste interno**; depois em fechado/aberto conforme o plano de QA.
- [ ] Se a conta pessoal foi criada após 13/11/2023: manter teste fechado com pelo menos 12 pessoas inscritas continuamente por 14 dias e solicitar acesso à produção.

Referência: [preparar o app para revisão](https://support.google.com/googleplay/android-developer/answer/9859455) e [requisito de testes para contas pessoais](https://support.google.com/googleplay/android-developer/answer/14151465).

## 3. Ligar pagamentos: desbloqueio permanente

Para remover anúncios, desbloquear coleção premium ou liberar conteúdo permanentemente, usar um **one-time product não consumível**. Ele é vinculado à conta Google do cliente e não pode ser comprado novamente por ela.

### Console e recebimento de valores

- [ ] Confirmar que o Brasil/país de operação aceita registro de comerciante e que a empresa/pessoa possui conta bancária elegível.
- [ ] No Play Console, criar ou vincular o **Google Payments profile / merchant account**, informar dados legais/fiscais e método de recebimento.
- [ ] Em **Monetize with Play > Products > One-time products**, criar o produto.
- [ ] Usar um ID permanente e em minúsculas, por exemplo `premium_unlock`; IDs não podem ser reutilizados.
- [ ] Definir nome, descrição, disponibilidade regional, preço e uma opção de compra do tipo **Buy**; ativar o produto.
- [ ] Usar o Google Play Billing para itens digitais vendidos no app distribuído pelo Google Play, salvo exceções/programas regionais expressamente aplicáveis.

Referência: [perfil de pagamentos e conta de comerciante](https://support.google.com/googleplay/android-developer/answer/3092739), [países aceitos para desenvolvedor/comerciante](https://support.google.com/googleplay/android-developer/answer/9306917), [produtos de compra única no Console](https://support.google.com/googleplay/android-developer/answer/16430488) e [o que é produto não consumível](https://developer.android.com/google/play/billing/one-time-products).

### Integração no Godot

- [ ] Instalar a versão atual do plugin oficial [GodotGooglePlayBilling](https://github.com/godot-sdk-integrations/godot-google-play-billing) em `addons/GodotGooglePlayBilling`.
- [ ] Ativá-lo em **Project Settings > Plugins** e usar a exportação Gradle.
- [ ] Usar versão de Play Billing suportada no momento do envio (Billing Library 7 não é aceita para novos envios após 31/08/2026; usar a versão atual do plugin/Billing).
- [ ] Ao abrir ou retornar ao jogo: iniciar `BillingClient`, consultar compras já existentes e recuperar os desbloqueios.
- [ ] Antes de exibir/comprar: consultar `ProductDetails` do produto `INAPP`; não manter detalhes antigos em cache.
- [ ] Iniciar a compra somente a partir do resultado atual dessa consulta.
- [ ] Conceder `premium_unlock` somente para compra com estado `PURCHASED` — nunca para `PENDING`.
- [ ] Registrar a titularidade pelo usuário do jogo e também recuperar compras da conta Google ao reinstalar/trocar de aparelho.
- [ ] Após validar e conceder a titularidade, reconhecer a compra com **acknowledge**. Para não consumível, **não** chamar `consume`.
- [ ] Reconhecer em até três dias após o estado `PURCHASED`; caso contrário, o Google reembolsa e revoga a compra.

Referência: [compras in-app no Godot](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html), [integração da Play Billing Library](https://developer.android.com/google/play/billing/integrate) e [fim de suporte de versões do Billing](https://developer.android.com/google/play/billing/deprecation-faq.html).

## 4. Arquitetura segura recomendada

Para um protótipo, o reconhecimento pode ocorrer no cliente. Para lançamento comercial, implementar um backend mínimo é a opção recomendada:

1. O app envia o `purchaseToken`, o ID do produto e a conta interna para o servidor.
2. O servidor consulta a Google Play Developer API para validar token, produto, estado e reconhecimento.
3. Só então persiste a titularidade `premium_unlock` no perfil do jogador.
4. O servidor reconhece a compra pelo endpoint `Purchases.products:acknowledge`.
5. Configurar **Real-time Developer Notifications (RTDN)** para manter a titularidade sincronizada e reagir a cancelamentos/reembolsos.

Não usar `orderId` como chave de deduplicação; usar o token de compra. O backend reduz fraudes, duplicação de benefícios e falhas causadas por perda de rede no aparelho.

Referência: [segurança e prevenção a abuso](https://developer.android.com/google/play/billing/security), [integração com backend](https://developer.android.com/google/play/billing/backend) e [ciclo de vida de compra única](https://developer.android.com/google/play/billing/lifecycle/one-time).

## 5. Checklist de testes antes de produção

- [ ] Adicionar contas de QA como **license testers** no Play Console.
- [ ] Subir AAB em teste interno/fechado com o mesmo pacote final.
- [ ] Testar compra aprovada, cancelada e pendente; em pendente não liberar premium.
- [ ] Testar reiniciar o jogo, reinstalar e trocar de aparelho: o premium deve ser restaurado para a mesma conta Google.
- [ ] Testar compra já reconhecida: não conceder duas vezes e não tentar comprá-la de novo.
- [ ] Testar sem conexão após o pagamento e reconciliação ao abrir/retornar ao app.
- [ ] Validar a tela de sucesso, tela de erro e restauração de compras em Android físico.
- [ ] Conferir produto ativo, preço e regiões antes do rollout de produção.

Referência: [testar a integração Google Play Billing](https://developer.android.com/google/play/billing/test).

## Ordem recomendada de execução

1. Criar chave de release, preset Android e AAB assinado.
2. Criar o app no Play Console e enviar à faixa interna.
3. Configurar o perfil de pagamentos/conta de comerciante.
4. Criar e ativar `premium_unlock` como produto de compra única **Buy**.
5. Integrar o plugin oficial e armazenar a titularidade no perfil do jogador.
6. Validar com license testers; adicionar backend/RTDN antes do lançamento comercial.
7. Completar App content e abrir o rollout de produção.
