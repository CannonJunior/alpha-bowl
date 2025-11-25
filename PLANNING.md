# Alpha Bowl - Planning Document

## Project Overview

**Alpha Bowl** is a real-time 3D American Football video game with RPG progression mechanics, built using Flutter and WebGL. The project adapts the proven architecture from the Warchief RPG game, transforming combat mechanics into football gameplay while retaining character progression, AI systems, and strategic depth.

---

## Design Principles

### 1. Reuse Over Rewrite
- Maximum code reuse from Warchief codebase
- Adapt existing systems rather than building from scratch
- Proven patterns: systems-based architecture, centralized state, WebGL rendering

### 2. Configuration Over Code
- **NEVER HARDCODE VALUES** - all game parameters in config files
- Easy balancing and iteration
- Modding support potential

### 3. Clarity Over Cleverness
- Clear, readable code
- Consistent naming conventions
- Comprehensive documentation

### 4. Performance First
- Target: 60 FPS with 22 players
- Delta-time based game loop
- Efficient rendering (mesh caching, culling)

---

## Architecture Patterns

### Systems-Based Architecture (ECS-like)

**Why**: Warchief proves this pattern works well for real-time games

```
GameState (centralized data)
    ↓
Systems (functional processors)
    ↓
Rendering (3D visualization)
```

**Benefits**:
- Clear separation of concerns
- Easy to test individual systems
- Minimal coupling between components
- Simple to add new features

### Centralized Game State

**Pattern**: Single mutable `GameState` class holds all game data

**Why**:
- Single source of truth
- Easy to serialize for save/load
- Simple to pass to systems
- No complex state synchronization

**Trade-offs**:
- Can become large (mitigate with sub-objects)
- Requires discipline to avoid spaghetti code

### Functional Systems

**Pattern**: Systems are static utility classes that modify `GameState`

```dart
class PlaySystem {
  static void update(double dt, GameState state) {
    // Pure logic, no instance state
    // Modify state directly
  }
}
```

**Why**:
- No dependency injection needed
- Easy to understand call flow
- Testable (pass in mock GameState)

---

## File Organization

### Directory Structure

```
lib/
├── main.dart                    # Entry point
├── game3d/                      # Main game logic
│   ├── game3d_widget.dart       # Game loop & initialization
│   ├── state/                   # Centralized state
│   │   ├── game_state.dart
│   │   ├── game_config.dart
│   │   ├── plays_config.dart
│   │   ├── formations_config.dart
│   │   ├── attributes_config.dart
│   │   └── progression_config.dart
│   ├── systems/                 # Functional systems
│   │   ├── input_system.dart
│   │   ├── physics_system.dart
│   │   ├── play_system.dart
│   │   ├── player_ai_system.dart
│   │   ├── gameplay_system.dart
│   │   ├── progression_system.dart
│   │   └── render_system.dart
│   └── ui/                      # Flutter UI overlays
│       ├── scoreboard.dart
│       ├── play_selection_hud.dart
│       ├── player_stats_panel.dart
│       ├── formation_selector.dart
│       └── minimap.dart
├── models/                      # Data models (entities)
│   ├── player.dart
│   ├── ball.dart
│   ├── team.dart
│   ├── play.dart
│   ├── formation.dart
│   ├── skill_tree.dart
│   └── game_action.dart
├── rendering3d/                 # 3D rendering engine
│   ├── webgl_renderer.dart
│   ├── camera3d.dart
│   ├── mesh.dart
│   ├── shader_program.dart
│   └── math/
│       ├── transform3d.dart
│       └── bezier_path.dart
├── controllers/                 # Input handling
│   └── input_manager.dart
└── utils/                       # Shared utilities
    ├── collision_detection.dart
    ├── visual_effects.dart
    └── animation_utils.dart
```

### File Size Limits

**Rule**: No file should exceed 500 lines of code

**Why**: Maintainability, readability, focused responsibility

**How**: Split large files into:
- `system_name.dart` - Main logic
- `system_name_helpers.dart` - Helper functions
- `system_name_config.dart` - Configuration constants

---

## Naming Conventions

### Files
- `snake_case.dart` - All Dart files
- Match class name: `class GameState` → `game_state.dart`

