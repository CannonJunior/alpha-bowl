import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';
import 'mesh.dart';

/// Football-specific mesh factories
///
/// Factory methods for creating meshes used in football game:
/// - Football field with yard markers
/// - Football (prolate spheroid)
/// - Player meshes with team colors
class FootballMeshes {
  /// Create a football field mesh (100 yards + end zones)
  ///
  /// Parameters:
  /// - length: Field length in units (default: 120 yards)
  /// - width: Field width in units (default: 53.33 yards)
  /// - grassColor: Color of the grass
  ///
  /// Returns: Mesh representing the football field
  static Mesh createFootballField({
    double length = 120.0,
    double width = 53.33,
    Vector3? grassColor,
  }) {
    grassColor ??= Vector3(0.1, 0.6, 0.1); // Dark green grass

    final halfLength = length / 2;
    final halfWidth = width / 2;

    // Create a large plane for the field
    return Mesh.plane(
      width: width,
      height: length,
      color: grassColor,
    );
  }

  /// Create yard line markers (white lines)
  ///
  /// This creates individual line meshes for every 5 yards
  ///
  /// Returns: List of Mesh objects for yard lines
  static List<Mesh> createYardLines({
    double fieldLength = 120.0,
    double fieldWidth = 53.33,
    Vector3? lineColor,
  }) {
    lineColor ??= Vector3(1.0, 1.0, 1.0); // White

    final lines = <Mesh>[];
    final lineWidth = fieldWidth;
    final lineThickness = 0.1;

    // Create lines every 5 yards
    for (int yard = -60; yard <= 60; yard += 5) {
      lines.add(
        Mesh.plane(
          width: lineWidth,
          height: lineThickness,
          color: lineColor,
        ),
      );
    }

    return lines;
  }

  /// Create a football mesh (prolate spheroid shape)
  ///
  /// Parameters:
  /// - length: Length of football (default: 0.3 units)
  /// - diameter: Diameter at widest point (default: 0.18 units)
  /// - color: Color of the football
  ///
  /// Returns: Mesh representing a football
  static Mesh createFootball({
    double length = 0.3,
    double diameter = 0.18,
    Vector3? color,
  }) {
    color ??= Vector3(0.6, 0.3, 0.1); // Brown leather color

    // For now, use a cube as a placeholder
    // TODO: Create actual prolate spheroid geometry
    return Mesh.cube(
      size: length,
      color: color,
    );
  }

  /// Create a player mesh with team colors
  ///
  /// Parameters:
  /// - size: Size of the player cube (default: 1.0)
  /// - teamColor: Primary team color
  /// - jerseyNumber: Player's jersey number (for future use)
  ///
  /// Returns: Mesh representing a player
  static Mesh createPlayer({
    double size = 1.0,
    required Vector3 teamColor,
    int? jerseyNumber,
  }) {
    // Simple cube for now
    // TODO: Create more detailed player mesh with jersey number
    return Mesh.cube(
      size: size,
      color: teamColor,
    );
  }

  /// Create end zone mesh
  ///
  /// Parameters:
  /// - width: End zone width (matches field width)
  /// - depth: End zone depth (10 yards)
  /// - isHomeEndZone: Is this the home team's end zone?
  ///
  /// Returns: Mesh for the end zone
  static Mesh createEndZone({
    double width = 53.33,
    double depth = 10.0,
    required bool isHomeEndZone,
  }) {
    // Home end zone: blue, Away end zone: red
    final color = isHomeEndZone
        ? Vector3(0.0, 0.2, 0.6) // Dark blue
        : Vector3(0.6, 0.0, 0.0); // Dark red

    return Mesh.plane(
      width: width,
      height: depth,
      color: color,
    );
  }

  /// Create goalposts mesh
  ///
  /// Returns: Simple representation of goalposts
  static Mesh createGoalposts({
    Vector3? color,
  }) {
    color ??= Vector3(1.0, 0.8, 0.0); // Yellow/gold

    // Simple cube for now (represents the upright)
    // TODO: Create actual goalpost geometry
    return Mesh.cube(
      size: 0.5,
      color: color,
    );
  }

  /// Create a direction indicator (triangle arrow)
  ///
  /// Used to show which way a player is facing
  ///
  /// Parameters:
  /// - size: Size of the triangle
  /// - color: Color of the indicator
  ///
  /// Returns: Triangle mesh pointing forward
  static Mesh createDirectionIndicator({
    double size = 0.5,
    Vector3? color,
  }) {
    color ??= Vector3(1.0, 1.0, 0.0); // Yellow

    return Mesh.triangle(
      size: size,
      color: color,
    );
  }

  /// Create a shadow plane under a player
  ///
  /// Parameters:
  /// - size: Size of the shadow
  ///
  /// Returns: Dark semi-transparent plane
  static Mesh createShadow({
    double size = 1.0,
  }) {
    return Mesh.plane(
      width: size,
      height: size,
      color: Vector3(0.0, 0.0, 0.0), // Black shadow
    );
  }
}
