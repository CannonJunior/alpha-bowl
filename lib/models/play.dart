import 'package:vector_math/vector_math.dart';
import 'formation.dart';
import 'player.dart';

/// Type of offensive play
enum PlayType {
  run,        // Running play
  shortPass,  // Short passing play (< 15 yards)
  longPass,   // Deep passing play (> 15 yards)
  fieldGoal,  // Field goal attempt
  punt,       // Punt
  kickoff,    // Kickoff
}

/// Route type for receivers/defenders
enum RouteType {
  // Receiver routes
  straight,    // Run straight downfield
  slant,       // Diagonal cut towards middle
  out,         // Cut towards sideline
  inRoute,     // Cut towards middle
  post,        // Deep diagonal towards goalpost
  corner,      // Deep diagonal towards corner
  curl,        // Run then turn back to QB
  hitch,       // Short stop and turn back
  go,          // Straight deep route
  screen,      // Short pass behind line of scrimmage

  // Defensive assignments
  manCoverage, // Follow assigned receiver
  zoneCoverage, // Cover area of field
  blitz,       // Rush the QB
}

/// Player route - defines path a player should run
class PlayerRoute {
  /// Position of player running this route (QB, RB, etc.)
  final Position playingPosition;

  /// Type of route
  final RouteType routeType;

  /// Waypoints along the route (relative to line of scrimmage)
  final List<Vector3> waypoints;

  /// Speed multiplier (1.0 = normal, > 1.0 = sprint)
  final double speedMultiplier;

  /// Timing (seconds after snap to start route)
  final double delayAfterSnap;

  PlayerRoute({
    required this.playingPosition,
    required this.routeType,
    required this.waypoints,
    this.speedMultiplier = 1.0,
    this.delayAfterSnap = 0.0,
  });

  /// Create a simple straight route
  factory PlayerRoute.straight({
    required Position playingPosition,
    required double distance,
  }) {
    return PlayerRoute(
      playingPosition: playingPosition,
      routeType: RouteType.straight,
      waypoints: [
        Vector3(0, 0, 0),           // Start at formation position
        Vector3(0, 0, distance),    // Run straight downfield
      ],
      speedMultiplier: 1.0,
    );
  }

  /// Create a slant route (diagonal across middle)
  factory PlayerRoute.slant({
    required Position playingPosition,
    required bool toLeft,
  }) {
    return PlayerRoute(
      playingPosition: playingPosition,
      routeType: RouteType.slant,
      waypoints: [
        Vector3(0, 0, 0),
        Vector3(0, 0, 3),           // Run forward 3 yards
        Vector3(toLeft ? -5 : 5, 0, 10), // Cut diagonally
      ],
      speedMultiplier: 1.0,
    );
  }

  /// Create a post route (deep diagonal to goal post)
  factory PlayerRoute.post({
    required Position playingPosition,
    required bool toLeft,
  }) {
    return PlayerRoute(
      playingPosition: playingPosition,
      routeType: RouteType.post,
      waypoints: [
        Vector3(0, 0, 0),
        Vector3(0, 0, 10),          // Run straight 10 yards
        Vector3(toLeft ? -10 : 10, 0, 30), // Cut deep towards middle
      ],
      speedMultiplier: 1.0,
    );
  }

  /// Create a curl route (run then turn back)
  factory PlayerRoute.curl({
    required Position playingPosition,
    required double depth,
  }) {
    return PlayerRoute(
      playingPosition: playingPosition,
      routeType: RouteType.curl,
      waypoints: [
        Vector3(0, 0, 0),
        Vector3(0, 0, depth),       // Run downfield
        Vector3(0, 0, depth - 2),   // Turn back towards QB
      ],
      speedMultiplier: 1.0,
    );
  }
}

/// Offensive or defensive play
class Play {
  /// Play name
  final String name;

  /// Type of play
  final PlayType type;

  /// Formation to use
  final Formation formation;

  /// Routes for each position
  final List<PlayerRoute> routes;

  /// Expected execution time (seconds)
  final double executionTime;

  /// Additional parameters (for special plays)
  final Map<String, dynamic> parameters;

  Play({
    required this.name,
    required this.type,
    required this.formation,
    required this.routes,
    this.executionTime = 5.0,
    this.parameters = const {},
  });

  /// Get route for a specific position
  PlayerRoute? getRouteFor(Position playingPosition) {
    for (final route in routes) {
      if (route.playingPosition == playingPosition) {
        return route;
      }
    }
    return null;
  }

  /// Is this a passing play?
  bool get isPass => type == PlayType.shortPass || type == PlayType.longPass;

  /// Is this a running play?
  bool get isRun => type == PlayType.run;

  // ==================== PREDEFINED PLAYS ====================

