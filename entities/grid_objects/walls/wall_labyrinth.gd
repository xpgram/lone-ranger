##
@tool
extends GridEntity


# TODO Walls don't really need to be GridEntities, I don't think, but I'm not sure yet where the split should be.
# TODO Walls auto-tile with other walls. WallTops auto-tile with other Walls and WallTops.
# TODO Socket types? 'wall-lab', 'walltop-lab', u d l r ud lr ul bl ur br uli bli uri bri 3u 3d 3l 3r 4


@export var sprite_locked := false;


func _ready() -> void:
  on_placed();


func on_placed() -> void:
  _auto_set_tile();
  _update_all_neighbors();


func on_neighbor_placed() -> void:
  _auto_set_tile();


func _auto_set_tile() -> void:
  if sprite_locked:
    return;

  # TODO Based on neighbors and neighbor types, pick a wall sprite.
  prints('Auto-setting wall tile:', grid_position);


func _update_all_neighbors() -> void:
  var relative_neighbor_positions := [
    Vector2i.LEFT + Vector2i.UP,
    Vector2i.UP,
    Vector2i.RIGHT + Vector2i.UP,
    Vector2i.LEFT,
    Vector2i.RIGHT,
    Vector2i.LEFT + Vector2i.DOWN,
    Vector2i.DOWN,
    Vector2i.RIGHT + Vector2i.DOWN,
  ] as Array[Vector2i];

  for relative_position in relative_neighbor_positions:
    var neighbor_position := relative_position + grid_position;
    var entities := Grid.get_entities(neighbor_position);

    for entity in entities:
      if entity.has_method('on_neighbor_placed'):
        entity.on_neighbor_placed();
