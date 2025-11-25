# Alpha Bowl - Architecture Design Document
**Real-Time American Football Game with RPG Mechanics**

## Executive Summary

Alpha Bowl is a 3D real-time American Football video game built with Flutter and WebGL, featuring RPG-style player progression, team management, and strategic gameplay. The architecture is adapted from the Warchief RPG codebase, maintaining its proven systems-based design while transforming combat mechanics into football gameplay.

---

## 1. Architectural Mapping: Warchief → Alpha Bowl

### 1.1 Core System Transformations

| Warchief System | Alpha Bowl Equivalent | Transformation Details |
|----------------|----------------------|----------------------|
| **Combat System** | **Gameplay System** | Tackles, blocks, catches, interceptions |
| **Ability System** | **Play System** | Offensive/defensive plays, formations |
| **AI System** | **Player AI System** | AI-controlled players with football behaviors |
| **Character Stats** | **Player Attributes** | Speed, strength, agility, awareness, stamina |
| **XP/Leveling** | **Player Development** | Training, skill trees, performance bonuses |
| **Monster** | **Opposing Team** | AI-controlled enemy team |
| **Allies** | **Team Members** | Your 11 players on the field |
| **Projectiles** | **Ball Physics** | Football trajectory, throwing, kicking |
| **Terrain** | **Football Field** | 100-yard field with yard markers |

### 1.2 Retained Systems (Minimal Changes)

- **WebGL Renderer** - 3D rendering engine
- **Camera System** - Third-person and strategic views
- **Input Manager** - Keyboard/gamepad controls
- **Physics System** - Extended for ball dynamics
- **UI Layer** - Flutter widgets for HUD, menus, stats
- **Game Loop** - 60 FPS delta-time based

---

## 2. System Architecture

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   Game Screen (Widget)                 │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │              Game3D StatefulWidget              │  │  │
│  │  │                                                 │  │  │
│  │  │  ┌──────────────────────────────────────────┐  │  │  │
│  │  │  │         WebGL Canvas (3D View)           │  │  │
│  │  │  │  - Football Field                        │  │  │
│  │  │  │  - Players (22 total)                    │  │  │
│  │  │  │  - Ball Physics                          │  │  │
│  │  │  │  - Animations                            │  │  │
│  │  │  └──────────────────────────────────────────┘  │  │  │
│  │  │                                                 │  │  │
│  │  │  Flutter UI Overlays:                          │  │  │
│  │  │  - Scoreboard                                  │  │  │
│  │  │  - Play Selection HUD                          │  │  │
│  │  │  - Player Stats Panel                          │  │  │
│  │  │  - Formation Selector                          │  │  │
│  │  │  - Minimap                                     │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Systems (Functional)                      │
├─────────────────────────────────────────────────────────────┤
│  InputSystem      → Process player controls                  │
│  PhysicsSystem    → Ball trajectory, player movement         │
│  PlaySystem       → Execute offensive/defensive plays        │
│  PlayerAISystem   → Control AI player decisions              │
│  GameplaySystem   → Tackles, catches, scoring, penalties    │
│  RenderSystem     → 3D scene orchestration                   │
│  ProgressionSystem→ XP, leveling, skill improvements         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  Centralized Game State                      │
├─────────────────────────────────────────────────────────────┤
│  - 22 Player Entities (11 offense, 11 defense)              │
│  - Ball Entity (position, velocity, carrier)                │
│  - Game Clock & Score                                        │
│  - Current Play & Formation                                  │
│  - Player Stats & Progression                                │
│  - Team Configurations                                       │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Core Systems Detail

#### 2.2.1 GameplaySystem (formerly CombatSystem)

**Responsibilities:**
- Tackle detection and resolution
- Catch mechanics (timing, contested catches)
- Ball carrier physics
- Scoring detection (touchdowns, field goals, safeties)
- Penalty detection
- Fumble mechanics
- Interception logic

**Key Methods:**
```dart
class GameplaySystem {
  static void update(double dt, GameState state);

  // Tackle mechanics
  static bool attemptTackle(Player tackler, Player ballCarrier);
  static void resolveTackle(TackleResult result, GameState state);

  // Ball mechanics
  static bool attemptCatch(Player receiver, Ball ball);
  static void handleFumble(Player fumbler, GameState state);
  static void handleInterception(Player defender, Ball ball);

  // Scoring
  static bool checkTouchdown(Player ballCarrier, GameState state);
  static bool checkFieldGoal(Ball ball, GameState state);

  // Collision detection
  static bool checkPlayerCollision(Player p1, Player p2);
  static double calculateTackleSuccess(Player tackler, Player carrier);
}
```

