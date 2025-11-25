# Alpha Bowl

**Real-Time 3D American Football Game with RPG Mechanics**

A strategic football simulation featuring player progression, team management, and tactical gameplay built with Flutter and WebGL.

---

## Overview

Alpha Bowl combines the excitement of real-time American Football with RPG-style character progression. Control your team, execute plays, develop players through experience and skill trees, and compete in immersive 3D gameplay.

### Key Features

- **Real-Time 3D Gameplay**: Powered by Flutter + WebGL rendering
- **RPG Progression**: Level up players, unlock skills, use special abilities
- **Strategic Depth**: Multiple formations, plays, and tactical decisions
- **AI-Controlled Players**: 22 players on field with intelligent behaviors
- **Multiple Camera Modes**: Third-person, strategic overhead, sideline view
- **Team Management**: Customize rosters, develop players, build your dynasty

---

## Architecture

Built on a proven systems-based architecture adapted from the Warchief RPG game:

- **Systems-Based Design**: Functional systems (Physics, AI, Gameplay) operate on centralized state
- **WebGL Rendering**: Custom 3D renderer for smooth 60 FPS gameplay
- **Flutter UI**: Rich HUD and menu system overlaying 3D game
- **Configuration-Driven**: All game parameters in config files for easy balancing

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Technology Stack

- **Frontend**: Flutter 3.9.2+ (web target)
- **Rendering**: WebGL (custom implementation)
- **Language**: Dart
- **Math Library**: vector_math 2.1.4
- **State Management**: Direct state mutation (centralized GameState)
- **Development Port**: 9009 (as per project standards)

---

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── game3d/                      # Core game logic
│   ├── game3d_widget.dart       # Game loop & initialization
│   ├── state/                   # Game state & configuration
│   ├── systems/                 # Functional game systems
│   └── ui/                      # HUD and menu widgets
├── models/                      # Data models (Player, Ball, Team, etc.)
├── rendering3d/                 # 3D rendering engine
│   ├── webgl_renderer.dart
│   ├── camera3d.dart
│   ├── mesh.dart
│   └── math/                    # 3D math utilities
├── controllers/                 # Input handling
└── utils/                       # Shared utilities

tests/                           # Unit and integration tests
docs/                            # Additional documentation
```

---

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.0.0 or higher
- **Web Browser**: Chrome recommended (for WebGL support)

### Quick Start

**Recommended: Use the start script**
```bash
cd /home/junior/src/alpha_bowl
./start.sh
```

The start script will:
- Check and free port 9009 if needed
- Verify Flutter installation
- Install dependencies automatically
- Launch the game at `http://localhost:9009`

### Manual Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd alpha_bowl
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome --web-port 9009
   ```

4. **Open in browser**
   Navigate to `http://localhost:9009`

### Development Setup

**Verify Flutter installation:**
```bash
flutter doctor
```

**Run tests:**
```bash
flutter test
```

**Build for production:**
```bash
flutter build web
```

---

## Controls

### Player Movement
- `W` - Move forward
- `A` - Rotate left
- `S` - Move backward
- `D` - Rotate right
- `Shift` - Sprint
- `Space` - Juke/Spin/Tackle

### Passing (Quarterback)
- `1-5` - Select receiver
- `Click` - Throw to selected receiver
- `Q` - Pump fake

### Camera
- `V` - Toggle camera mode
- `J/L` - Rotate camera left/right
- `N/M` - Pitch camera up/down
- `I/K` - Zoom in/out

### Game Controls
- `P` - Pause menu
- `O` - Play selection
- `F` - Formation selector
- `R` - Use special ability

---

## Game Modes

### Quick Play (MVP)
Single offensive drive to practice mechanics and test gameplay.

### Full Game (Planned)
Complete 4-quarter game with full rules implementation.

### Season Mode (Planned)
Multiple games with player progression and team management.

### Career Mode (Planned)
RPG-focused mode building a player from rookie to legend.

---

## Development Roadmap

### Phase 1: Foundation ✅ (In Progress)
- [x] Project structure setup
- [x] Core architecture documentation
- [ ] Port Warchief rendering system
- [ ] Football field rendering
- [ ] Basic player movement

