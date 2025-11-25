import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'math/transform3d.dart';

/// Camera Mode - Different camera perspectives for football gameplay
enum CameraMode {
  followBall,        // Third-person behind ball carrier
  strategicOverhead, // Bird's eye view of field
  sidelineView,      // TV broadcast angle from sideline
  endZoneView,       // Behind offense looking at defense
}

/// Camera3D - 3D perspective camera with dual-axis rotation
///
/// Supports multiple camera modes optimized for football gameplay.
/// This camera generates view and projection matrices for 3D rendering.
///
/// Usage:
/// ```dart
/// final camera = Camera3D(
///   fov: 60,
///   aspectRatio: 16/9,
///   near: 0.1,
///   far: 1000.0,
/// );
/// camera.setTarget(Vector3(0, 0, 0));
/// camera.pitchBy(10); // N/M keys
/// camera.yawBy(15);   // J/L keys
/// final viewMatrix = camera.getViewMatrix();
/// final projMatrix = camera.getProjectionMatrix();
/// ```
class Camera3D {
  /// Transform for camera position and rotation
  final Transform3d transform;

  /// Field of view (degrees)
  double fov;

  /// Aspect ratio (width / height)
  double aspectRatio;

  /// Near clipping plane distance
  final double near;

  /// Far clipping plane distance
  final double far;

  /// Target position to look at (null = use forward direction)
  Vector3? _target;

  /// Distance from target (for orbiting)
  double _targetDistance = 10.0;

  /// Min/max pitch angles (in degrees)
  final double minPitch = -89.0;  // Almost straight down
  final double maxPitch = 89.0;   // Almost straight up

  /// Current camera mode
  CameraMode _mode = CameraMode.followBall;

  /// Follow ball camera settings
  double _followBallDistance = 8.0;  // Distance behind ball carrier
  double _followBallHeight = 4.0;    // Height above ball carrier
  double _followBallPitch = 25.0;    // Fixed pitch angle

  /// Strategic overhead camera settings
  double _overheadHeight = 50.0;     // Height above field
  double _overheadPitch = -70.0;     // Looking down

  /// Sideline view settings
  double _sidelineDistance = 30.0;   // Distance from sideline
  double _sidelineHeight = 10.0;     // Height above field

  /// Camera FOV settings
  final double _followBallFOV = 90.0;      // Wide FOV for action
  final double _strategicOverheadFOV = 75.0; // Medium FOV for overview
  final double _sidelineFOV = 60.0;        // Standard TV broadcast FOV
  final double _endZoneFOV = 80.0;         // Wide FOV for downfield view

  /// Smooth camera interpolation speed
  final double _cameraLerpSpeed = 8.0;

  Camera3D({
    Vector3? position,
    Vector3? rotation,
    this.fov = 90.0,
    this.aspectRatio = 16.0 / 9.0,
    this.near = 0.1,
    this.far = 1000.0,
  }) : transform = Transform3d(
          position: position ?? Vector3(0, 5, 10),
          rotation: rotation ?? Vector3(0, 0, 0),
        );

  /// Get the view matrix for rendering
  ///
  /// View matrix transforms world space to camera space.
  /// This is the inverse of the camera's transform matrix.
  Matrix4 getViewMatrix() {
    if (_target != null) {
      // Look-at mode: camera looks at target
      return makeViewMatrix(
        transform.position,
        _target!,
        Vector3(0, 1, 0), // Up vector
      );
    } else {
      // Free-look mode: use camera's forward direction
      final forward = transform.forward;
      final lookAt = transform.position + forward;
      return makeViewMatrix(
        transform.position,
        lookAt,
        Vector3(0, 1, 0),
      );
    }
  }

  /// Get the projection matrix for rendering
  ///
  /// Projection matrix transforms camera space to clip space.
  /// This creates the perspective effect (far objects appear smaller).
  Matrix4 getProjectionMatrix() {
    return makePerspectiveMatrix(
      radians(fov),
      aspectRatio,
      near,
      far,
    );
  }

  /// Set a target position for the camera to orbit around
  void setTarget(Vector3 target) {
    _target = target;
    updatePositionFromTarget();
  }

  /// Get the current target position
  Vector3 getTarget() {
    return _target ?? Vector3.zero();
  }

  /// Clear target (switch to free-look mode)
  void clearTarget() {
    _target = null;
  }

  /// Update camera position based on target and current rotation
  ///
  /// This positions the camera at _targetDistance from the target,
  /// using current pitch/yaw angles.
  void updatePositionFromTarget() {
    if (_target == null) return;

    // Calculate camera position based on spherical coordinates
    final pitchRad = radians(transform.rotation.x);
    final yawRad = radians(transform.rotation.y);

    // Spherical to Cartesian conversion
    final x = _targetDistance * -math.sin(yawRad) * math.cos(pitchRad);
    final y = _targetDistance * math.sin(pitchRad);
    final z = _targetDistance * -math.cos(yawRad) * math.cos(pitchRad);

    transform.position = _target! + Vector3(x, y, z);
  }

