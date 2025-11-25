import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import '../rendering3d/webgl_renderer.dart';
import '../rendering3d/camera3d.dart';
import '../rendering3d/mesh.dart';
import '../rendering3d/math/transform3d.dart';
import '../rendering3d/football_meshes.dart';
import '../controllers/input_manager.dart';
import '../models/game_action.dart';
import '../models/player.dart';
import '../models/ball.dart';
import '../models/team.dart';
import 'state/game_state.dart';
import 'state/game_config.dart';

/// Game3D - Main game widget with 3D rendering and game loop
///
/// This widget manages the WebGL canvas, game loop, input handling,
/// and renders the 3D football game.
class Game3D extends StatefulWidget {
  const Game3D({super.key});

  @override
  State<Game3D> createState() => _Game3DState();
}

class _Game3DState extends State<Game3D> {
  // ==================== RENDERING ====================

  late html.CanvasElement canvas;
  late WebGLRenderer renderer;

  // ==================== GAME STATE ====================

  late GameState gameState;
  late InputManager inputManager;

  // ==================== GAME LOOP ====================

  int? animationFrameId;
  DateTime lastFrameTime = DateTime.now();
  int frameCount = 0;
  double fpsCounter = 0.0;

  // ==================== MESHES ====================

  late Mesh fieldMesh;
  late Mesh ballMesh;
  late Mesh playerMesh;

  @override
  void initState() {
    super.initState();

    // Initialize game immediately (like Warchief)
    _initializeGame();
  }

  @override
  void dispose() {
    _stopGameLoop();
    renderer.dispose();
    canvas.remove();
    super.dispose();
  }

