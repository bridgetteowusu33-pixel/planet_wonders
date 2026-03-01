/// A single floating ingredient entity on screen.
class RushIngredient {
  const RushIngredient({
    required this.uid,
    required this.ingredientId,
    required this.name,
    required this.emoji,
    required this.isTarget,
    required this.lane,
    required this.x,
    required this.speed,
    required this.direction,
    this.assetPath,
  });

  /// Unique instance ID (monotonically increasing).
  final int uid;

  /// Ingredient type ID (matches objective / distractor pool).
  final String ingredientId;

  final String name;
  final String emoji;

  /// Whether this ingredient is a valid target for the current objective.
  final bool isTarget;

  /// Vertical lane index (0-based).
  final int lane;

  /// Normalized horizontal position: 0.0 = off-screen start, 1.0 = off-screen end.
  final double x;

  /// Speed in logical-pixels per second.
  final double speed;

  /// Movement direction: 1 = left-to-right, -1 = right-to-left.
  final int direction;

  /// Optional ingredient PNG asset path.
  final String? assetPath;

  RushIngredient copyWith({double? x}) {
    return RushIngredient(
      uid: uid,
      ingredientId: ingredientId,
      name: name,
      emoji: emoji,
      isTarget: isTarget,
      lane: lane,
      x: x ?? this.x,
      speed: speed,
      direction: direction,
      assetPath: assetPath,
    );
  }
}
