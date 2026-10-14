extends SubViewportContainer



func _ready() -> void:
  Events.player_camera_position_changed.connect(_on_player_camera_position_changed);
  Events.player_camera_rotation_changed.connect(_on_player_camera_rotation_changed);


func _unhandled_input(event: InputEvent) -> void:
  if not event.is_pressed() or not event is InputEventKey:
    return;

  var key_event := event as InputEventKey;
  var resolution_increment := 20;

  # [DEBUG]
  if key_event.get_modifiers_mask() == KEY_MASK_META:
    if key_event.keycode == KEY_BRACKETLEFT:
      _add_to_resolution(resolution_increment);
    if key_event.keycode == KEY_BRACKETRIGHT:
      _add_to_resolution(-resolution_increment);


## Updates shader paramters when the player camera's position changes.
func _on_player_camera_position_changed(camera_position: Vector2) -> void:
  material.set_shader_parameter('subpixel_offset', camera_position);


## Updates shader parameters when the player camera's rotation changes.
func _on_player_camera_rotation_changed(camera_rotation: float) -> void:
  material.set_shader_parameter('pixel_grid_rotation', camera_rotation);


# [DEBUG]
func _add_to_resolution(increment: int) -> void:
  var resolution: Vector2 = material.get_shader_parameter('pixel_grid_resolution');

  resolution.x = max(resolution.x + increment * (240.0 / 160.0), 60);
  resolution.y = max(resolution.y + increment, 40);
  resolution = resolution.round();

  material.set_shader_parameter('pixel_grid_resolution', resolution);
