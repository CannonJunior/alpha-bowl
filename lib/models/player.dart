import 'package:vector_math/vector_math.dart';
import '../rendering3d/mesh.dart';
import '../rendering3d/math/transform3d.dart';
import '../rendering3d/math/bezier_path.dart';

/// Player position on the football field
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

/// Player's current state in gameplay
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

/// AI behavior modes for players
enum AIBehavior {
  // Offensive behaviors
  runRoute,
  blockDefender,
  receivePass,
  runWithBall,

  // Defensive behaviors
  manCoverage,
  zoneCoverage,
  rushPasser,
  pursueCarrier,

  // Special teams
  kickCoverage,
  returnKick,
}

/// Team affiliation
enum Team {
  home,
  away,
}

/// Player attributes (RPG stats)
///
/// All attributes range from 0-100, where:
/// - 0-40: Below average
/// - 40-60: Average
/// - 60-80: Above average
/// - 80-100: Elite
class PlayerAttributes {
  // Physical attributes
  double speed;        // Top speed
  double acceleration; // How fast they reach top speed
  double strength;     // Tackle power, blocking effectiveness
  double agility;      // Cutting, juking ability
  double jumping;      // Catching high balls, deflecting passes

  // Mental attributes
  double awareness;    // React to plays, read defense
  double catching;     // Catch success rate
  double tackling;     // Tackle success rate
  double throwing;     // QB accuracy and power (if QB)
  double blocking;     // Block effectiveness

  // Position-specific
  double coverage;     // Defensive coverage ability (DBs)

  PlayerAttributes({
    this.speed = 50.0,
    this.acceleration = 50.0,
    this.strength = 50.0,
    this.agility = 50.0,
    this.jumping = 50.0,
    this.awareness = 50.0,
    this.catching = 50.0,
    this.tackling = 50.0,
    this.throwing = 50.0,
    this.blocking = 50.0,
    this.coverage = 50.0,
  });

  /// Create attributes with random values (for quick testing)
  factory PlayerAttributes.random() {
    return PlayerAttributes(
      speed: 40 + (60 * (0.5 + 0.5 * (DateTime.now().millisecond % 100) / 100)),
      acceleration: 40 + (60 * (0.5 + 0.5 * (DateTime.now().microsecond % 100) / 100)),
      strength: 40 + (60 * (0.5 + 0.5 * ((DateTime.now().millisecond + 10) % 100) / 100)),
      agility: 40 + (60 * (0.5 + 0.5 * ((DateTime.now().microsecond + 20) % 100) / 100)),
      jumping: 40 + (60 * (0.5 + 0.5 * ((DateTime.now().millisecond + 30) % 100) / 100)),
      awareness: 50.0,
      catching: 50.0,
      tackling: 50.0,
      throwing: 50.0,
      blocking: 50.0,
      coverage: 50.0,
    );
  }

  /// Create attributes optimized for a specific position
  factory PlayerAttributes.forPosition(Position position) {
    switch (position) {
      case Position.QB:
        return PlayerAttributes(
          speed: 60.0,
          acceleration: 65.0,
          strength: 55.0,
          agility: 70.0,
          jumping: 60.0,
          awareness: 85.0,
          catching: 40.0,
          tackling: 30.0,
          throwing: 90.0,
          blocking: 40.0,
          coverage: 30.0,
        );
      case Position.RB:
        return PlayerAttributes(
          speed: 85.0,
          acceleration: 90.0,
          strength: 70.0,
          agility: 85.0,
          jumping: 60.0,
          awareness: 75.0,
          catching: 70.0,
          tackling: 40.0,
          throwing: 30.0,
          blocking: 55.0,
          coverage: 30.0,
        );
      case Position.WR:
        return PlayerAttributes(
          speed: 90.0,
          acceleration: 85.0,
          strength: 50.0,
          agility: 85.0,
          jumping: 85.0,
          awareness: 75.0,
          catching: 90.0,
          tackling: 30.0,
          throwing: 30.0,
          blocking: 40.0,
          coverage: 30.0,
        );
      case Position.LB:
        return PlayerAttributes(
          speed: 75.0,
          acceleration: 80.0,
          strength: 80.0,
          agility: 70.0,
          jumping: 70.0,
          awareness: 80.0,
          catching: 50.0,
          tackling: 85.0,
          throwing: 30.0,
          blocking: 60.0,
          coverage: 65.0,
        );
      case Position.CB:
        return PlayerAttributes(
          speed: 90.0,
          acceleration: 90.0,
          strength: 55.0,
          agility: 90.0,
          jumping: 85.0,
          awareness: 80.0,
          catching: 75.0,
          tackling: 70.0,
          throwing: 30.0,
          blocking: 40.0,
          coverage: 90.0,
        );
      default:
        return PlayerAttributes();
    }
  }
}

/// Player entity - represents a football player in the game
///
/// This combines 3D representation, game state, attributes, AI, and progression.
class Player {
  // ==================== IDENTITY ====================

  /// Jersey number (1-99)
  final int number;

  /// Player name
  final String name;

  /// Position on field (QB, RB, etc.)
  final Position playingPosition;

  /// Team affiliation
  final Team team;

