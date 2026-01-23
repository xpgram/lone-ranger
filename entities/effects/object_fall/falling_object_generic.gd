extends OneShotEffect


const _scene_object_fall_audio := preload('uid://wk5w0neyylsi');


func _ready() -> void:
  super._ready();

  var downward_tween := get_tree().create_tween();
  downward_tween.tween_method(set_position_y, position.y, position.y + 3, 0.75);

  Events.one_shot_sound_emitted.emit(_scene_object_fall_audio);


func set_position_y(y_pos: float) -> void:
  position.y = ceil(y_pos);