### Classes
- `PascalCase` - All classes, enums
- Descriptive names: `PlayerAISystem`, `FormationType`

### Variables & Functions
- `camelCase` - Variables, functions, parameters
- Clear intent: `calculateTackleSuccess()`, `throwBall()`

### Constants
- `SCREAMING_SNAKE_CASE` - Top-level constants
- `camelCase` - Class-level constants in config files

### Enums
- Enum name: `PascalCase`
- Enum values: `camelCase`

```dart
enum PlayerState {
  idle,
  running,
  tackling,
  beingTackled,
}
```

---

## Coding Standards

### Type Safety
- Always use type annotations
- Leverage Dart's null safety
- Avoid `dynamic` unless absolutely necessary

```dart
// Good
Player findPlayerByNumber(int number, List<Player> players) {
  return players.firstWhere((p) => p.number == number);
}

// Bad
findPlayerByNumber(number, players) {
  return players.firstWhere((p) => p.number == number);
}
```

### Documentation
- **Docstrings for every public function** (Google style)
- Inline comments for non-obvious logic
- `// Reason:` comments for "why" not "what"

```dart
/// Calculates tackle success probability based on attributes.
///
/// Takes into account tackler's strength/tackling vs carrier's
/// agility/strength. Returns probability from 0.0 to 1.0.
///
/// Args:
///   tackler: The player attempting the tackle.
///   carrier: The player carrying the ball.
///
/// Returns:
///   double: Probability of successful tackle (0.0 - 1.0).
double calculateTackleSuccess(Player tackler, Player carrier) {
  // Reason: Agility helps ball carrier avoid tackles
  final carrierAvoidance = carrier.attributes.agility * 0.6 +
                           carrier.attributes.strength * 0.4;

  final tacklerPower = tackler.attributes.tackling * 0.7 +
                       tackler.attributes.strength * 0.3;

  return (tacklerPower / (tacklerPower + carrierAvoidance)).clamp(0.0, 1.0);
}
```

### Error Handling
- Use exceptions for exceptional cases
- Validate inputs at system boundaries
- Fail fast with meaningful messages

```dart
void snapBall(GameState state) {
  if (state.playState != PlayState.preSnap) {
    throw StateError('Cannot snap ball during ${state.playState}');
  }

  final qb = state.offensivePlayers.firstWhere(
    (p) => p.position == Position.QB,
    orElse: () => throw StateError('No QB on field'),
  );

  // ... proceed with snap
}
```

---

## Testing Strategy

### Unit Tests
- **Required for every system**
- Test each system in isolation
- Mock `GameState` as needed

```
tests/
├── systems/
│   ├── physics_system_test.dart
│   ├── gameplay_system_test.dart
│   └── player_ai_system_test.dart
├── models/
│   ├── player_test.dart
│   └── ball_test.dart
└── utils/
    └── collision_detection_test.dart
```

### Test Coverage
- Minimum 80% code coverage
- Focus on critical gameplay systems
- Edge cases for physics and AI

### Integration Tests
- Full play execution
- End-to-end game flow
- Performance benchmarks

---

## Development Workflow

### Phase-Based Development

**Phase 1: Foundation** (Current)
- Set up project structure
- Port core Warchief systems
- Football field rendering
- Basic player movement

**Phase 2: Core Gameplay**
- Play system
- AI behaviors
- Tackle/catch mechanics
- Ball physics

**Phase 3: RPG Systems**
- Player attributes
- Progression system
- Skill trees
- Special abilities

**Phase 4: Polish**
- Enhanced visuals
- Effects and animations
- UI/UX refinement

**Phase 5: Game Modes**
- Full game mode
- Season mode
- Career mode

### Iteration Cycle

1. **Plan** - Define feature requirements
2. **Implement** - Write code following standards
3. **Test** - Unit and integration tests
4. **Review** - Code review checklist
5. **Refine** - Address feedback, optimize

---

## Configuration Management

### Config File Strategy

All game parameters stored in dedicated config files:

#### `game_config.dart`
```dart
class GameConfig {
  // Field dimensions
  static const double fieldLength = 100.0; // yards
  static const double fieldWidth = 53.33; // yards
  static const double endZoneDepth = 10.0; // yards

  // Physics
  static const double gravity = 9.8;
  static const double ballMass = 0.42; // kg

  // Game rules
  static const int quarterDuration = 900; // 15 minutes in seconds
  static const int timeoutsPerHalf = 3;
  static const int yardsForFirstDown = 10;
}
```