#### 2.2.2 PlaySystem (formerly AbilitySystem)

**Responsibilities:**
- Play selection and execution
- Formation management
- Route running
- Play timing and coordination
- Audible calls

**Data Model:**
```dart
class Play {
  final String name;
  final PlayType type; // run, pass, kick, punt
  final Formation formation;
  final List<PlayerRoute> routes;
  final double executionTime;
  final Map<String, dynamic> parameters;
}

enum PlayType {
  run,
  shortPass,
  longPass,
  fieldGoal,
  punt,
  kickoff,
}

class PlayerRoute {
  final int playerNumber;
  final List<Vector3> waypoints;
  final double speed;
  final RouteType type; // straight, slant, post, corner, etc.
}

class Formation {
  final String name;
  final Map<int, Vector3> playerPositions; // Player number → field position
  final FormationType type; // shotgun, I-formation, etc.
}
```

#### 2.2.3 PlayerAISystem (formerly AISystem)

**Responsibilities:**
- AI player decision-making
- Route running precision
- Defensive coverage
- Blocking assignments
- Pursuit angles
- Zone/man coverage logic

**AI Behaviors:**
```dart
enum AIBehavior {
  // Offense
  runRoute,
  blockDefender,
  receivePass,
  runWithBall,

  // Defense
  manCoverage,
  zoneCoverage,
  rushPasser,
  pursueCarrier,

  // Special Teams
  kickCoverage,
  returnKick,
}

class PlayerAI {
  static void update(double dt, Player player, GameState state) {
    switch (player.currentBehavior) {
      case AIBehavior.runRoute:
        _executeRoute(player, state);
        break;
      case AIBehavior.pursueCarrier:
        _pursueBallCarrier(player, state);
        break;
      // ... other behaviors
    }
  }

  static void _executeRoute(Player player, GameState state) {
    // Follow assigned route with timing
    // Adjust for defensive pressure
    // Prepare for catch opportunity
  }

  static void _pursueBallCarrier(Player player, GameState state) {
    // Calculate pursuit angle
    // Adjust for blockers
    // Position for tackle
  }
}
```

#### 2.2.4 PhysicsSystem (Extended)

**New Capabilities:**
- Ball aerodynamics (spiral, wobble, wind)
- Player collision resolution
- Momentum-based tackles
- Stamina drain from movement

```dart
class PhysicsSystem {
  // Ball physics
  static void updateBallPhysics(double dt, Ball ball, GameState state) {
    // Apply gravity
    // Apply air resistance
    // Calculate spiral rotation
    // Check ground collision
  }

  // Player physics
  static void updatePlayerPhysics(double dt, Player player) {
    // Apply movement acceleration
    // Calculate stamina drain
    // Handle collisions with other players
    // Update animation state
  }

  // Collision detection
  static List<Collision> detectPlayerCollisions(List<Player> players);
  static bool checkBallCatchable(Player player, Ball ball);
}
```

---

## 3. Data Models

### 3.1 Player Entity

```dart
class Player {
  // Identity
  final int number;
  final String name;
  final Position position; // QB, RB, WR, TE, OL, DL, LB, CB, S, K, P
  final Team team;

  // 3D Representation
  Mesh mesh;
  Transform3d transform;
  double rotation;

  // Core Attributes (RPG Stats)
  PlayerAttributes attributes;

  // Game State
  double stamina;
  double maxStamina;
  bool hasBall;
  PlayerState state; // idle, running, blocking, tackling, etc.

  // AI
  AIBehavior currentBehavior;
  BezierPath? assignedRoute;
  Player? assignedTarget; // For blocking/coverage

  // Progression (RPG)
  int level;
  int experience;
  SkillTree skills;

  // Animation
  AnimationState currentAnimation;
  double animationTime;
}

class PlayerAttributes {
  // Physical (0-100 scale)
  double speed;       // Top speed
  double acceleration; // How fast they reach top speed
  double strength;    // Tackle power, blocking effectiveness
  double agility;     // Cutting, juking ability
  double jumping;     // Catching high balls, deflecting passes

  // Mental (0-100 scale)
  double awareness;   // React to plays, read defense
  double catching;    // Catch success rate
  double tackling;    // Tackle success rate
  double throwing;    // QB accuracy and power (if QB)
  double blocking;    // Block effectiveness
  double coverage;    // Defensive coverage ability
}

enum Position {
  // Offense
  QB,  // Quarterback
  RB,  // Running Back
  WR,  // Wide Receiver
  TE,  // Tight End
  OL,  // Offensive Line

  // Defense
  DL,  // Defensive Line
  LB,  // Linebacker
  CB,  // Cornerback
  S,   // Safety

  // Special Teams
  K,   // Kicker
  P,   // Punter
}

enum PlayerState {
  idle,
  running,
  blocking,
  tackling,
  beingTackled,
  catchingBall,
  throwingBall,
  celebrating,
  injured,
}
```

