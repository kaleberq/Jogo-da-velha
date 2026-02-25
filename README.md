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
| `/online-game` | Partida online (argumentos: `isHost`) |

---

## Regras do jogo (resumo)

- **Tabuleiro:** 3×3 (9 posições).
- **Turnos:** X e O alternam, uma jogada por vez em casa vazia.
- **Vitória:** 3 marcas iguais em linha (horizontal), coluna (vertical) ou diagonal.
- **Empate:** tabuleiro cheio sem vencedor.

---

## Licença

Este projeto não está publicado no pub.dev (`publish_to: "none"` no `pubspec.yaml`). Consulte o repositório para informações de uso e licença.
