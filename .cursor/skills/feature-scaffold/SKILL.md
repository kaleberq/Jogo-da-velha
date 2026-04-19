---
name: feature-scaffold
description: Gera scaffold de feature Flutter com screen, view_model, rota e wiring no padrao do projeto. Use quando criar nova tela/feature e quando o usuario pedir boilerplate com baixo risco.
---

# Feature Scaffold

Skill para acelerar criacao de feature no projeto com padrao consistente e risco controlado.

## Quando usar
- Nova tela no fluxo de jogo.
- Nova feature com estado local via ViewModel.
- Necessidade de gerar estrutura inicial sem mexer em logica sensivel.

## Saida esperada
- Arquivo `screen` no caminho correto de `presentation/screens/...`.
- Arquivo `view_model` com estado e metodos iniciais.
- Registro de rota e wiring em `lib/main.dart` quando solicitado.
- TODOs tecnicos no codigo para completar regras de negocio.
- Textos de UI usando localizacao do projeto (sem hardcode).

## Modo seguro (obrigatorio)
- Criar arquivos e estrutura basica primeiro.
- Nao alterar logica sensivel existente sem confirmacao explicita.
- Nao remover arquivos existentes automaticamente.
- Em mudancas de rota, aplicar alteracao minima e isolada.
- Regras de estado/fluxo ficam no ViewModel; screen apenas renderiza e delega acoes.

## Passo a passo
1. Identificar nome da feature e caminho alvo em `presentation/screens`.
2. Criar `*_view_model.dart` com `ChangeNotifier` e estado inicial.
3. Criar `*_screen.dart` com construtor recebendo o ViewModel.
4. Se pedido, adicionar rota em `RoutesEnum` e wiring em `main.dart`.
5. Inserir TODOs objetivos para pontos pendentes.
6. Rodar validacao com `flutter analyze`.

## Padrao de naming
- Arquivos em snake_case.
- Classes em PascalCase.
- Sufixos obrigatorios: `Screen` e `ViewModel`.

## Template rapido de ViewModel
```dart
class NewFeatureViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

## Checklist final
- Estrutura de pastas respeita Clean Architecture.
- Wiring de rota compila sem quebrar rotas existentes.
- Codigo novo possui TODOs apenas onde necessario.
- Nenhum texto de interface esta hardcoded.
- Regras de tela foram mantidas no ViewModel.
