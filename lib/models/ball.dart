import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import '../rendering3d/mesh.dart';
import '../rendering3d/math/transform3d.dart';
import 'player.dart';

/// Ball state during gameplay
enum BallState {
  carried,      // Being carried by a player
  inAirPass,    // In air after being thrown
  inAirPunt,    // In air after being punted
  inAirKickoff, // In air after kickoff
  onGround,     // Loose on the ground
  dead,         // Play is over, ball is dead
}

/// Football (the ball) - represents the football in gameplay
///
/// Includes physics simulation for realistic ball trajectory,
/// tracking of possession, and state management.
class Ball {
  // ==================== 3D REPRESENTATION ====================

  /// 3D mesh for rendering (prolate spheroid shape)
  Mesh mesh;

  /// Transform (position, rotation, scale)
  Transform3d transform;

  // ==================== PHYSICS ====================

  /// Linear velocity (units per second)
  Vector3 velocity;

  /// Angular velocity for rotation/spin
  Vector3 angularVelocity;

  /// Spiral rotation rate (radians per second)
  /// Positive = clockwise spiral, negative = counterclockwise
  double spinRate;

  // ==================== STATE ====================

  /// Current state of the ball
  BallState state;

  /// Player currently carrying the ball (null if not carried)
  Player? carrier;

  /// Player who threw/kicked the ball (for stats)
  Player? thrower;

  /// Intended receiver for passes (for AI targeting)
  Player? intendedReceiver;

  // ==================== TRAJECTORY (for passing) ====================

  /// Time the ball has been in the air
  double timeInAir;

  /// Maximum flight time before ball dies (safety measure)
  double maxFlightTime;

  /// Target position for passes (where QB aimed)
  Vector3? targetPosition;

  /// Initial throw velocity magnitude
  double? throwPower;

  // ==================== CONSTRUCTOR ====================

  Ball({
    required this.mesh,
    Transform3d? transform,
    Vector3? velocity,
    Vector3? angularVelocity,
    this.spinRate = 0.0,
    this.state = BallState.dead,
    this.carrier,
    this.thrower,
    this.intendedReceiver,
    this.timeInAir = 0.0,
    this.maxFlightTime = 10.0,
    this.targetPosition,
    this.throwPower,
  })  : transform = transform ?? Transform3d(position: Vector3.zero()),
        velocity = velocity ?? Vector3.zero(),
        angularVelocity = angularVelocity ?? Vector3.zero();

  // ==================== HELPER METHODS ====================

  /// Get ball's current position
  Vector3 get position => transform.position;

  /// Set ball's position
  set position(Vector3 newPosition) {
    transform.position = newPosition;
  }

  /// Is the ball currently being carried?
  bool get isCarried => state == BallState.carried && carrier != null;

  /// Is the ball in the air?
  bool get isInAir =>
      state == BallState.inAirPass ||
      state == BallState.inAirPunt ||
      state == BallState.inAirKickoff;

  /// Is the ball loose (can be recovered)?
  bool get isLoose => state == BallState.onGround;

  /// Is the play over?
  bool get isDead => state == BallState.dead;

  /// Give the ball to a player
  ///
  /// Parameters:
  /// - player: The player to give the ball to
  void giveToPlayer(Player player) {
    carrier = player;
    player.hasBall = true;
    state = BallState.carried;
    velocity = Vector3.zero();
    angularVelocity = Vector3.zero();
    spinRate = 0.0;
  }

  /// Throw the ball (QB pass)
  ///
  /// Parameters:
  /// - throwingPlayer: Player throwing the ball
  /// - target: Target position to throw to
  /// - power: Throw power (0.0 - 1.0)
  /// - receiver: Intended receiver (optional)
  void throwBall({
    required Player throwingPlayer,
    required Vector3 target,
    required double power,
    Player? receiver,
  }) {
    // Release from carrier
    if (carrier != null) {
      carrier!.hasBall = false;
      carrier = null;
    }

    // Set thrower and receiver
    thrower = throwingPlayer;
    intendedReceiver = receiver;
    targetPosition = target;
    throwPower = power;

    // Calculate initial velocity to reach target
    final toTarget = target - position;
    final horizontalDistance = Vector2(toTarget.x, toTarget.z).length;
    final heightDiff = toTarget.y;

    // Physics: calculate parabolic trajectory
    // Using simplified physics: v = sqrt(g * d / sin(2θ))
    // Assuming optimal angle of 45 degrees for now
    final gravity = 9.8;
    final angle = 45.0 * (3.14159 / 180.0); // 45 degrees in radians

    final speed = power * 30.0; // Max throw speed: 30 units/sec
    final horizontalVelocity = toTarget.normalized() * speed * 0.866; // cos(30°)
    final verticalVelocity = speed * 0.5; // sin(30°)

    velocity = Vector3(
      horizontalVelocity.x,
      verticalVelocity,
      horizontalVelocity.z,
    );

    // Set spiral rotation
    spinRate = 10.0; // Radians per second
    angularVelocity = Vector3(0, spinRate, 0);

    // Update state
    state = BallState.inAirPass;
    timeInAir = 0.0;
  }

