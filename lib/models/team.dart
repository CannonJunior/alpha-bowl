import 'package:vector_math/vector_math.dart';
import '../rendering3d/mesh.dart';
import '../rendering3d/math/transform3d.dart';
import 'player.dart';

/// Team metadata and roster
///
/// Represents a football team with players, colors, and stats.
class FootballTeam {
  /// Team name
  final String name;

  /// Team affiliation (home or away)
  final Team teamSide;

  /// Primary team color (RGB 0-1)
  final Vector3 primaryColor;

  /// Secondary team color (RGB 0-1)
  final Vector3 secondaryColor;

  /// Team roster (all players)
  final List<Player> roster;

  /// Current score
  int score;

  /// Timeouts remaining in half
  int timeoutsRemaining;

  /// Team stats
  final TeamStats stats;

  FootballTeam({
    required this.name,
    required this.teamSide,
    Vector3? primaryColor,
    Vector3? secondaryColor,
    List<Player>? roster,
    this.score = 0,
    this.timeoutsRemaining = 3,
    TeamStats? stats,
  })  : primaryColor = primaryColor ??
            (teamSide == Team.home
                ? Vector3(0.0, 0.3, 0.8) // Blue
                : Vector3(0.8, 0.0, 0.0)), // Red
        secondaryColor = secondaryColor ??
            (teamSide == Team.home
                ? Vector3(1.0, 1.0, 1.0) // White
                : Vector3(0.9, 0.9, 0.0)), // Gold
        roster = roster ?? [],
        stats = stats ?? TeamStats();

  /// Get players by position
  List<Player> getPlayersByPosition(Position position) {
    return roster.where((p) => p.playingPosition == position).toList();
  }

  /// Get offensive players
  List<Player> get offensivePlayers {
    return roster.where((p) => p.isOffensive).toList();
  }

  /// Get defensive players
  List<Player> get defensivePlayers {
    return roster.where((p) => p.isDefensive).toList();
  }

  /// Call a timeout
  ///
  /// Returns true if successful, false if no timeouts remaining
  bool callTimeout() {
    if (timeoutsRemaining > 0) {
      timeoutsRemaining--;
      return true;
    }
    return false;
  }

  /// Reset timeouts (called at halftime)
  void resetTimeouts() {
    timeoutsRemaining = 3;
  }

  /// Add points to score
  void addScore(int points) {
    score += points;
    stats.totalPoints += points;
  }

  /// Create a default team with simple roster
  factory FootballTeam.createDefault({
    required String name,
    required Team teamSide,
    Vector3? primaryColor,
    Vector3? secondaryColor,
  }) {
    final team = FootballTeam(
      name: name,
      teamSide: teamSide,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );

    // Create a simple roster (you can expand this)
    // This creates one player of each position for testing
    final positions = [
      Position.QB,
      Position.RB,
      Position.WR,
      Position.TE,
      Position.OL,
      Position.DL,
      Position.LB,
      Position.CB,
      Position.S,
      Position.K,
      Position.P,
    ];

    int jerseyNumber = 1;
    for (final position in positions) {
      // Create a placeholder mesh (will be replaced with actual mesh)
      final playerMesh = Mesh.cube(
        size: 1.0,
        color: team.primaryColor,
      );

      final player = Player(
        number: jerseyNumber++,
        name: 'Player ${jerseyNumber - 1}',
        playingPosition: position,
        team: teamSide,
        mesh: playerMesh,
      );

      team.roster.add(player);
    }

    return team;
  }

  @override
  String toString() {
    return 'Team($name, Score: $score, Players: ${roster.length})';
  }
}

/// Team statistics for tracking performance
class TeamStats {
  // Offensive stats
  int totalYards;
  int passingYards;
  int rushingYards;
  int totalPoints;
  int touchdowns;
  int fieldGoals;

  // Defensive stats
  int tackles;
  int sacks;
  int interceptions;
  int forcedFumbles;

  // Possession
  double timeOfPossession; // in seconds

  TeamStats({
    this.totalYards = 0,
    this.passingYards = 0,
    this.rushingYards = 0,
    this.totalPoints = 0,
    this.touchdowns = 0,
    this.fieldGoals = 0,
    this.tackles = 0,
    this.sacks = 0,
    this.interceptions = 0,
    this.forcedFumbles = 0,
    this.timeOfPossession = 0.0,
  });

  /// Reset stats (for new game)
  void reset() {
    totalYards = 0;
    passingYards = 0;
    rushingYards = 0;
    totalPoints = 0;
    touchdowns = 0;
    fieldGoals = 0;
    tackles = 0;
    sacks = 0;
    interceptions = 0;
    forcedFumbles = 0;
    timeOfPossession = 0.0;
  }
}