### 3.2 Ball Entity

```dart
class Ball {
  // 3D Representation
  Mesh mesh;
  Transform3d transform;

  // Physics
  Vector3 velocity;
  Vector3 angularVelocity; // Spiral rotation
  double spinRate;

  // State
  BallState state;
  Player? carrier;
  Player? thrower;
  Player? intendedReceiver;

  // Trajectory (for passing)
  double timeInAir;
  double maxFlightTime;
  Vector3 targetPosition;
}

enum BallState {
  carried,
  inAirPass,
  inAirPunt,
  inAirKickoff,
  onGround,
  dead, // Play is over
}
```

### 3.3 Game State

```dart
class GameState {
  // Teams
  List<Player> offensivePlayers; // 11 players
  List<Player> defensivePlayers; // 11 players
  Team offenseTeam;
  Team defenseTeam;

  // Ball
  Ball ball;

  // Game Flow
  GameClock clock;
  int quarter;
  int offenseScore;
  int defenseScore;
  int down; // 1st, 2nd, 3rd, 4th down
  double yardsToGo; // Yards needed for first down
  double lineOfScrimmage;
  double ballSpot;

  // Current Play
  Play? currentPlay;
  Formation offensiveFormation;
  Formation defensiveFormation;
  PlayState playState;

  // Camera
  Camera3D camera;
  CameraMode cameraMode; // followBall, strategic, replay

  // UI State
  bool playSelectionOpen;
  bool pauseMenuOpen;

  // Progression
  int playerXP;
  int teamXP;
  List<Achievement> unlockedAchievements;
}

enum PlayState {
  preSnap,      // Before ball is hiked
  inProgress,   // Play is active
  whistleBlown, // Play ended
  betweenPlays, // Resetting for next play
  timeout,
  halftime,
  gameOver,
}

class GameClock {
  double timeRemaining; // Seconds
  bool isRunning;

  void tick(double dt) {
    if (isRunning) {
      timeRemaining -= dt;
      if (timeRemaining <= 0) {
        timeRemaining = 0;
        isRunning = false;
      }
    }
  }
}
```

---

## 4. RPG Progression System

### 4.1 Player Development

**Experience Sources:**
- Yards gained (rushing/receiving)
- Completions (QB)
- Tackles made
- Sacks, interceptions, forced fumbles
- Touchdowns scored
- Blocks executed
- Games won

**Leveling System:**
```dart
class SkillTree {
  // Skill categories
  Map<SkillCategory, List<Skill>> skills;
  int availableSkillPoints;

  // Unlocked abilities
  List<SpecialAbility> specialAbilities;
}

enum SkillCategory {
  offensive,
  defensive,
  athleticism,
  mental,
  leadership,
}

class Skill {
  final String name;
  final String description;
  final SkillCategory category;
  final int maxLevel;
  int currentLevel;
  final Map<int, AttributeBonus> levelBonuses;
}

class AttributeBonus {
  final String attributeName;
  final double bonusAmount;
}

// Example skills
final tacklingMastery = Skill(
  name: "Tackling Mastery",
  description: "Increases tackle success rate",
  category: SkillCategory.defensive,
  maxLevel: 5,
  currentLevel: 0,
  levelBonuses: {
    1: AttributeBonus("tackling", 5.0),
    2: AttributeBonus("tackling", 10.0),
    3: AttributeBonus("tackling", 15.0),
    4: AttributeBonus("tackling", 20.0),
    5: AttributeBonus("tackling", 30.0),
  },
);
```

### 4.2 Special Abilities (Ultimate Moves)

RPG-style special abilities that charge during gameplay:

```dart
class SpecialAbility {
  final String name;
  final AbilityType type;
  final double cooldown;
  final double duration;
  double cooldownRemaining;

  // Effects
  final Map<String, double> attributeMultipliers;
  final String visualEffect;
}

// Example abilities
final juggernautMode = SpecialAbility(
  name: "Juggernaut",
  type: AbilityType.offensive,
  cooldown: 120.0, // 2 minutes
  duration: 10.0,
  attributeMultipliers: {
    "strength": 2.0,
    "speed": 1.5,
  },
  visualEffect: "golden_glow",
);

final lockdownDefense = SpecialAbility(
  name: "Lockdown",
  type: AbilityType.defensive,
  cooldown: 90.0,
  duration: 15.0,
  attributeMultipliers: {
    "coverage": 2.0,
    "awareness": 1.8,
  },
  visualEffect: "blue_shield",
);
```