  /// Punt the ball (special teams)
  ///
  /// Parameters:
  /// - puntingPlayer: Player punting
  /// - direction: Direction to punt (normalized)
  /// - power: Punt power (0.0 - 1.0)
  void punt({
    required Player puntingPlayer,
    required Vector3 direction,
    required double power,
  }) {
    if (carrier != null) {
      carrier!.hasBall = false;
      carrier = null;
    }

    thrower = puntingPlayer;
    throwPower = power;

    // High arc for punts
    final speed = power * 35.0; // Punts are more powerful than passes
    velocity = Vector3(
      direction.x * speed * 0.7,
      speed * 0.7, // High vertical component
      direction.z * speed * 0.7,
    );

    spinRate = 8.0;
    angularVelocity = Vector3(0, spinRate, 0);

    state = BallState.inAirPunt;
    timeInAir = 0.0;
  }

  /// Drop the ball (fumble)
  ///
  /// Parameters:
  /// - fumblingPlayer: Player who fumbled
  void fumble(Player fumblingPlayer) {
    if (carrier != null) {
      carrier!.hasBall = false;
    }

    thrower = fumblingPlayer;
    carrier = null;

    // Random bounce
    final randomX = (DateTime.now().millisecond % 100 - 50) / 50.0;
    final randomZ = (DateTime.now().microsecond % 100 - 50) / 50.0;

    velocity = Vector3(randomX * 3.0, 2.0, randomZ * 3.0);
    angularVelocity = Vector3(
      (DateTime.now().millisecond % 100) / 10.0,
      (DateTime.now().microsecond % 100) / 10.0,
      (DateTime.now().millisecond % 50) / 5.0,
    );

    state = BallState.onGround;
  }

  /// Mark the ball as dead (play is over)
  void markDead() {
    state = BallState.dead;
    velocity = Vector3.zero();
    angularVelocity = Vector3.zero();
    spinRate = 0.0;
  }

  /// Reset the ball for a new play
  ///
  /// Parameters:
  /// - newPosition: Starting position for the ball
  void reset(Vector3 newPosition) {
    position = newPosition;
    velocity = Vector3.zero();
    angularVelocity = Vector3.zero();
    spinRate = 0.0;
    state = BallState.dead;
    carrier = null;
    thrower = null;
    intendedReceiver = null;
    timeInAir = 0.0;
    targetPosition = null;
    throwPower = null;
  }

  /// Update ball physics (called every frame)
  ///
  /// Parameters:
  /// - dt: Delta time in seconds
  /// - gravity: Gravity constant
  void updatePhysics(double dt, double gravity) {
    if (isInAir) {
      // Update time in air
      timeInAir += dt;

      // Check if ball has been in air too long
      if (timeInAir > maxFlightTime) {
        markDead();
        return;
      }

      // Apply gravity
      velocity.y -= gravity * dt;

      // Apply air resistance (slight drag)
      final dragFactor = 0.98;
      velocity = velocity * dragFactor;

      // Update position
      position += velocity * dt;

      // Update rotation from spin
      transform.rotation.y += spinRate * dt * (180.0 / 3.14159); // Convert to degrees

      // Check ground collision
      if (position.y <= 0.2) { // Ball hits ground (assuming ground at y=0)
        position.y = 0.2;
        velocity.y = -velocity.y * 0.5; // Bounce with energy loss

        // Reduce horizontal velocity on bounce
        velocity.x *= 0.7;
        velocity.z *= 0.7;

        // If ball has slowed down enough, mark as on ground
        if (velocity.length < 1.0) {
          velocity = Vector3.zero();
          state = BallState.onGround;
        }
      }
    }
    else if (isCarried && carrier != null) {
      // Ball follows carrier
      // Position slightly in front and above carrier's center
      final carrierForward = Vector3(
        -math.sin(carrier!.rotation * 3.14159 / 180.0),
        0,
        -math.cos(carrier!.rotation * 3.14159 / 180.0),
      );
      position = carrier!.position + Vector3(0, 0.8, 0) + carrierForward * 0.3;
      transform.rotation.y = carrier!.rotation;
    }
  }

  /// Check if ball is catchable by a player
  ///
  /// Parameters:
  /// - player: Player attempting to catch
  /// - catchRadius: How close player must be to catch
  ///
  /// Returns true if ball is within catch range
  bool isCatchableBy(Player player, double catchRadius) {
    if (!isInAir) return false;

    final distanceToBall = (position - player.position).length;
    return distanceToBall <= catchRadius;
  }

  @override
  String toString() {
    return 'Ball(state: ${state.name}, carrier: ${carrier?.displayName ?? "none"})';
  }
}