  /// HB Dive - Simple inside run
  static Play get hbDive {
    return Play(
      name: 'HB Dive',
      type: PlayType.run,
      formation: Formation.iFormation,
      routes: [
        PlayerRoute(
          playingPosition: Position.RB,
          routeType: RouteType.straight,
          waypoints: [
            Vector3(0, 0, -5),      // Start position
            Vector3(0, 0, 5),       // Run through hole
          ],
          speedMultiplier: 1.2,    // Sprint
        ),
        // QB hands off ball
        PlayerRoute.straight(playingPosition: Position.QB, distance: 0),
        // WRs block downfield
        PlayerRoute.straight(playingPosition: Position.WR, distance: 5),
      ],
      executionTime: 3.0,
    );
  }

  /// Slant Pass - Quick slant to WR
  static Play get slantPass {
    return Play(
      name: 'Slant Pass',
      type: PlayType.shortPass,
      formation: Formation.shotgun,
      routes: [
        // QB drops back
        PlayerRoute(
          playingPosition: Position.QB,
          routeType: RouteType.straight,
          waypoints: [
            Vector3(0, 0, -5),      // Shotgun start
            Vector3(0, 0, -7),      // Drop back 2 yards
          ],
        ),
        // WR runs slant
        PlayerRoute.slant(playingPosition: Position.WR, toLeft: true),
        // TE blocks
        PlayerRoute.straight(playingPosition: Position.TE, distance: 0),
      ],
      executionTime: 2.0,
    );
  }

  /// Go Route - Deep bomb to WR
  static Play get goRoute {
    return Play(
      name: 'Go Route',
      type: PlayType.longPass,
      formation: Formation.shotgun,
      routes: [
        // QB drops back
        PlayerRoute(
          playingPosition: Position.QB,
          routeType: RouteType.straight,
          waypoints: [
            Vector3(0, 0, -5),
            Vector3(0, 0, -10),     // Deep drop
          ],
        ),
        // WR goes deep
        PlayerRoute(
          playingPosition: Position.WR,
          routeType: RouteType.go,
          waypoints: [
            Vector3(-12, 0, 0),     // Start wide
            Vector3(-12, 0, 40),    // Run deep
          ],
          speedMultiplier: 1.3,    // Full speed
        ),
      ],
      executionTime: 4.0,
    );
  }

  /// Post Route - Deep crossing route
  static Play get postRoute {
    return Play(
      name: 'Post Route',
      type: PlayType.longPass,
      formation: Formation.spread,
      routes: [
        // QB in shotgun
        PlayerRoute.straight(playingPosition: Position.QB, distance: -5),
        // WR runs post
        PlayerRoute.post(playingPosition: Position.WR, toLeft: true),
      ],
      executionTime: 3.5,
    );
  }

  @override
  String toString() {
    return 'Play($name, ${type.name}, ${formation.name})';
  }
}

/// Playbook - collection of plays
class Playbook {
  /// Playbook name
  final String name;

  /// Offensive plays
  final List<Play> offensivePlays;

  /// Defensive plays (not implemented yet)
  final List<Play> defensivePlays;

  Playbook({
    required this.name,
    required this.offensivePlays,
    this.defensivePlays = const [],
  });

  /// Get plays for a specific situation
  ///
  /// Parameters:
  /// - down: Current down (1-4)
  /// - yardsToGo: Yards needed for first down
  /// - fieldPosition: Position on field (0-100 yards)
  ///
  /// Returns: List of recommended plays
  List<Play> getPlaysForSituation({
    required int down,
    required double yardsToGo,
    required double fieldPosition,
  }) {
    // Simple logic: recommend plays based on down and distance
    final recommendedPlays = <Play>[];

    if (down == 1) {
      // First down: balanced mix
      recommendedPlays.addAll(offensivePlays.where((p) =>
        p.type == PlayType.run || p.type == PlayType.shortPass
      ));
    } else if (down == 2 && yardsToGo > 7) {
      // 2nd and long: passing
      recommendedPlays.addAll(offensivePlays.where((p) => p.isPass));
    } else if (down == 3 && yardsToGo > 5) {
      // 3rd and medium/long: passing
      recommendedPlays.addAll(offensivePlays.where((p) => p.isPass));
    } else if (down == 4) {
      // 4th down: punt or field goal
      recommendedPlays.addAll(offensivePlays.where((p) =>
        p.type == PlayType.punt || p.type == PlayType.fieldGoal
      ));
    } else {
      // Default: all offensive plays
      recommendedPlays.addAll(offensivePlays);
    }

    return recommendedPlays;
  }

  /// Create a basic playbook with common plays
  factory Playbook.createBasic() {
    return Playbook(
      name: 'Basic Playbook',
      offensivePlays: [
        Play.hbDive,
        Play.slantPass,
        Play.goRoute,
        Play.postRoute,
      ],
    );
  }

  @override
  String toString() {
    return 'Playbook($name, ${offensivePlays.length} offensive plays)';
  }
}
