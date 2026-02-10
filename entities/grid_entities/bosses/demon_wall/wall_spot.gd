extends GridEntity


## 2 = floor, 0 = wall
@export var terrain_type: int = 2;


func _ready() -> void:
  super._ready();
  grid_position_changed.connect(_on_entity_moved);


func activate() -> void:
  Grid.set_tile_type(grid_position, terrain_type);


func _on_entity_moved() -> void:
  Grid.set_tile_type(grid_position, terrain_type);


func _on_free_fall() -> void:
  pass
