import 'package:vector_math/vector_math.dart';
import 'player.dart';

/// Formation type enum
enum FormationType {
  // Offensive formations
  iFormation,
  shotgun,
  spread,
  singleBack,
  goalLine,
  emptyBackfield,

  // Defensive formations
  fourThree,  // 4-3 defense (4 DL, 3 LB)
  threeFour,  // 3-4 defense (3 DL, 4 LB)
  nickel,     // 5 DBs
  dime,       // 6 DBs
  prevent,    // Prevent defense (deep coverage)
}

/// Formation - defines player positions on the field
///
/// A formation specifies where each player should line up
/// before the snap. Positions are relative to line of scrimmage.
class Formation {
  /// Formation name
  final String name;

  /// Formation type
  final FormationType type;

  /// Player positions mapped by position type
  /// Key: Position enum
  /// Value: Relative position from line of scrimmage
  ///        x = lateral (left/right from center)
  ///        y = vertical (should be 0 for ground level)
  ///        z = depth (distance from line of scrimmage, negative = behind)
  final Map<Position, Vector3> positionOffsets;

  /// Is this an offensive formation?
  final bool isOffensive;

  Formation({
    required this.name,
    required this.type,
    required this.positionOffsets,
    required this.isOffensive,
  });

  /// Get position offset for a specific position
  Vector3? getOffsetFor(Position position) {
    return positionOffsets[position];
  }

  /// Calculate actual field positions given a line of scrimmage
  ///
  /// Parameters:
  /// - lineOfScrimmage: Z-coordinate of the line of scrimmage
  /// - centerX: X-coordinate of the center of the field
  ///
  /// Returns: Map of Position → actual 3D position on field
  Map<Position, Vector3> getActualPositions(double lineOfScrimmage, double centerX) {
    final actualPositions = <Position, Vector3>{};

    positionOffsets.forEach((position, offset) {
      actualPositions[position] = Vector3(
        centerX + offset.x,
        offset.y,
        lineOfScrimmage + offset.z,
      );
    });

    return actualPositions;
  }

  // ==================== PREDEFINED FORMATIONS ====================

  /// I-Formation (classic running formation)
  ///
  /// QB under center, FB and RB in line behind QB
  static Formation get iFormation {
    return Formation(
      name: 'I-Formation',
      type: FormationType.iFormation,
      isOffensive: true,
      positionOffsets: {
        // Offensive Line (5 players across)
        Position.OL: Vector3(0, 0, 0),     // Center at line of scrimmage

        // Quarterback
        Position.QB: Vector3(0, 0, -2),    // 2 yards behind center

        // Fullback and Running Back
        Position.RB: Vector3(0, 0, -5),    // RB 5 yards deep

        // Wide Receivers
        Position.WR: Vector3(-10, 0, 0),   // Left WR on line

        // Tight End
        Position.TE: Vector3(3, 0, 0),     // TE on right side
      },
    );
  }

  /// Shotgun Formation (modern passing formation)
  ///
  /// QB 5 yards behind center, spread receivers
  static Formation get shotgun {
    return Formation(
      name: 'Shotgun',
      type: FormationType.shotgun,
      isOffensive: true,
      positionOffsets: {
        Position.OL: Vector3(0, 0, 0),     // Center
        Position.QB: Vector3(0, 0, -5),    // QB in shotgun (5 yards back)
        Position.RB: Vector3(-3, 0, -5),   // RB to QB's left
        Position.WR: Vector3(-12, 0, 0),   // Left WR split wide
        Position.TE: Vector3(4, 0, 0),     // TE on right
      },
    );
  }

  /// Spread Formation (4-5 wide receivers)
  ///
  /// Designed to spread defense horizontally
  static Formation get spread {
    return Formation(
      name: 'Spread',
      type: FormationType.spread,
      isOffensive: true,
      positionOffsets: {
        Position.OL: Vector3(0, 0, 0),
        Position.QB: Vector3(0, 0, -5),     // Shotgun
        Position.WR: Vector3(-15, 0, 0),    // Far left WR
        Position.TE: Vector3(8, 0, 0),      // Right side
        Position.RB: Vector3(0, 0, -3),     // RB shallow
      },
    );
  }

  /// 4-3 Defense (4 down linemen, 3 linebackers)
  ///
  /// Balanced defensive formation
  static Formation get fourThree {
    return Formation(
      name: '4-3 Defense',
      type: FormationType.fourThree,
      isOffensive: false,
      positionOffsets: {
        // Defensive Line (4 players)
        Position.DL: Vector3(0, 0, 1),      // Center of D-line

        // Linebackers (3 players)
        Position.LB: Vector3(0, 0, -3),     // Middle linebacker

        // Cornerbacks
        Position.CB: Vector3(-12, 0, -5),   // Left CB

        // Safeties
        Position.S: Vector3(0, 0, -15),     // Deep safety
      },
    );
  }

  /// 3-4 Defense (3 down linemen, 4 linebackers)
  ///
  /// Versatile defensive formation
  static Formation get threeFour {
    return Formation(
      name: '3-4 Defense',
      type: FormationType.threeFour,
      isOffensive: false,
      positionOffsets: {
        Position.DL: Vector3(0, 0, 1),      // Nose tackle area
        Position.LB: Vector3(0, 0, -2),     // MLB position
        Position.CB: Vector3(-13, 0, -6),   // Left CB
        Position.S: Vector3(0, 0, -16),     // Deep safety
      },
    );
  }

  /// Nickel Defense (5 defensive backs)
  ///
  /// Designed to defend against passing
  static Formation get nickel {
    return Formation(
      name: 'Nickel',
      type: FormationType.nickel,
      isOffensive: false,
      positionOffsets: {
        Position.DL: Vector3(0, 0, 1),
        Position.LB: Vector3(0, 0, -3),
        Position.CB: Vector3(-14, 0, -8),   // Wide coverage
        Position.S: Vector3(0, 0, -18),     // Deep coverage
      },
    );
  }

  @override
  String toString() {
    return 'Formation($name, ${isOffensive ? "Offensive" : "Defensive"})';
  }
}