  /// Rotate camera up/down (pitch - N/M keys)
  ///
  /// Positive delta looks up, negative looks down.
  /// This is rotation around the X-axis.
  void pitchBy(double deltaDegrees) {
    transform.rotation.x = (transform.rotation.x + deltaDegrees)
        .clamp(minPitch, maxPitch);

    if (_target != null) {
      updatePositionFromTarget();
    }
  }

  /// Rotate camera left/right (yaw - J/L keys)
  ///
  /// Positive delta rotates right, negative rotates left.
  /// This is rotation around the Y-axis.
  void yawBy(double deltaDegrees) {
    transform.rotation.y = (transform.rotation.y + deltaDegrees) % 360.0;

    if (_target != null) {
      updatePositionFromTarget();
    }
  }

  /// Set distance from target
  void setTargetDistance(double distance) {
    _targetDistance = distance.clamp(1.0, 100.0);

    if (_target != null) {
      updatePositionFromTarget();
    }
  }

  /// Zoom in/out by adjusting target distance
  void zoom(double delta) {
    setTargetDistance(_targetDistance + delta);
  }

  /// Move camera forward/backward along its forward direction
  void moveForward(double distance) {
    transform.position += transform.forward * distance;
  }

  /// Move camera right/left along its right direction
  void strafe(double distance) {
    transform.position += transform.right * distance;
  }

  /// Move camera up/down in world space
  void moveVertical(double distance) {
    transform.position.y += distance;
  }

  /// Get current pitch angle (degrees)
  double get pitch => transform.rotation.x;

  /// Get current yaw angle (degrees)
  double get yaw => transform.rotation.y;

  /// Get current position
  Vector3 get position => transform.position;

  /// Get forward direction
  Vector3 get forward => transform.forward;

  /// Get right direction
  Vector3 get right => transform.right;

  /// Get up direction
  Vector3 get up => transform.up;

  // ==================== CAMERA MODE MANAGEMENT ====================

  /// Get current camera mode
  CameraMode get mode => _mode;

  /// Set camera mode
  void setMode(CameraMode newMode) {
    if (_mode == newMode) return;

    _mode = newMode;

    // Adjust FOV based on mode
    switch (_mode) {
      case CameraMode.followBall:
        fov = _followBallFOV;
        break;
      case CameraMode.strategicOverhead:
        fov = _strategicOverheadFOV;
        break;
      case CameraMode.sidelineView:
        fov = _sidelineFOV;
        break;
      case CameraMode.endZoneView:
        fov = _endZoneFOV;
        break;
    }
  }

  /// Toggle between camera modes (cycles through all modes)
  void toggleMode() {
    final modes = CameraMode.values;
    final currentIndex = modes.indexOf(_mode);
    final nextIndex = (currentIndex + 1) % modes.length;
    setMode(modes[nextIndex]);
  }

  /// Update camera in follow ball mode to track ball carrier
  ///
  /// Parameters:
  /// - ballCarrierPosition: Position of the player with the ball
  /// - ballCarrierRotation: Y-axis rotation of the ball carrier (in degrees)
  /// - dt: Delta time for smooth interpolation
  void updateFollowBall(Vector3 ballCarrierPosition, double ballCarrierRotation, double dt) {
    if (_mode != CameraMode.followBall) return;

    // Calculate desired camera position behind the ball carrier
    // Add 180 degrees to position camera behind instead of in front
    final rotationRad = radians(ballCarrierRotation + 180.0);

    // Position behind ball carrier based on their rotation
    final offsetX = -math.sin(rotationRad) * _followBallDistance;
    final offsetZ = -math.cos(rotationRad) * _followBallDistance;

    final desiredPosition = Vector3(
      ballCarrierPosition.x + offsetX,
      ballCarrierPosition.y + _followBallHeight,
      ballCarrierPosition.z + offsetZ,
    );

    // Smooth interpolation to desired position
    final lerpFactor = math.min(1.0, _cameraLerpSpeed * dt);
    transform.position = Vector3(
      transform.position.x + (desiredPosition.x - transform.position.x) * lerpFactor,
      transform.position.y + (desiredPosition.y - transform.position.y) * lerpFactor,
      transform.position.z + (desiredPosition.z - transform.position.z) * lerpFactor,
    );

    // Set camera to look at a point slightly above the ball carrier
    final lookAtPoint = Vector3(
      ballCarrierPosition.x,
      ballCarrierPosition.y + 1.0,  // Look at ball carrier's upper body
      ballCarrierPosition.z,
    );

    _target = lookAtPoint;

    // Set the pitch angle for follow ball view
    transform.rotation.x = _followBallPitch;
    transform.rotation.y = ballCarrierRotation;
  }

