extends SubViewportContainer


func _ready() -> void:
  Events.camera_moved.connect(_on_camera_moved);


func _on_camera_moved(camera_position: Vector2) -> void:
  var subpixel_component := camera_position.round() - camera_position;
  # var subpixel_component := camera_position - camera_position.round();
  # subpixel_component *= 2;

  # material.set_shader_parameter('subpixel_vector', subpixel_component);
  # position = subpixel_component;