#### `plays_config.dart`
```dart
class PlaysConfig {
  static final Play hbDive = Play(
    name: "HB Dive",
    type: PlayType.run,
    formation: FormationsConfig.iFormation,
    routes: [...],
  );

  static final Play sluggoGo = Play(
    name: "Sluggo Go",
    type: PlayType.longPass,
    formation: FormationsConfig.shotgun,
    routes: [...],
  );

  // ... all plays defined here
}
```

### Configuration Validation

- Validate configs on app startup
- Throw descriptive errors for invalid values
- Log config values in debug mode

---

## Performance Optimization

### Target Metrics
- **60 FPS** constant frame rate
- **22 players** on field simultaneously
- **Sub-10ms** AI decision making
- **Smooth** camera transitions

### Optimization Strategies

1. **Mesh Caching**
   - Cache GPU buffers for meshes
   - Reuse meshes across players (team colors via uniforms)

2. **Update Frequencies**
   - Physics: 60 Hz (every frame)
   - AI: 30 Hz (every 2 frames)
   - UI: 10 Hz (every 6 frames)

3. **Culling**
   - Don't render off-screen players
   - Simplify far-away player meshes (LOD)

4. **Spatial Partitioning**
   - Grid-based for collision detection
   - Only check nearby players for tackles

---

## Camera Design

### Camera Modes

1. **Follow Ball** (Default)
   - Third-person behind ball carrier
   - Smooth interpolation
   - Dynamic height based on speed

2. **Strategic Overhead**
   - Bird's eye view
   - See entire formation
   - Good for play calling

3. **Sideline View**
   - TV broadcast style
   - Fixed height, tracks ball
   - Cinematic feel

4. **End Zone View**
   - Behind offense looking downfield
   - Good for passing plays

### Camera Transitions
- Smooth lerp between modes (1-2 seconds)
- Maintain orientation consistency
- User can manually switch with V key

---

## Input Design

### Control Scheme

**Offense (with ball)**:
- `W/A/S/D` - Movement
- `Shift` - Sprint
- `Space` - Juke/spin
- `E` - Dive
- `1-5` - Select receiver (when QB)
- `Mouse Click` - Throw to selected receiver

**Defense**:
- `W/A/S/D` - Movement
- `Shift` - Sprint
- `Space` - Tackle
- `E` - Swat ball
- `Q` - Strip ball attempt

**Universal**:
- `V` - Change camera mode
- `J/L` - Rotate camera
- `I/K` - Zoom camera
- `P` - Pause menu
- `O` - Play selection
- `F` - Use special ability

### Gamepad Support (Future)
- Left stick: Movement
- Right stick: Camera
- Triggers: Sprint/special moves
- Buttons: Actions (tackle, juke, pass)

---

## UI/UX Principles

### HUD Design
- **Minimal**: Don't obstruct 3D view
- **Clear**: Easy to read at a glance
- **Contextual**: Show relevant info for current play state

### Color Coding
- **Team Colors**: Clear distinction (blue vs red by default)
- **Status Indicators**: Green (good), yellow (warning), red (critical)
- **Highlight**: Selected player, ball carrier, targeted receiver

### Information Hierarchy
1. **Critical**: Score, time, down & distance
2. **Important**: Player stamina, special ability cooldown
3. **Contextual**: Play name, formation
4. **Detail**: Full player stats (toggle panel)

---

## AI Behavior Design

### Behavior Tree Structure

```
Root
├── Offensive Behaviors
│   ├── Route Running
│   │   ├── Follow waypoints
│   │   ├── Adjust for defender
│   │   └── Prepare for catch
│   ├── Blocking
│   │   ├── Engage defender
│   │   ├── Maintain position
│   │   └── Pancake block
│   └── Ball Carrier
│       ├── Follow blocks
│       ├── Break tackles
│       └── Score
└── Defensive Behaviors
    ├── Coverage
    │   ├── Man-to-man
    │   ├── Zone coverage
    │   └── Press coverage
    ├── Pursuit
    │   ├── Calculate angle
    │   ├── Avoid blocks
    │   └── Tackle
    └── Pass Rush
        ├── Beat blocker
        ├── Contain QB
        └── Sack
```

