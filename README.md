# Jogo da Velha

Aplicativo Flutter do clássico **Jogo da Velha** (Tic-Tac-Toe), com partida local e multiplayer online na mesma rede.

<p align="center">
  <img height="320" alt="Menu" src="https://github.com/user-attachments/assets/c3e73319-f8f0-4740-9d0b-5a841d11ef72" />
  <img height="320" alt="Jogo local" src="https://github.com/user-attachments/assets/724b8b9b-351d-4830-97db-802742d9f253" />
  <img height="320" alt="Partida online" src="https://github.com/user-attachments/assets/56cb5aa1-7098-42ee-8b3a-d46f68974fc4" />
</p>

---

## O que é?

O jogo da velha é um jogo de estratégia para dois jogadores em um tabuleiro 3×3. Cada jogador usa **X** ou **O**, alternando turnos. Vence quem formar primeiro uma linha, coluna ou diagonal com três marcas iguais. Se o tabuleiro encher sem vencedor, o resultado é **empate**.

---

## Funcionalidades

| Recurso | Descrição |
|--------|-----------|
| **Partida local** | Dois jogadores no mesmo dispositivo, com rodadas e tempo limite configuráveis |
| **Partida online** | Multiplayer na mesma rede: um dispositivo cria a sala (host) e outro entra via QR Code ou IP |
| **Deep links** | Navegação via links para telas específicas (ex.: entrar em sala por link) |
| **Internacionalização** | Suporte a PT-BR e EN |
| **Tema** | Light/Dark conforme preferência do sistema |

---

## Como funciona o modo online (host autoritativo)

No modo online, o jogo opera em **rede local (Wi‑Fi)** usando **TCP sockets**. O fluxo foi desenhado no modelo **host autoritativo**:

- **Host (X)**: é o “dono” do estado do jogo. Ele **valida** e **aplica** todas as jogadas (as dele e as do cliente), atualiza placar/rodadas e **envia o estado completo** para o outro dispositivo.
- **Cliente (O)**: não altera o estado do jogo localmente. Ele apenas **solicita jogadas** ao host e **renderiza** o estado que o host envia.

### Componentes e responsabilidades

- **UI**: `OnlineGameScreen`
  - Controla interação do usuário (toque no tabuleiro) e exibe “**Sua vez**”/“**Aguardando**”.
  - Mantém um booleano local `_isMyTurn` para bloquear cliques fora do turno.
- **Regras do jogo + coordenação**: `OnlineGameViewModel`
  - Aplica regras de jogada (`makeMove`, `makeMoveWithPlayer`), detecta vitória/empate e troca `currentPlayer`.
  - Recebe eventos da rede via callbacks do repositório e atualiza o modelo `_game`.
- **Transporte/serialização**: `GameRepository` (+ DTO)
  - Converte mensagens JSON ↔️ modelo (`OnlineTicTacToeGameDTO`).
  - Roteia mensagens por `type` para callbacks: `gameState`, `requestMove`, `reset`, `nextRound`, `config`.
- **Socket TCP**: `NetworkService`
  - Host abre um servidor TCP na porta `8080`.
  - Cliente conecta no IP do host e recebe/envia mensagens.

### Mensagens trocadas na rede

As mensagens são strings JSON com o campo `type`:

- **`gameState`**: estado completo do jogo (tabuleiro, `currentPlayer`, placares, rodada, etc.).
- **`requestMove`**: pedido do cliente para jogar em `row`/`col`.
- **`reset`**: reinicia placar e rodada.
- **`nextRound`**: avança para a próxima rodada.
- **`config`**: configuração (ex.: `maxRounds`).

### Fluxo de jogadas (passo a passo)

#### Quando é a vez do host (X)

1. Host toca na célula.
2. A UI chama `viewModel.makeMove(row, col)` (a jogada é aplicada no host).
3. Host envia `gameState` com `sendCurrentGameState()`.
4. Cliente recebe `gameState` → `onGameStateReceived` → atualiza o tabuleiro e o placar.

#### Quando é a vez do cliente (O)

1. Cliente toca na célula.
2. A UI **não** aplica localmente; ela envia `requestMove` via `sendRequestMove(row, col)`.
3. Host recebe `requestMove` → valida se é válido (vez do O, casa vazia, jogo não acabou).
4. Host aplica a jogada com `makeMoveWithPlayer(row, col, PlayerEnum.o)` e envia `gameState`.
5. Cliente recebe `gameState` e atualiza a UI.

> Importante: o host **não recebe** a própria mensagem `gameState` que ele acabou de enviar. Por isso, quando o host processa `requestMove`, o ViewModel também dispara `onGameStateReceived` localmente para manter a UI do host sincronizada.

### “Sua vez” vs “Aguardando” (como o app decide)

Em ambos os dispositivos, a vez é derivada de:

- `myPlayer` (X no host, O no cliente)
- `game.currentPlayer` (quem deve jogar agora)

A regra usada pela UI é:

> `_isMyTurn = (game.currentPlayer == myPlayer)`

Isso evita inconsistência entre o AppBar/placar e o bloqueio de cliques, inclusive em transições como `nextRound`, `reset` e recebimento de `gameState`.