---

## 5. Camera System

### 5.1 Camera Modes

```dart
enum CameraMode {
  followBall,      // Third-person behind ball carrier
  strategicOverhead, // Bird's eye view of field
  sidelineView,    // TV broadcast angle
  endZoneView,     // Behind offense looking at defense
  replay,          // Cinematic replay camera
}

class FootballCamera extends Camera3D {
  CameraMode mode;

  void update(double dt, GameState state) {
    switch (mode) {
      case CameraMode.followBall:
        _followBallCarrier(dt, state);
        break;
      case CameraMode.strategicOverhead:
        _strategicView(state);
        break;
      case CameraMode.sidelineView:
        _sidelineView(state);
        break;
      // ... other modes
    }
  }

  void _followBallCarrier(double dt, GameState state) {
    final carrier = state.ball.carrier;
    if (carrier != null) {
      // Position camera behind and above carrier
      final offset = Vector3(0, 5, -8); // Above and behind
      final targetPos = carrier.transform.position + offset;

      // Smooth interpolation
      transform.position = Vector3.lerp(
        transform.position,
        targetPos,
        dt * 5.0,
      );

      // Look at carrier
      lookAt(carrier.transform.position);
    }
  }
}
```

---

## 6. Play Calling System

### 6.1 Playbook Structure

```dart
class Playbook {
  final String name;
  final Map<FormationType, List<Play>> playsByFormation;

  List<Play> getPlaysForSituation(
    int down,
    double yardsToGo,
    double fieldPosition,
  ) {
    // AI-recommended plays based on situation
  }
}

enum FormationType {
  // Offensive
  iFormation,
  shotgun,
  spread,
  singleBack,
  goalLine,

  // Defensive
  fourThree, // 4-3 defense
  threeFour, // 3-4 defense
  nickel,    // 5 DBs
  dime,      // 6 DBs
  prevent,   // Prevent big plays
}
```

### 6.2 Pre-Snap Phase

```dart
class PreSnapSystem {
  static void update(double dt, GameState state) {
    if (state.playState == PlayState.preSnap) {
      // Allow offensive adjustments
      _handleAudibles(state);
      _handleMotion(state);

      // Defensive adjustments
      _handleDefensiveShifts(state);

      // Snap ball when ready
      if (state.inputManager.isActionPressed(GameAction.snapBall)) {
        _snapBall(state);
      }
    }
  }

  static void _snapBall(GameState state) {
    state.playState = PlayState.inProgress;
    state.clock.isRunning = true;

    // Give ball to QB or center it for punts/kicks
    final qb = state.offensivePlayers.firstWhere((p) => p.position == Position.QB);
    state.ball.carrier = qb;
    state.ball.state = BallState.carried;

    // Trigger player AI behaviors
    for (var player in state.offensivePlayers) {
      player.currentBehavior = _getOffensiveBehavior(player, state.currentPlay!);
    }
    for (var player in state.defensivePlayers) {
      player.currentBehavior = _getDefensiveBehavior(player, state);
    }
  }
}
```

---

## 7. Input System

### 7.1 Game Actions

```dart
enum FootballAction {
  // Player control
  moveUp,
  moveDown,
  moveLeft,
  moveRight,
  sprint,
  juke,
  spin,
  dive,

  // Passing
  snapBall,
  throwPass,
  pumpFake,
  selectReceiver1,
  selectReceiver2,
  selectReceiver3,
  selectReceiver4,
  selectReceiver5,

  // Defense
  tackle,
  swat,
  intercept,
  stripBall,

  // Camera
  cameraRotateLeft,
  cameraRotateRight,
  cameraZoomIn,
  cameraZoomOut,
  cameraModeToggle,

  // UI
  pauseMenu,
  playSelection,
  formationSelection,
  timeoutCall,

  // Special
  useSpecialAbility,
}
```

---

## 8. Rendering Extensions

### 8.1 Football-Specific Meshes

```dart
// Field mesh with yard lines
factory Mesh.footballField(double length, double width) {
  // 100 yard field with end zones
  // Yard markers every 5 yards
  // Hash marks
  // End zone colors
}

// Football mesh (prolate spheroid)
factory Mesh.football(Vector3 color) {
  // Elongated sphere shape
  // Laces texture
}

// Player mesh with jersey number
factory Mesh.footballPlayer(int jerseyNumber, Vector3 teamColor) {
  // Humanoid shape (can be simple cube initially)
  // Team-colored uniform
  // Jersey number visible
}
```