  /// Update camera in strategic overhead mode
  ///
  /// Parameters:
  /// - fieldCenter: Center point of the current play area
  /// - dt: Delta time for smooth interpolation
  void updateStrategicOverhead(Vector3 fieldCenter, double dt) {
    if (_mode != CameraMode.strategicOverhead) return;

    // Position camera high above the field center
    final desiredPosition = Vector3(
      fieldCenter.x,
      _overheadHeight,
      fieldCenter.z,
    );

    // Smooth interpolation to desired position
    final lerpFactor = math.min(1.0, _cameraLerpSpeed * dt);
    transform.position = Vector3(
      transform.position.x + (desiredPosition.x - transform.position.x) * lerpFactor,
      transform.position.y + (desiredPosition.y - transform.position.y) * lerpFactor,
      transform.position.z + (desiredPosition.z - transform.position.z) * lerpFactor,
    );

    // Look down at field center
    _target = Vector3(fieldCenter.x, 0, fieldCenter.z);
    transform.rotation.x = _overheadPitch;
  }

  /// Update camera in sideline view mode
  ///
  /// Parameters:
  /// - ballPosition: Current position of the ball
  /// - fieldWidth: Width of the football field (for sideline positioning)
  /// - dt: Delta time for smooth interpolation
  void updateSidelineView(Vector3 ballPosition, double fieldWidth, double dt) {
    if (_mode != CameraMode.sidelineView) return;

    // Position camera on the sideline, tracking the ball's Z position
    final desiredPosition = Vector3(
      fieldWidth / 2 + _sidelineDistance,  // Off to the side
      _sidelineHeight,                     // At broadcast height
      ballPosition.z,                      // Track ball downfield
    );

    // Smooth interpolation
    final lerpFactor = math.min(1.0, _cameraLerpSpeed * dt);
    transform.position = Vector3(
      transform.position.x + (desiredPosition.x - transform.position.x) * lerpFactor,
      transform.position.y + (desiredPosition.y - transform.position.y) * lerpFactor,
      transform.position.z + (desiredPosition.z - transform.position.z) * lerpFactor,
    );

    // Look at ball
    _target = ballPosition;
  }

  /// Update camera in end zone view mode
  ///
  /// Parameters:
  /// - offensePosition: Average position of offensive players (or QB position)
  /// - lookingDownfield: Direction the offense is facing (in degrees)
  /// - dt: Delta time for smooth interpolation
  void updateEndZoneView(Vector3 offensePosition, double lookingDownfield, double dt) {
    if (_mode != CameraMode.endZoneView) return;

    // Position camera behind the offense looking downfield
    final rotationRad = radians(lookingDownfield + 180.0);

    final desiredPosition = Vector3(
      offensePosition.x - math.sin(rotationRad) * 15.0,
      5.0,  // Medium height
      offensePosition.z - math.cos(rotationRad) * 15.0,
    );

    // Smooth interpolation
    final lerpFactor = math.min(1.0, _cameraLerpSpeed * dt);
    transform.position = Vector3(
      transform.position.x + (desiredPosition.x - transform.position.x) * lerpFactor,
      transform.position.y + (desiredPosition.y - transform.position.y) * lerpFactor,
      transform.position.z + (desiredPosition.z - transform.position.z) * lerpFactor,
    );

    // Look downfield
    final lookAtPoint = Vector3(
      offensePosition.x + math.sin(radians(lookingDownfield)) * 30.0,
      2.0,
      offensePosition.z + math.cos(radians(lookingDownfield)) * 30.0,
    );

    _target = lookAtPoint;
  }

  /// Set follow ball camera distance from ball carrier
  void setFollowBallDistance(double distance) {
    _followBallDistance = distance.clamp(3.0, 15.0);
  }

  /// Set follow ball camera height above ball carrier
  void setFollowBallHeight(double height) {
    _followBallHeight = height.clamp(1.0, 10.0);
  }

  /// Set follow ball camera pitch angle
  void setFollowBallPitch(double pitch) {
    _followBallPitch = pitch.clamp(0.0, 60.0);
  }

  /// Set strategic overhead camera height
  void setOverheadHeight(double height) {
    _overheadHeight = height.clamp(20.0, 100.0);
  }

  /// Set sideline camera distance from field
  void setSidelineDistance(double distance) {
    _sidelineDistance = distance.clamp(10.0, 50.0);
  }
}
