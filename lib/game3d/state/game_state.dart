import 'package:vector_math/vector_math.dart';
import '../../models/player.dart';
import '../../models/ball.dart';
import '../../models/team.dart';
import '../../models/play.dart';
import '../../models/formation.dart';
import '../../rendering3d/camera3d.dart';
import '../../rendering3d/mesh.dart';

/// Play state enum
enum PlayState {
  preSnap,      // Before ball is snapped
  inProgress,   // Play is active
  whistleBlown, // Play ended, players still moving
  betweenPlays, // Resetting for next play
  timeout,      // Timeout called
  halftime,     // Halftime break
  gameOver,     // Game finished
}

/// GameState - Centralized mutable state for the entire game
///
/// This is the single source of truth for all game data.
/// All systems read from and modify this state.
class GameState {
  // ==================== TEAMS & PLAYERS ====================

  /// Home team
  FootballTeam homeTeam;

  /// Away team
  FootballTeam awayTeam;

  /// Team currently on offense
  FootballTeam get offenseTeam => _isHomeOnOffense ? homeTeam : awayTeam;

  /// Team currently on defense
  FootballTeam get defenseTeam => _isHomeOnOffense ? awayTeam : homeTeam;

  /// Is home team on offense?
  bool _isHomeOnOffense;

  /// Players currently on offense (11 players)
  List<Player> offensivePlayers;

  /// Players currently on defense (11 players)
  List<Player> defensivePlayers;

  // ==================== BALL ====================

  /// The football
  Ball ball;

  // ==================== GAME FLOW ====================

  /// Current quarter (1-4)
  int quarter;

  /// Time remaining in current quarter (seconds)
  double timeRemaining;

  /// Is game clock running?
  bool isClockRunning;

  /// Current down (1-4)
  int down;

  /// Yards to go for first down
  double yardsToGo;

  /// Line of scrimmage (Z-coordinate on field)
  double lineOfScrimmage;

  /// Ball spot (where ball is positioned for next play)
  double ballSpot;

  /// Current play state
  PlayState playState;

  // ==================== CURRENT PLAY ====================

  /// Selected play (null if none selected)
  Play? currentPlay;

  /// Offensive formation
  Formation offensiveFormation;

  /// Defensive formation
  Formation defensiveFormation;

  /// Playbook for offense
  Playbook playbook;

  /// Time since snap (for timing routes)
  double timeSinceSnap;

  /// Play clock time (40 seconds to snap ball)
  double playClockTime;

  // ==================== CAMERA ====================

  /// Game camera
  Camera3D camera;

  // ==================== INPUT ====================

  /// Selected receiver (for QB passing)
  Player? selectedReceiver;

  /// Is player sprinting?
  bool isSprinting;

  // ==================== GAME LOOP ====================

  /// Frame counter
  int frameCount;

  /// Last frame time
  DateTime lastFrameTime;

  /// Delta time accumulator
  double dtAccumulator;

  // ==================== UI STATE ====================

  /// Is play selection menu open?
  bool playSelectionOpen;

  /// Is pause menu open?
  bool pauseMenuOpen;

  /// Is formation selector open?
  bool formationSelectorOpen;

  // ==================== CONSTRUCTOR ====================

  GameState({
    required this.homeTeam,
    required this.awayTeam,
    required this.ball,
    bool isHomeOnOffense = true,
    List<Player>? offensivePlayers,
    List<Player>? defensivePlayers,
    Camera3D? camera,
    this.quarter = 1,
    this.timeRemaining = 900.0,
    this.isClockRunning = false,
    this.down = 1,
    this.yardsToGo = 10.0,
    this.lineOfScrimmage = -60.0, // Start at home goal line
    this.ballSpot = -60.0,
    this.playState = PlayState.betweenPlays,
    this.currentPlay,
    Formation? offensiveFormation,
    Formation? defensiveFormation,
    Playbook? playbook,
    this.timeSinceSnap = 0.0,
    this.playClockTime = 40.0,
    this.selectedReceiver,
    this.isSprinting = false,
    this.frameCount = 0,
    DateTime? lastFrameTime,
    this.dtAccumulator = 0.0,
    this.playSelectionOpen = false,
    this.pauseMenuOpen = false,
    this.formationSelectorOpen = false,
  })  : _isHomeOnOffense = isHomeOnOffense,
        offensivePlayers = offensivePlayers ?? [],
        defensivePlayers = defensivePlayers ?? [],
        camera = camera ?? Camera3D(fov: 90.0, aspectRatio: 16 / 9),
        offensiveFormation = offensiveFormation ?? Formation.iFormation,
        defensiveFormation = defensiveFormation ?? Formation.fourThree,
        playbook = playbook ?? Playbook.createBasic(),
        lastFrameTime = lastFrameTime ?? DateTime.now();

  // ==================== HELPER METHODS ====================

  /// Get all players on the field (22 total)
  List<Player> get allPlayers {
    return [...offensivePlayers, ...defensivePlayers];
  }

  /// Get the player with the ball
  Player? get ballCarrier {
    return ball.carrier;
  }

