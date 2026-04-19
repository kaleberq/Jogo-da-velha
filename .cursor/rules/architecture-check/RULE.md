---
description: Reviewer arquitetural para Clean Architecture no Flutter.
alwaysApply: true
---

# Architecture Check

Use esta regra ao revisar novas features, correcoes e refactors.

## Regras por camada

### Domain
- Nao pode depender de Flutter.
- Deve conter modelos de negocio, enums e interfaces.
- Interfaces devem descrever contratos sem detalhes de implementacao.

### Data
- Implementa contratos definidos em `domain/interfaces`.
- Concentra acesso a rede, serializacao e infraestrutura.
- Nao deve conter widgets ou detalhes de UI.

### Presentation
- Contem telas, componentes de UI e ViewModels.
- Regras de interface devem ficar no ViewModel da tela.
- A tela dispara acoes e renderiza estado; nao centraliza regra de negocio pesada.
- Textos de UI nao devem ser hardcoded; usar localizacao do projeto (`context.l10n`).

## Wiring e composicao
- Construcao de dependencias ocorre no `main.dart` e roteamento.
- Novas telas devem seguir o padrao de injecao manual ja existente.

## Checklist de revisao da mudanca
1. A feature respeita separacao `domain -> data -> presentation`.
2. Nenhuma dependencia de Flutter foi adicionada em `domain`.
3. Repositorios em `data` implementam interfaces de `domain`.
4. Fluxo da tela usa ViewModel para estado e eventos.
5. Textos da interface seguem localizacao (sem hardcode).
6. Mudancas de arquitetura global so avancam com confirmacao humana.

## Resposta esperada do agente
- Apontar violacao com caminho do arquivo.
- Explicar impacto da violacao em 1-2 frases.
- Sugerir correcao localizada com baixo risco.