### Difficulty Scaling
- **Easy**: AI makes mistakes, slower reactions
- **Medium**: Balanced, realistic behavior
- **Hard**: Perfect execution, anticipates moves

---

## RPG Progression Design

### XP Gain Formula

```dart
int calculateXP(PlayerAction action, bool success) {
  final baseXP = {
    PlayerAction.tackle: 10,
    PlayerAction.catch: 15,
    PlayerAction.touchdown: 100,
    PlayerAction.sack: 25,
    PlayerAction.interception: 50,
    // ... other actions
  }[action] ?? 1;

  final successMultiplier = success ? 1.0 : 0.3;
  final difficultyMultiplier = _getDifficultyMultiplier();

  return (baseXP * successMultiplier * difficultyMultiplier).round();
}
```

### Level-Up Curve

- Level 1-10: 100 XP per level (linear)
- Level 10-20: Exponential curve
- Level 20+: Asymptotic (diminishing returns)

```dart
int xpRequiredForLevel(int level) {
  if (level <= 10) {
    return level * 100;
  } else if (level <= 20) {
    return 1000 + ((level - 10) * (level - 10) * 50);
  } else {
    return 6000 + ((level - 20) * 200);
  }
}
```

### Skill Point Allocation

- 1 skill point per level
- Can allocate to any unlocked skill
- Skills have prerequisites (skill tree)
- Max 5 levels per skill

---

## Multiplayer Considerations (Future)

### Architecture
- Client-server model
- Server authoritative (prevent cheating)
- Client-side prediction for responsiveness

### Networking
- WebSocket for real-time communication
- State synchronization (player positions, ball)
- Input replay for lag compensation

**Note**: Not part of MVP, but architecture should not prevent future addition

---

## Port Configuration

**CRITICAL**: Application runs on **port 9009** (per CLAUDE.md)

```dart
// Configure in appropriate file
const int APP_PORT = 9009;
```

For web builds:
```bash
# Run development server
flutter run -d chrome --web-port 9009
```

---

## Version Control Strategy

### Branch Strategy
- `main` - Stable, deployable code
- `develop` - Integration branch
- `feature/feature-name` - Individual features
- `bugfix/bug-name` - Bug fixes

### Commit Messages
```
type(scope): Brief description

Detailed explanation if needed.

Examples:
feat(gameplay): Add tackle mechanics
fix(ai): Correct route running timing
refactor(physics): Optimize ball trajectory calculation
docs(readme): Update installation instructions
```

### Code Review Checklist
- [ ] Follows naming conventions
- [ ] Has docstrings for public functions
- [ ] Includes unit tests
- [ ] No hardcoded values
- [ ] Performance considerations addressed
- [ ] No files >500 lines

---

## Documentation Requirements

### Required Docs
- [x] `README.md` - Project overview, setup instructions
- [x] `ARCHITECTURE.md` - Detailed technical architecture
- [x] `PLANNING.md` - This document
- [x] `TASK.md` - Task tracking
- [ ] `API.md` - Public API reference (when applicable)

### Code Documentation
- Docstrings for all public classes/functions
- Inline comments for complex logic
- `// TODO:` for future improvements
- `// FIXME:` for known issues

---

## Accessibility Considerations

### Visual
- Colorblind-friendly team colors (option)
- High-contrast mode
- Adjustable text size

### Controls
- Remappable keys
- Gamepad support
- Simplified control scheme option

### Difficulty
- Multiple AI difficulty levels
- Adjustable game speed
- Practice mode with no penalties

---

## Next Steps

1. **Initialize Flutter Project**
   ```bash
   flutter create alpha_bowl
   cd alpha_bowl
   ```

2. **Port Warchief Core**
   - Copy rendering3d/ directory
   - Copy game3d/systems/ (adapt as needed)
   - Copy controllers/input_manager.dart

3. **Create Foundation**
   - Implement models (Player, Ball, Team, etc.)
   - Create game_config.dart
   - Set up game_state.dart

4. **Build MVP**
   - Football field rendering
   - Basic player movement
   - Simple play execution
   - Minimal AI (follow routes)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-23
**Next Review**: After Phase 1 completion