  /// Initialize the game (called once)
  void _initializeGame() {
    try {
      print('=== Alpha Bowl Initialization Starting ===');

      // Create WebGL canvas (DO NOT set width/height yet - Warchief pattern)
      canvas = html.CanvasElement()
        ..style.position = 'fixed'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..style.zIndex = '-1' // Behind Flutter UI
        ..style.pointerEvents = 'none'; // Let Flutter handle input

      // Append canvas to document body
      html.document.body?.append(canvas);
      print('Canvas created and appended to DOM');

      // Set canvas size AFTER appending to DOM (CRITICAL - Warchief pattern)
      canvas.width = 1600;
      canvas.height = 900;
      print('Canvas size: ${canvas.width}x${canvas.height}');

      // Initialize renderer
      renderer = WebGLRenderer(canvas);
      print('WebGL renderer initialized');

      // Create meshes
      _createMeshes();

      // Initialize input manager
      inputManager = InputManager();
      _setupInputBindings();

      // Initialize game state
      _initializeGameState();

      print('Alpha Bowl initialized successfully!');

      // Start game loop
      _startGameLoop();
    } catch (e, stackTrace) {
      debugPrint('Error initializing game: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Create all game meshes
  void _createMeshes() {
    // Football field (green plane)
    fieldMesh = FootballMeshes.createFootballField(
      length: GameConfig.fieldLength,
      width: GameConfig.fieldWidth,
      grassColor: GameConfig.fieldGrassColor,
    );

    // Football (brown)
    ballMesh = FootballMeshes.createFootball(
      length: GameConfig.ballMeshSize,
      color: Vector3(0.6, 0.3, 0.1),
    );

    // Player (blue cube for now)
    playerMesh = Mesh.cube(
      size: GameConfig.playerMeshSize,
      color: GameConfig.homeTeamColor,
    );

    debugPrint('Meshes created');
  }

  /// Initialize game state with teams and players
  void _initializeGameState() {
    // Create teams
    final homeTeam = FootballTeam.createDefault(
      name: 'Home Team',
      teamSide: Team.home,
      primaryColor: GameConfig.homeTeamColor,
    );

    final awayTeam = FootballTeam.createDefault(
      name: 'Away Team',
      teamSide: Team.away,
      primaryColor: GameConfig.awayTeamColor,
    );

    // Create ball
    final ball = Ball(
      mesh: ballMesh,
      transform: Transform3d(
        position: Vector3(0, 0.5, 0),
      ),
    );

    // Create camera (like Warchief pattern)
    final camera = Camera3D(
      position: Vector3(0, 10, -20),
      rotation: Vector3(30, 0, 0), // Start at 30 degrees pitch like Warchief
      fov: GameConfig.defaultCameraFOV,
      aspectRatio: canvas.width! / canvas.height!,
    );

    // Set camera target and distance explicitly (Warchief pattern)
    camera.setTarget(Vector3(0, 0, 0));
    camera.setTargetDistance(20);
    camera.setMode(CameraMode.followBall);

    // Initialize game state
    gameState = GameState(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      ball: ball,
      camera: camera,
    );

    // Create a few test players
    _createTestPlayers();

    debugPrint('Game state initialized');
  }

  /// Create test players for MVP demo
  void _createTestPlayers() {
    // Create one player with the ball (QB)
    final qbMesh = FootballMeshes.createPlayer(
      teamColor: GameConfig.homeTeamColor,
      jerseyNumber: 12,
    );

    final qb = Player(
      number: 12,
      name: 'Test QB',
      playingPosition: Position.QB,
      team: Team.home,
      mesh: qbMesh,
      transform: Transform3d(position: Vector3(0, 0.5, 0)),
    );

    gameState.offensivePlayers.add(qb);
    gameState.ball.giveToPlayer(qb);

    // Create a receiver
    final wrMesh = FootballMeshes.createPlayer(
      teamColor: GameConfig.homeTeamColor,
      jerseyNumber: 88,
    );

    final wr = Player(
      number: 88,
      name: 'Test WR',
      playingPosition: Position.WR,
      team: Team.home,
      mesh: wrMesh,
      transform: Transform3d(position: Vector3(-10, 0.5, 5)),
    );

    gameState.offensivePlayers.add(wr);

    // Create a defender
    final cbMesh = FootballMeshes.createPlayer(
      teamColor: GameConfig.awayTeamColor,
      jerseyNumber: 21,
    );

    final cb = Player(
      number: 21,
      name: 'Test CB',
      playingPosition: Position.CB,
      team: Team.away,
      mesh: cbMesh,
      transform: Transform3d(position: Vector3(-10, 0.5, 10)),
    );

    gameState.defensivePlayers.add(cb);

    debugPrint('Created ${gameState.allPlayers.length} test players');
  }

  /// Setup input bindings
  void _setupInputBindings() {
    // Movement (continuous)
    inputManager.bindContinuousAction(FootballAction.moveUp, () {
      _movePlayer(Vector3(0, 0, 1));
    });

    inputManager.bindContinuousAction(FootballAction.moveDown, () {
      _movePlayer(Vector3(0, 0, -1));
    });

    inputManager.bindContinuousAction(FootballAction.moveLeft, () {
      _movePlayer(Vector3(-1, 0, 0));
    });

    inputManager.bindContinuousAction(FootballAction.moveRight, () {
      _movePlayer(Vector3(1, 0, 0));
    });

    // Camera toggle (one-time press)
    inputManager.bindAction(FootballAction.cameraToggleMode, () {
      gameState.camera.toggleMode();
      debugPrint('Camera mode: ${gameState.camera.mode}');
    });

    // Camera rotation (continuous)
    inputManager.bindContinuousAction(FootballAction.cameraRotateLeft, () {
      gameState.camera.yawBy(-90 * _getLastDeltaTime());
    });

    inputManager.bindContinuousAction(FootballAction.cameraRotateRight, () {
      gameState.camera.yawBy(90 * _getLastDeltaTime());
    });

    debugPrint('Input bindings setup');
  }

  /// Move the controlled player
  void _movePlayer(Vector3 direction) {
    final player = gameState.ballCarrier ?? gameState.quarterback;
    if (player != null) {
      final speed = GameConfig.basePlayerSpeed * _getLastDeltaTime();
      player.position += direction * speed;
    }
  }

  /// Get last frame delta time
  double _getLastDeltaTime() {
    final now = DateTime.now();
    final dt = (now.millisecondsSinceEpoch - lastFrameTime.millisecondsSinceEpoch) / 1000.0;
    return dt.clamp(0.0, 0.1); // Cap at 100ms to avoid huge jumps
  }

  /// Start the game loop
  void _startGameLoop() {
    lastFrameTime = DateTime.now();
    print('Starting game loop...');

    void gameLoop(num timestamp) {
      if (!mounted) return;

      // Calculate delta time
      final now = DateTime.now();
      final dt = (now.millisecondsSinceEpoch - lastFrameTime.millisecondsSinceEpoch) / 1000.0;
      lastFrameTime = now;

      frameCount++;

      // Log every 60 frames (~1 second at 60fps)
      if (frameCount % 60 == 0) {
        print('Frame $frameCount - dt: ${dt.toStringAsFixed(4)}s - Players: ${gameState.allPlayers.length}');
      }

      // Update game
      _update(dt);

      // Render scene
      _render();

      // Schedule next frame
      animationFrameId = html.window.requestAnimationFrame(gameLoop);
    }

    animationFrameId = html.window.requestAnimationFrame(gameLoop);
    print('Game loop started - animationFrameId: $animationFrameId');
  }

  /// Stop the game loop
  void _stopGameLoop() {
    if (animationFrameId != null) {
      html.window.cancelAnimationFrame(animationFrameId!);
      animationFrameId = null;
    }
  }

  /// Update game state (called every frame)
  void _update(double dt) {
    // Update input
    inputManager.update(dt);

    // Update ball carrier
    final ballCarrier = gameState.ballCarrier;
    if (ballCarrier != null && gameState.camera.mode == CameraMode.followBall) {
      gameState.camera.updateFollowBall(
        ballCarrier.position,
        ballCarrier.rotation,
        dt,
      );
    }

    // Update ball physics (if in air)
    if (gameState.ball.isInAir) {
      gameState.ball.updatePhysics(dt, GameConfig.gravity);
    }
  }

  /// Render the 3D scene (called every frame)
  void _render() {
    // Debug check
    if (frameCount == 1) {
      print('First render call - Field mesh: ${fieldMesh != null}, Camera: ${gameState.camera != null}');
    }

    // Clear screen
    renderer.clear();

    // Render football field
    final fieldTransform = Transform3d(
      position: Vector3(0, 0, 0),
    );
    renderer.render(fieldMesh, fieldTransform, gameState.camera);

    // Render all players
    for (final player in gameState.allPlayers) {
      renderer.render(player.mesh, player.transform, gameState.camera);
    }

    // Render ball
    renderer.render(gameState.ball.mesh, gameState.ball.transform, gameState.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        return inputManager.handleKeyEvent(event);
      },
      child: Container(
        color: Colors.transparent, // CRITICAL: Transparent to show canvas behind (like Warchief)
        child: const SizedBox.expand(), // Empty container to allow canvas to show through
      ),
    );
  }
}