### 8.2 Visual Effects

```dart
class VisualEffects {
  // Tackle impact
  static void createTackleEffect(Vector3 position, GameState state);

  // Speed burst (when using special ability)
  static void createSpeedTrail(Player player, GameState state);

  // Catch celebration
  static void createCatchEffect(Player receiver, GameState state);

  // Touchdown celebration
  static void createTouchdownEffect(Vector3 position, GameState state);
}
```

---

## 9. Game Modes

### 9.1 Single Play Mode (MVP)
- Quick match: one offensive series
- Practice mode for learning mechanics
- Ideal for initial development

### 9.2 Full Game Mode
- 4 quarters, 15 minutes each (game time)
- Full rules implementation
- Halftime adjustments

### 9.3 Season Mode (Future)
- Multiple games
- Player progression between games
- Team roster management
- Draft system

### 9.4 Career Mode (Future)
- RPG-focused mode
- Build player from rookie to legend
- Story elements
- Dynamic difficulty

---

## 10. Technical Specifications

### 10.1 Performance Targets

- **Frame Rate**: 60 FPS constant
- **Player Count**: 22 players (11 vs 11)
- **AI Updates**: 30 Hz (every other frame)
- **Physics Updates**: 60 Hz (every frame)
- **UI Updates**: 10 Hz (every 6 frames)

### 10.2 Development Phases

**Phase 1: Foundation** (2-3 weeks)
- Port Warchief codebase structure
- Implement football field rendering
- Basic player movement
- Simple ball physics

**Phase 2: Core Gameplay** (3-4 weeks)
- Play system implementation
- Formation system
- Basic AI behaviors (route running, pursuit)
- Tackle mechanics
- Passing mechanics

**Phase 3: RPG Systems** (2-3 weeks)
- Player attributes
- Progression system
- Skill trees
- Special abilities

**Phase 4: Polish** (2-3 weeks)
- Enhanced animations
- Visual effects
- Sound integration
- UI/UX refinement

**Phase 5: Game Modes** (2-3 weeks)
- Full game mode
- Season mode
- Career mode scaffolding

---

## 11. File Structure

```
lib/
├── main.dart
├── game3d/
│   ├── game3d_widget.dart
│   ├── state/
│   │   ├── game_state.dart
│   │   ├── game_config.dart
│   │   └── plays_config.dart
│   ├── systems/
│   │   ├── input_system.dart
│   │   ├── physics_system.dart
│   │   ├── play_system.dart
│   │   ├── player_ai_system.dart
│   │   ├── gameplay_system.dart
│   │   ├── progression_system.dart
│   │   └── render_system.dart
│   └── ui/
│       ├── scoreboard.dart
│       ├── play_selection_hud.dart
│       ├── player_stats_panel.dart
│       ├── formation_selector.dart
│       └── minimap.dart
├── models/
│   ├── player.dart
│   ├── ball.dart
│   ├── team.dart
│   ├── play.dart
│   ├── formation.dart
│   ├── skill_tree.dart
│   └── game_action.dart
├── rendering3d/
│   ├── webgl_renderer.dart
│   ├── camera3d.dart
│   ├── mesh.dart
│   ├── shader_program.dart
│   └── math/
│       ├── transform3d.dart
│       └── bezier_path.dart
├── controllers/
│   ├── input_manager.dart
│   └── gamepad_manager.dart (future)
└── utils/
    ├── collision_detection.dart
    ├── visual_effects.dart
    └── animation_utils.dart
```

---

## 12. Configuration Management

Following CLAUDE.md guidelines: **NEVER HARDCODE VALUES**

All game parameters stored in configuration files:

- `game_config.dart` - Field dimensions, physics constants
- `plays_config.dart` - All play definitions
- `formations_config.dart` - All formation positions
- `attributes_config.dart` - Player attribute scaling
- `progression_config.dart` - XP curves, skill trees
- `ui_config.dart` - HUD positions, sizes, colors

---

## 13. Port Configuration

**CRITICAL**: Application runs on **port 9009** as specified in CLAUDE.md

```dart
// web/server.dart or similar
const int PORT = 9009;
```

---

## Next Steps

1. Set up Flutter project structure
2. Port core Warchief systems (renderer, camera, input)
3. Implement football field mesh
4. Create player entity system
5. Build basic movement and ball physics
6. Implement play system
7. Add AI behaviors
8. Build RPG progression

---

**Document Version**: 1.0
**Last Updated**: 2025-11-23
**Author**: Claude Code
**Based On**: Warchief RPG Architecture
