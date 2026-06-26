##
class_name VectorUtils


## Returns the grid distance, or manhattan distance, between vectors
## [param from] and [param to].
static func grid_distance(from: Vector2i, to: Vector2i) -> int:
  var vector := (to - from).abs();
  return vector.x + vector.y;
