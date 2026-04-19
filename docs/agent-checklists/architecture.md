# Checklist Arquitetural para Agentes

Use este checklist ao revisar PRs e implementacao de novas features.

## 1) Separacao de camadas
- [ ] `domain` permanece sem dependencia de Flutter.
- [ ] `data` concentra implementacoes tecnicas (rede/servicos/repositorios).
- [ ] `presentation` concentra telas, componentes e ViewModels.

## 2) Contratos e implementacoes
- [ ] Toda implementacao em `data` referencia uma interface em `domain/interfaces`.
- [ ] Nao ha acoplamento direto da UI com servicos de infraestrutura.

## 3) Estado e fluxo de tela
- [ ] Tela delega regras para o ViewModel.
- [ ] ViewModel expoe estado e operacoes de forma consistente.
- [ ] Mudancas no fluxo online mantem host autoritativo e sincronizacao de estado.

## 4) Rotas e injecao de dependencias
- [ ] Nova tela foi adicionada ao fluxo de rotas com padrao existente.
- [ ] Injecao de dependencias foi feita de forma explicita e localizada.

## 5) Risco e governanca
- [ ] Mudancas extensas de arquitetura foram sinalizadas para confirmacao humana.
- [ ] Remocoes de arquivos ou alteracoes globais foram justificadas no PR.
- [ ] `flutter analyze` e `flutter test` executam sem falhas.
