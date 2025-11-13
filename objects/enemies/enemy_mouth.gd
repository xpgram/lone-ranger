class_name Enemy2D
extends CharacterBody2D

## Whether this Enemy2D has acted this turn.
var _has_acted := false;


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  Grid.put(self, Grid.get_grid_coords(position));
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


func move(vector: Vector2) -> void:
  # TODO Abstract this and Player2D's equivalent.

  var new_world_position := position + (vector * Constants.GRID_SIZE);

  # Basic collision detection: do not move into an occupied Cell.
  if Grid.get_entities(Grid.get_grid_coords(new_world_position)).size() > 0:
    return;

  Grid.put(self, Grid.get_grid_coords(new_world_position));
  position = new_world_position;
  _set_facing(vector);
  _has_acted = true;


func _set_facing(vector: Vector2) -> void:
  match vector:
    # Up
    Vector2( 0, -1):
      animated_sprite.scale.x = -1;
    
    # Down
    Vector2( 0,  1):
      animated_sprite.scale.x = 1;
    
    # Left
    Vector2(-1,  0):
      animated_sprite.scale.x = -1;
    
    # Right
    Vector2( 1,  0):
      animated_sprite.scale.x = 1;


## Returns an array of grid positions extending from our current grid position in the
## direction of 'dir'.
func _get_vision_line(dir: Vector2) -> Array[Vector2i]:
  var grid_positions := [] as Array[Vector2i];
  var cursor := Grid.get_grid_coords(position) + Vector2i(dir);

  for i in range(10):
    grid_positions.append(cursor);
    cursor += Vector2i(dir);

  return grid_positions;


## Given a direction, returns True if a Player2D is in sight in that direction.
func _player_is_in_sight(dir: Vector2) -> bool:
  var vision_line := _get_vision_line(dir);
  # print('%s looking...' % name, vision_line);

  for grid_pos in vision_line:
    var entities = Grid.get_entities(grid_pos);

    # If entities contains the target, return positively.
    if entities.any(func (entity): return is_instance_of(entity, Player2D)):
      return true;

    # If entities contains anything sight-obstructing, quit early.
    if entities.size() > 0:
      break;
  
  return false;
