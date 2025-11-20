##
# TODO Refactor this into a parent class.
class_name Enemy2D
extends GridEntity

## Whether this Enemy2D has acted this turn.
var _has_acted := false;


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


func has_acted() -> bool:
  return _has_acted;


func prepare_to_act() -> void:
  _has_acted = false;


func act() -> void:
  if _player_is_in_sight(Vector2.UP):
    move(Vector2.UP);
  elif _player_is_in_sight(Vector2.DOWN):
    move(Vector2.DOWN);
  elif _player_is_in_sight(Vector2.LEFT):
    move(Vector2.LEFT);
  elif _player_is_in_sight(Vector2.RIGHT):
    move(Vector2.RIGHT);


func move(vector: Vector2i) -> void:
  # TODO Abstract this and Player2D's equivalent.

  var new_grid_position := grid_position + vector;

  var tile_entities := Grid.get_entities(new_grid_position);
  var tile_is_obstructed := tile_entities.any(func (entity: GridEntity): return entity.solid);

  if tile_is_obstructed:
    return;

  grid_position = new_grid_position;
  _has_acted = true;


func _facing_changed() -> void:
  match faced_direction:
    Vector2.UP:
      animated_sprite.scale.x = -1;

    Vector2.DOWN:
      animated_sprite.scale.x = 1;

    Vector2.LEFT:
      animated_sprite.scale.x = -1;

    Vector2.RIGHT:
      animated_sprite.scale.x = 1;


## Returns an array of grid positions extending from our current grid position in the
## direction of 'dir'.
func _get_vision_line(dir: Vector2i) -> Array[Vector2i]:
  var grid_positions := [] as Array[Vector2i];
  var cursor := grid_position + dir;

  for i in range(10):
    grid_positions.append(cursor);
    cursor += dir;

  return grid_positions;


## Given a direction, returns True if a Player2D is in sight in that direction.
func _player_is_in_sight(dir: Vector2) -> bool:
  var vision_line := _get_vision_line(dir);

  for cell_position in vision_line:
    var entities := Grid.get_entities(cell_position);

    # If entities contains the target, return positively.
    if entities.any(func (entity: GridEntity): return is_instance_of(entity, Player2D)):
      return true;

    # If entities contains anything sight-obstructing, quit early.
    if entities.any(func (entity: GridEntity): return entity.solid):
      break;

  return false;
