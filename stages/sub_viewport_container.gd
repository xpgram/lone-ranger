extends SubViewportContainer



func _ready() -> void:
  Events.player_camera_position_changed.connect(_on_player_camera_position_changed);
  Events.player_camera_rotation_changed.connect(_on_player_camera_rotation_changed);


##
func _on_player_camera_position_changed(camera_position: Vector2) -> void:
  var subpixel_offset := Vector2(
    camera_position.x - int(camera_position.x),
    camera_position.y - int(camera_position.y),
  );

  material.set_shader_parameter('pixel_grid_offset', subpixel_offset);


##
func _on_player_camera_rotation_changed(camera_rotation: float) -> void:
  var camera_rotation_deg := rad_to_deg(camera_rotation);
  material.set_shader_parameter('pixel_grid_rotation_deg', camera_rotation_deg);