  /// Get the quarterback
  Player? get quarterback {
    return offensivePlayers.firstWhere(
      (p) => p.playingPosition == Position.QB,
      orElse: () => offensivePlayers.first,
    );
  }

  /// Snap the ball (start the play)
  void snapBall() {
    if (playState != PlayState.preSnap) return;

    playState = PlayState.inProgress;
    isClockRunning = true;
    timeSinceSnap = 0.0;

    // Give ball to QB
    final qb = quarterback;
    if (qb != null) {
      ball.giveToPlayer(qb);
    }
  }

  /// End the current play
  void endPlay() {
    if (playState != PlayState.inProgress) return;

    playState = PlayState.whistleBlown;
    isClockRunning = false;
    ball.markDead();

    // Calculate yards gained
    final yardsGained = ballSpot - lineOfScrimmage;

    // Update down and distance
    if (yardsGained >= yardsToGo) {
      // First down!
      down = 1;
      yardsToGo = 10.0;
    } else {
      down++;
      yardsToGo -= yardsGained;
    }

    // Update line of scrimmage
    lineOfScrimmage = ballSpot;

    // Check for turnover on downs
    if (down > 4) {
      _turnoverOnDowns();
    }
  }

  /// Turnover on downs (failed to get first down)
  void _turnoverOnDowns() {
    _switchPossession();
    down = 1;
    yardsToGo = 10.0;
  }

  /// Switch possession (offense becomes defense)
  void _switchPossession() {
    _isHomeOnOffense = !_isHomeOnOffense;

    // Swap offensive and defensive players
    final temp = offensivePlayers;
    offensivePlayers = defensivePlayers;
    defensivePlayers = temp;

    // Flip ball spot to opposite side of field
    ballSpot = -ballSpot;
    lineOfScrimmage = -lineOfScrimmage;
  }

  /// Score a touchdown
  void scoreTouchdown(Team team) {
    final scoringTeam = team == Team.home ? homeTeam : awayTeam;
    scoringTeam.addScore(6); // 6 points for TD

    // TODO: Extra point attempt
  }

  /// Score a field goal
  void scoreFieldGoal(Team team) {
    final scoringTeam = team == Team.home ? homeTeam : awayTeam;
    scoringTeam.addScore(3); // 3 points for FG
  }

  /// Update game clock
  void updateClock(double dt) {
    if (isClockRunning && playState == PlayState.inProgress) {
      timeRemaining -= dt;

      if (timeRemaining <= 0) {
        _endQuarter();
      }
    }

    // Update play clock
    if (playState == PlayState.preSnap) {
      playClockTime -= dt;

      if (playClockTime <= 0) {
        // Delay of game penalty (TODO)
        playClockTime = 40.0;
      }
    }

    // Update time since snap
    if (playState == PlayState.inProgress) {
      timeSinceSnap += dt;
    }
  }

  /// End the current quarter
  void _endQuarter() {
    isClockRunning = false;

    if (quarter == 2) {
      // Halftime
      playState = PlayState.halftime;
      homeTeam.resetTimeouts();
      awayTeam.resetTimeouts();
    } else if (quarter == 4) {
      // Game over
      playState = PlayState.gameOver;
    }

    quarter++;
    timeRemaining = 900.0; // Reset to 15 minutes
  }

  /// Reset for next play
  void resetForNextPlay() {
    playState = PlayState.preSnap;
    playClockTime = 40.0;
    timeSinceSnap = 0.0;
    selectedReceiver = null;
    isSprinting = false;

    // Position ball at line of scrimmage
    ball.reset(Vector3(0, 0.2, lineOfScrimmage));

    // Position players in formation
    _positionPlayersInFormation();
  }

  /// Position all players according to current formations
  void _positionPlayersInFormation() {
    // Get actual positions from formations
    final offensePositions = offensiveFormation.getActualPositions(
      lineOfScrimmage,
      0.0, // Center of field (X)
    );

    final defensePositions = defensiveFormation.getActualPositions(
      lineOfScrimmage + 1.0, // 1 yard away from offense
      0.0,
    );

    // Position offensive players
    for (final player in offensivePlayers) {
      final position = offensePositions[player.position];
      if (position != null) {
        player.position = position;
        player.rotation = 90.0; // Face downfield
      }
    }

    // Position defensive players
    for (final player in defensivePlayers) {
      final position = defensePositions[player.position];
      if (position != null) {
        player.position = position;
        player.rotation = -90.0; // Face offense
      }
    }
  }

  /// Get score summary
  String getScoreSummary() {
    return '${homeTeam.name}: ${homeTeam.score}  ${awayTeam.name}: ${awayTeam.score}';
  }

  /// Get down and distance string (e.g., "2nd & 7")
  String getDownAndDistance() {
    final downStr = ['1st', '2nd', '3rd', '4th'][down - 1];
    return '$downStr & ${yardsToGo.round()}';
  }

  /// Get time remaining string (MM:SS)
  String getTimeString() {
    final minutes = (timeRemaining / 60).floor();
    final seconds = (timeRemaining % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
