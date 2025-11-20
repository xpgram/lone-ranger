##
# TODO Refactor this into a parent class.
class_name EnemyMouth
extends Enemy2D


@export var vision_range := 10;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


func act_async() -> void:
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
  #  movement may be unique among each kind of grid entity, but some standard methods
  #  about checking if a location is traversible or the like would be nice. They could
  #  even go in Grid, I suppose.

  var new_grid_position := grid_position + vector;

  var tile_entities := Grid.get_entities(new_grid_position);
  var tile_is_obstructed := tile_entities.any(func (entity: GridEntity): return entity.solid);
  var tile_contains_player := tile_entities.any(func (entity): return entity is Player2D);

  if tile_contains_player:
    # TODO Reorganize this code to be less garbage.
    var player_index := tile_entities.find_custom(func (entity): return entity is Player2D);
    var player := tile_entities[player_index] as Player2D;
    player.set_animation_state('injured');
    exhaust();
    return;

  if tile_is_obstructed:
    return;

  # TODO Tags need a better interface, as well.
  if tags.has('stun'):
    tags.erase('stun');
  else:
    grid_position = new_grid_position;

  exhaust();


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

  for i in range(vision_range):
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