### Início da partida

Na primeira rodada, quem começa é sempre o **Host (X)**. O estado inicial do jogo é configurado para `currentPlayer = X` em ambos os dispositivos para que o placar já destaque corretamente quem inicia.

---

## Stack e requisitos

- **Flutter** (SDK **Dart ^3.9.2**)
- **Principais dependências:**
  - `network_info_plus` – IP local e rede
  - `flutter_svg` – ícones SVG
  - `qr_native_bridge` – geração/leitura de QR Code (repositório privado)
  - `flutter_design_system` – componentes e tema (repositório privado)

**Requisitos para partida online:** os dois dispositivos na mesma rede Wi‑Fi.

---

## Arquitetura

O projeto segue **Clean Architecture** com camadas bem definidas:

```
lib/
├── app/                    # Tema e configurações globais
├── domain/                 # Regras de negócio (sem dependência de Flutter)
│   ├── constants/
│   ├── enums/
│   ├── interfaces/         # Contratos (repositories, services, channels)
│   └── models/
├── data/                   # Implementações e fontes de dados
│   ├── channels/           # Deep links (plataforma → app)
│   ├── models/
│   ├── repositories/
│   └── services/           # Rede, QR Code, etc.
├── presentation/           # UI e estado da tela
│   ├── navigation/
│   ├── screens/
│   └── ...
├── l10n/                   # Localizações (pt, en)
└── main.dart
```

- **Domain:** interfaces (`IGameRepository`, `INetworkService`, etc.), enums (`PlayerEnum`, `RoutesEnum`, `ConnectionStatusEnum`), modelos de domínio.
- **Data:** implementações concretas (TCP/sockets para rede, repositório que orquestra rede + QR), modelos de dados, canais de deep link.
- **Presentation:** telas (Menu, Splash, Jogo Local, Jogo Online, Scanner QR), ViewModels para lógica de UI, componentes reutilizáveis (tabuleiro, célula, placar, overlay de vitória).

A injeção de dependências é feita manualmente no `main.dart` e em `onGenerateRoute` (ex.: `GameRepository(networkService: NetworkService(), qrCodeGeneratorService: QrCodeGeneratorService())`).

---

## Como executar

1. **Pré-requisitos:** Flutter instalado e configurado ([flutter.dev](https://flutter.dev)).
2. **Clone e dependências:**
   ```bash
   git clone <url-do-repositorio>
   cd Jogo-da-velha
   flutter pub get
   ```
3. **Rodar o app:**
   ```bash
   flutter run
   ```
   Para um dispositivo específico: `flutter run -d <device_id>` (use `flutter devices` para listar).

**Nota:** As dependências `qr_native_bridge` e `flutter_design_system` vêm de repositórios Git privados; é necessário ter acesso e chave SSH configurada para o `flutter pub get` funcionar.

---

## Estrutura das rotas

| Rota | Descrição |
|------|-----------|
| `/` | Splash (inicialização e tratamento de deep link) |
| `/menu` | Menu principal (local vs online) |
| `/local-game` | Partida local (argumentos: `maxRounds`, `timeLimitSeconds`) |
| `/online-game` | Partida online (argumentos: `playerRole`: `PlayerRole.host` ou `PlayerRole.guest`) |

---

## Regras do jogo (resumo)

- **Tabuleiro:** 3×3 (9 posições).
- **Turnos:** X e O alternam, uma jogada por vez em casa vazia.
- **Vitória:** 3 marcas iguais em linha (horizontal), coluna (vertical) ou diagonal.
- **Empate:** tabuleiro cheio sem vencedor.

---

## Agentes DevOps (Cursor/CI/Git)

O projeto agora possui uma base de automacao para acelerar desenvolvimento com seguranca:

- **CI de qualidade:** workflow em `.github/workflows/ci.yml` executa `flutter pub get`, `flutter analyze` e `flutter test` em PR/push para `main`.
- **Regra de qualidade:** `.cursor/rules/quality-guard/RULE.md` orienta o guardiao a reportar falhas objetivas e manter correcoes de baixo risco.
- **Regra arquitetural:** `.cursor/rules/architecture-check/RULE.md` valida separacao `domain/data/presentation` e uso de ViewModel.
- **Checklist de revisao:** `docs/agent-checklists/architecture.md` padroniza revisao de arquitetura antes de merge.
- **Skill de scaffold:** `.cursor/skills/feature-scaffold/SKILL.md` gera `screen + view_model + rota + wiring` no modo seguro.
- **Template de uso:** `docs/templates/feature-scaffold.md` traz prompt e criterios de aceite para novas features.

### Sequencia recomendada no dia a dia
1. Criar/atualizar feature com a skill `feature-scaffold`.
2. Validar arquitetura com checklist em `docs/agent-checklists/architecture.md`.
3. Abrir PR e deixar o CI bloquear regressao basica.
4. Fazer ajustes pequenos sugeridos pelos agentes antes do merge.

---

## Licença

Este projeto não está publicado no pub.dev (`publish_to: "none"` no `pubspec.yaml`). Consulte o repositório para informações de uso e licença.
