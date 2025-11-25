import 'package:vector_math/vector_math.dart';

/// Game configuration constants
///
/// All game parameters are defined here - NEVER HARDCODED in game logic.
/// This allows easy balancing and tuning without changing code.
class GameConfig {
  // ==================== FIELD DIMENSIONS ====================

  /// Total field length in yards (100 yards + 2x10 yard end zones)
  static const double fieldLengthYards = 120.0;

  /// Field width in yards
  static const double fieldWidthYards = 53.33;

  /// End zone depth in yards
  static const double endZoneDepthYards = 10.0;

  /// Playing field length (without end zones)
  static const double playingFieldLengthYards = 100.0;

  /// Convert yards to game units (1 yard = 1 unit for simplicity)
  static const double yardsToUnits = 1.0;

  /// Field length in game units
  static const double fieldLength = fieldLengthYards * yardsToUnits;

  /// Field width in game units
  static const double fieldWidth = fieldWidthYards * yardsToUnits;

  /// End zone depth in game units
  static const double endZoneDepth = endZoneDepthYards * yardsToUnits;

  // ==================== PHYSICS ====================

  /// Gravity constant (units per second squared)
  static const double gravity = 9.8;

  /// Air resistance factor (0.0 = no resistance, 1.0 = maximum)
  static const double airResistance = 0.02;

  /// Ground friction
  static const double groundFriction = 0.9;

  /// Ball mass (kg) - affects physics
  static const double ballMass = 0.42;

  /// Ball bounce coefficient (0.0 = no bounce, 1.0 = perfect bounce)
  static const double ballBounceCoefficient = 0.5;

  // ==================== GAME RULES ====================

  /// Number of quarters in a game
  static const int quartersPerGame = 4;

  /// Duration of each quarter in seconds (15 minutes = 900 seconds)
  static const int quarterDurationSeconds = 900;

  /// Timeouts per half for each team
  static const int timeoutsPerHalf = 3;

  /// Yards needed for first down
  static const int yardsForFirstDown = 10;

  /// Number of downs per series
  static const int downsPerSeries = 4;

  /// Play clock duration (seconds)
  static const int playClockSeconds = 40;

  // ==================== SCORING ====================

  /// Points for a touchdown
  static const int touchdownPoints = 6;

  /// Points for an extra point (kick)
  static const int extraPointPoints = 1;

  /// Points for a 2-point conversion
  static const int twoPointConversionPoints = 2;

  /// Points for a field goal
  static const int fieldGoalPoints = 3;

  /// Points for a safety
  static const int safetyPoints = 2;

  // ==================== PLAYER MOVEMENT ====================

  /// Base player speed (units per second) - multiplied by player's speed attribute
  static const double basePlayerSpeed = 5.0;

  /// Sprint speed multiplier
  static const double sprintMultiplier = 1.5;

  /// Rotation speed (degrees per second)
  static const double playerRotationSpeed = 180.0;

  /// Stamina drain rate when sprinting (points per second)
  static const double sprintStaminaDrain = 10.0;

  /// Stamina recovery rate when not sprinting (points per second)
  static const double staminaRecoveryRate = 5.0;

  /// Max stamina for players
  static const double maxPlayerStamina = 100.0;

  // ==================== BALL PHYSICS ====================

  /// Maximum throw power (units per second)
  static const double maxThrowPower = 30.0;

  /// Maximum punt power (units per second)
  static const double maxPuntPower = 35.0;

  /// Ball catch radius (how close player must be to catch)
  static const double ballCatchRadius = 1.5;

  /// Ball spiral rate (radians per second for perfect spiral)
  static const double ballSpiralRate = 10.0;

  // ==================== COLLISION & TACKLES ====================

  /// Tackle range (how close defender must be to tackle)
  static const double tackleRange = 1.0;

  /// Tackle success base probability (modified by attributes)
  static const double baseTackleProbability = 0.7;

  /// Player collision radius
  static const double playerCollisionRadius = 0.5;

  // ==================== CAMERA SETTINGS ====================

  /// Default camera FOV (field of view in degrees)
  static const double defaultCameraFOV = 90.0;

  /// Camera near clipping plane
  static const double cameraNearPlane = 0.1;

  /// Camera far clipping plane
  static const double cameraFarPlane = 1000.0;

  /// Follow camera distance from ball carrier
  static const double followCameraDistance = 8.0;

  /// Follow camera height above ball carrier
  static const double followCameraHeight = 4.0;

  /// Strategic overhead camera height
  static const double overheadCameraHeight = 50.0;

  // ==================== RENDERING ====================

  /// Target frame rate (FPS)
  static const int targetFrameRate = 60;

  /// Player mesh size (cube side length for now)
  static const double playerMeshSize = 1.0;

  /// Ball mesh size
  static const double ballMeshSize = 0.3;

  /// Field grass color
  static final Vector3 fieldGrassColor = Vector3(0.1, 0.6, 0.1);

  /// Field line color (white)
  static final Vector3 fieldLineColor = Vector3(1.0, 1.0, 1.0);

  /// Home team color (blue)
  static final Vector3 homeTeamColor = Vector3(0.0, 0.3, 0.8);

  /// Away team color (red)
  static final Vector3 awayTeamColor = Vector3(0.8, 0.0, 0.0);

  // ==================== AI SETTINGS ====================

  /// AI decision update frequency (seconds between decisions)
  static const double aiDecisionInterval = 0.5;

  /// AI reaction time (delay before reacting to changes)
  static const double aiReactionTime = 0.2;

  /// Route following tolerance (how close AI must get to waypoints)
  static const double routeFollowTolerance = 0.5;

  // ==================== PROGRESSION (RPG) ====================

  /// Base XP for a tackle
  static const int tackleXP = 10;

  /// Base XP for a catch
  static const int catchXP = 15;

  /// Base XP for a touchdown
  static const int touchdownXP = 100;

  /// Base XP for a sack
  static const int sackXP = 25;

  /// Base XP for an interception
  static const int interceptionXP = 50;

  /// XP multiplier for successful plays
  static const double successXPMultiplier = 1.0;

  /// XP multiplier for failed plays
  static const double failureXPMultiplier = 0.3;

  /// Level-up XP curve multiplier
  static const double levelUpXPMultiplier = 1.1;

  // ==================== DIFFICULTY SETTINGS ====================

  /// AI difficulty presets
  static const Map<String, double> aiDifficultyMultipliers = {
    'easy': 0.7,
    'medium': 1.0,
    'hard': 1.3,
  };

  // ==================== HELPER METHODS ====================

  /// Convert yards to game units
  static double yardsTo(double yards) {
    return yards * yardsToUnits;
  }

  /// Convert game units to yards
  static double toYards(double units) {
    return units / yardsToUnits;
  }

  /// Get field position as yards from own goal line
  ///
  /// Parameters:
  /// - zPosition: Z coordinate on field (0 = center, -60 to +60)
  /// - isHomeTeam: Is this the home team's perspective?
  ///
  /// Returns: Yards from own goal line (0-100)
  static int getYardLine(double zPosition, bool isHomeTeam) {
    // Field runs from -60 (home goal line) to +60 (away goal line)
    // Convert to 0-100 yard line
    final fromHomeGoal = zPosition + 60.0;
    final yardLine = (fromHomeGoal / 1.2).round().clamp(0, 100);

    // If away team, flip the yard line
    return isHomeTeam ? yardLine : (100 - yardLine);
  }
}