### Phase 2: Core Gameplay (Next)
- [ ] Play execution system
- [ ] AI behaviors (route running, pursuit)
- [ ] Ball physics (throwing, catching)
- [ ] Tackle mechanics
- [ ] Scoring system

### Phase 3: RPG Systems
- [ ] Player attributes
- [ ] Experience and leveling
- [ ] Skill trees
- [ ] Special abilities

### Phase 4: Polish
- [ ] Enhanced animations
- [ ] Visual effects
- [ ] Sound integration
- [ ] UI/UX refinement

### Phase 5: Extended Modes
- [ ] Full game mode
- [ ] Season mode
- [ ] Career mode scaffolding

---

## Configuration

All game parameters are stored in configuration files (never hardcoded):

- `game_config.dart` - Field dimensions, physics constants, rules
- `plays_config.dart` - Offensive and defensive plays
- `formations_config.dart` - Team formations and positions
- `attributes_config.dart` - Player attribute definitions and scaling
- `progression_config.dart` - XP curves and skill trees

### Example Configuration

```dart
// game_config.dart
class GameConfig {
  static const double fieldLength = 100.0; // yards
  static const double fieldWidth = 53.33;  // yards
  static const int quarterDuration = 900;  // 15 minutes
  static const double gravity = 9.8;
  // ... more config
}
```

---

## Testing

### Running Tests

**All tests:**
```bash
flutter test
```

**Specific test file:**
```bash
flutter test test/systems/physics_system_test.dart
```

**With coverage:**
```bash
flutter test --coverage
```

### Test Structure

```
tests/
├── systems/          # System-level tests
├── models/           # Data model tests
├── utils/            # Utility function tests
└── integration/      # End-to-end tests
```

### Test Requirements

- Minimum 80% code coverage
- Unit tests for all systems
- Integration tests for critical gameplay flows
- Performance benchmarks for 60 FPS target

---

## Performance Targets

- **Frame Rate**: 60 FPS constant
- **Players on Field**: 22 (11 vs 11)
- **AI Update Frequency**: 30 Hz
- **Physics Update Frequency**: 60 Hz
- **UI Update Frequency**: 10 Hz

---

## Contributing

### Code Standards

- **No Hardcoded Values**: All parameters in config files
- **Type Safety**: Full type annotations, leverage Dart null safety
- **Documentation**: Docstrings for all public functions (Google style)
- **File Size**: Maximum 500 lines per file
- **Naming**: `camelCase` for variables/functions, `PascalCase` for classes

### Commit Guidelines

```
type(scope): Brief description

Examples:
feat(gameplay): Add tackle mechanics
fix(ai): Correct route running timing
refactor(physics): Optimize ball trajectory
docs(readme): Update setup instructions
```

### Before Submitting

- [ ] Code follows naming conventions
- [ ] All public functions have docstrings
- [ ] Unit tests included
- [ ] No hardcoded values
- [ ] No files exceed 500 lines
- [ ] Tests pass (`flutter test`)

---

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed technical architecture
- **[PLANNING.md](PLANNING.md)** - Development planning and patterns
- **[TASK.md](TASK.md)** - Task tracking and progress

---

## Port Configuration

This application runs on **port 9009** by default (as per project standards).

```bash
flutter run -d chrome --web-port 9009
```

Access at: `http://localhost:9009`

---

## Known Issues

_None yet - project in early development_

---

## Future Enhancements

- Gamepad/controller support
- Multiplayer (local and online)
- Advanced animations and cutscenes
- Weather effects (rain, snow, wind)
- Replay system with camera controls
- Custom team/player creation
- Modding support
- Achievement system

---

## License

_To be determined_

---

## Credits

**Architecture Based On**: Warchief RPG (systems-based 3D game architecture)

**Developed By**: Claude Code

**Project Start**: 2025-11-23

---

## Contact

For questions, issues, or feature requests, please use the project's issue tracker.

---

**Version**: 0.1.0-alpha
**Status**: Early Development
**Last Updated**: 2025-11-23