  // ==================== 3D REPRESENTATION ====================

  /// 3D mesh for rendering
  Mesh mesh;

  /// Transform (position, rotation, scale)
  Transform3d transform;

  /// Y-axis rotation in degrees (direction player is facing)
  double rotation;

  // ==================== CORE ATTRIBUTES ====================

  /// Player's RPG-style attributes
  PlayerAttributes attributes;

  // ==================== GAME STATE ====================

  /// Current stamina (0-100)
  double stamina;

  /// Maximum stamina
  double maxStamina;

  /// Does this player have the ball?
  bool hasBall;

  /// Current state
  PlayerState state;

  /// Velocity vector (for physics)
  Vector3 velocity;

  // ==================== AI ====================

  /// Current AI behavior
  AIBehavior? currentBehavior;

  /// Assigned route (for receivers/defenders)
  BezierPath? assignedRoute;

  /// Target player (for blocking/coverage assignments)
  Player? assignedTarget;

  /// AI decision timer (when to make next decision)
  double aiDecisionTimer;

  // ==================== PROGRESSION (RPG) ====================

  /// Player level (1-99)
  int level;

  /// Current experience points
  int experience;

  /// XP required for next level
  int xpForNextLevel;

  // ==================== ANIMATION ====================

  /// Current animation frame/state
  double animationTime;

  // ==================== CONSTRUCTOR ====================

  Player({
    required this.number,
    required this.name,
    required this.playingPosition,
    required this.team,
    required this.mesh,
    Transform3d? transform,
    this.rotation = 0.0,
    PlayerAttributes? attributes,
    this.stamina = 100.0,
    this.maxStamina = 100.0,
    this.hasBall = false,
    this.state = PlayerState.idle,
    Vector3? velocity,
    this.currentBehavior,
    this.assignedRoute,
    this.assignedTarget,
    this.aiDecisionTimer = 0.0,
    this.level = 1,
    this.experience = 0,
    this.xpForNextLevel = 100,
    this.animationTime = 0.0,
  })  : transform = transform ?? Transform3d(position: Vector3.zero()),
        attributes = attributes ?? PlayerAttributes.forPosition(playingPosition),
        velocity = velocity ?? Vector3.zero();

  // ==================== HELPER METHODS ====================

  /// Get player's position on the field
  Vector3 get position => transform.position;

  /// Set player's position on the field
  set position(Vector3 newPosition) {
    transform.position = newPosition;
  }

  /// Get forward direction vector
  Vector3 get forward => transform.forward;

  /// Is this player on offense?
  bool get isOffensive {
    return playingPosition == Position.QB ||
        playingPosition == Position.RB ||
        playingPosition == Position.WR ||
        playingPosition == Position.TE ||
        playingPosition == Position.OL;
  }

  /// Is this player on defense?
  bool get isDefensive {
    return playingPosition == Position.DL ||
        playingPosition == Position.LB ||
        playingPosition == Position.CB ||
        playingPosition == Position.S;
  }

  /// Calculate actual speed based on attributes and stamina
  ///
  /// Returns speed in units per second
  double getActualSpeed() {
    final baseSpeed = attributes.speed / 10.0; // Convert 0-100 to 0-10 units/sec
    final staminaMultiplier = (stamina / maxStamina).clamp(0.5, 1.0);
    return baseSpeed * staminaMultiplier;
  }

  /// Drain stamina over time
  ///
  /// Parameters:
  /// - dt: Delta time in seconds
  /// - drainRate: How fast to drain (default: 5.0 per second when sprinting)
  void drainStamina(double dt, {double drainRate = 5.0}) {
    stamina = (stamina - drainRate * dt).clamp(0.0, maxStamina);
  }

  /// Recover stamina over time
  ///
  /// Parameters:
  /// - dt: Delta time in seconds
  /// - recoveryRate: How fast to recover (default: 10.0 per second)
  void recoverStamina(double dt, {double recoveryRate = 10.0}) {
    stamina = (stamina + recoveryRate * dt).clamp(0.0, maxStamina);
  }

  /// Add experience points
  ///
  /// Returns true if player leveled up
  bool addExperience(int xp) {
    experience += xp;

    if (experience >= xpForNextLevel) {
      _levelUp();
      return true;
    }

    return false;
  }

  /// Level up the player (called internally)
  void _levelUp() {
    level++;
    experience -= xpForNextLevel;
    xpForNextLevel = (xpForNextLevel * 1.1).round(); // 10% increase per level

    // Slight attribute boost on level up
    attributes.speed = (attributes.speed + 0.5).clamp(0.0, 100.0);
    attributes.strength = (attributes.strength + 0.5).clamp(0.0, 100.0);
    attributes.agility = (attributes.agility + 0.5).clamp(0.0, 100.0);
  }

  /// Get display name with number
  String get displayName => '#$number $name';

  /// Get team color
  Vector3 getTeamColor() {
    return team == Team.home
        ? Vector3(0.0, 0.3, 0.8)  // Blue
        : Vector3(0.8, 0.0, 0.0); // Red
  }

  @override
  String toString() {
    return 'Player(#$number $name, $position, ${team.name})';
  }
}
