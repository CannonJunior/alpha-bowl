import 'package:flutter/services.dart';

/// Enumeration of all possible game actions for football gameplay
///
/// These actions can be bound to keyboard keys and
/// are used throughout the game for player input.
enum FootballAction {
  // Player movement
  moveUp,
  moveDown,
  moveLeft,
  moveRight,
  sprint,
  juke,
  spin,
  dive,

  // Passing (QB controls)
  snapBall,
  throwPass,
  pumpFake,
  selectReceiver1,
  selectReceiver2,
  selectReceiver3,
  selectReceiver4,
  selectReceiver5,

  // Defense controls
  tackle,
  swat,
  intercept,
  stripBall,

  // Camera control
  cameraRotateLeft,
  cameraRotateRight,
  cameraZoomIn,
  cameraZoomOut,
  cameraPitchUp,
  cameraPitchDown,
  cameraToggleMode,

  // UI controls
  pauseMenu,
  playSelection,
  formationSelection,
  timeoutCall,

  // Special abilities
  useSpecialAbility,
}

/// Extension to provide display names and default keys for football actions
extension FootballActionExtension on FootballAction {
  /// Human-readable display name
  String get displayName {
    switch (this) {
      case FootballAction.moveUp:
        return 'Move Up';
      case FootballAction.moveDown:
        return 'Move Down';
      case FootballAction.moveLeft:
        return 'Move Left';
      case FootballAction.moveRight:
        return 'Move Right';
      case FootballAction.sprint:
        return 'Sprint';
      case FootballAction.juke:
        return 'Juke';
      case FootballAction.spin:
        return 'Spin Move';
      case FootballAction.dive:
        return 'Dive';
      case FootballAction.snapBall:
        return 'Snap Ball';
      case FootballAction.throwPass:
        return 'Throw Pass';
      case FootballAction.pumpFake:
        return 'Pump Fake';
      case FootballAction.selectReceiver1:
        return 'Select Receiver 1';
      case FootballAction.selectReceiver2:
        return 'Select Receiver 2';
      case FootballAction.selectReceiver3:
        return 'Select Receiver 3';
      case FootballAction.selectReceiver4:
        return 'Select Receiver 4';
      case FootballAction.selectReceiver5:
        return 'Select Receiver 5';
      case FootballAction.tackle:
        return 'Tackle';
      case FootballAction.swat:
        return 'Swat Ball';
      case FootballAction.intercept:
        return 'Intercept';
      case FootballAction.stripBall:
        return 'Strip Ball';
      case FootballAction.cameraRotateLeft:
        return 'Camera Rotate Left';
      case FootballAction.cameraRotateRight:
        return 'Camera Rotate Right';
      case FootballAction.cameraZoomIn:
        return 'Camera Zoom In';
      case FootballAction.cameraZoomOut:
        return 'Camera Zoom Out';
      case FootballAction.cameraPitchUp:
        return 'Camera Pitch Up';
      case FootballAction.cameraPitchDown:
        return 'Camera Pitch Down';
      case FootballAction.cameraToggleMode:
        return 'Toggle Camera Mode';
      case FootballAction.pauseMenu:
        return 'Pause Menu';
      case FootballAction.playSelection:
        return 'Play Selection';
      case FootballAction.formationSelection:
        return 'Formation Selection';
      case FootballAction.timeoutCall:
        return 'Call Timeout';
      case FootballAction.useSpecialAbility:
        return 'Use Special Ability';
    }
  }

  /// Default key binding for this action
  LogicalKeyboardKey get defaultKey {
    switch (this) {
      case FootballAction.moveUp:
        return LogicalKeyboardKey.keyW;
      case FootballAction.moveDown:
        return LogicalKeyboardKey.keyS;
      case FootballAction.moveLeft:
        return LogicalKeyboardKey.keyA;
      case FootballAction.moveRight:
        return LogicalKeyboardKey.keyD;
      case FootballAction.sprint:
        return LogicalKeyboardKey.shiftLeft;
      case FootballAction.juke:
        return LogicalKeyboardKey.keyQ;
      case FootballAction.spin:
        return LogicalKeyboardKey.keyE;
      case FootballAction.dive:
        return LogicalKeyboardKey.space;
      case FootballAction.snapBall:
        return LogicalKeyboardKey.space;
      case FootballAction.throwPass:
        return LogicalKeyboardKey.space;
      case FootballAction.pumpFake:
        return LogicalKeyboardKey.keyQ;
      case FootballAction.selectReceiver1:
        return LogicalKeyboardKey.digit1;
      case FootballAction.selectReceiver2:
        return LogicalKeyboardKey.digit2;
      case FootballAction.selectReceiver3:
        return LogicalKeyboardKey.digit3;
      case FootballAction.selectReceiver4:
        return LogicalKeyboardKey.digit4;
      case FootballAction.selectReceiver5:
        return LogicalKeyboardKey.digit5;
      case FootballAction.tackle:
        return LogicalKeyboardKey.space;
      case FootballAction.swat:
        return LogicalKeyboardKey.keyE;
      case FootballAction.intercept:
        return LogicalKeyboardKey.keyQ;
      case FootballAction.stripBall:
        return LogicalKeyboardKey.keyR;
      case FootballAction.cameraRotateLeft:
        return LogicalKeyboardKey.keyJ;
      case FootballAction.cameraRotateRight:
        return LogicalKeyboardKey.keyL;
      case FootballAction.cameraZoomIn:
        return LogicalKeyboardKey.keyI;
      case FootballAction.cameraZoomOut:
        return LogicalKeyboardKey.keyK;
      case FootballAction.cameraPitchUp:
        return LogicalKeyboardKey.keyN;
      case FootballAction.cameraPitchDown:
        return LogicalKeyboardKey.keyM;
      case FootballAction.cameraToggleMode:
        return LogicalKeyboardKey.keyV;
      case FootballAction.pauseMenu:
        return LogicalKeyboardKey.escape;
      case FootballAction.playSelection:
        return LogicalKeyboardKey.keyP;
      case FootballAction.formationSelection:
        return LogicalKeyboardKey.keyF;
      case FootballAction.timeoutCall:
        return LogicalKeyboardKey.keyT;
      case FootballAction.useSpecialAbility:
        return LogicalKeyboardKey.keyR;
    }
  }
}
