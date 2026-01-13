extends OneShotEffect


func _ready() -> void:
  super._ready();

  var downward_tween := get_tree().create_tween();
  downward_tween.tween_method(set_position_y, position.y, position.y + 3, 0.75);


func set_position_y(y_pos: float) -> void:
  position.y = floor(y_pos);
