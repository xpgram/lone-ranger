@warning_ignore('missing_tool')
extends GridActorComponent


@export var vision_range := 10;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


func act_async() -> void:
  var dirs := [
    Vector2i.UP,
    Vector2i.DOWN,
    Vector2i.LEFT,
    Vector2i.RIGHT,
  ];

  for dir in dirs:
    if _player_is_in_sight(dir):
      _move(dir);
      break;


func get_entity() -> Enemy2D:
  return super.get_entity();


## Attempts to _move this enemy on the Grid.
func _move(vector: Vector2i) -> void:
  # TODO Consider refactoring this component to contain a list of behaviors (FieldActions)
  #  instead of explicit code here. It would make certain behaviors reusable, and also
  #  make ActionUtils less awkward to use since they'd be in the same directory.

  var self_entity := get_entity();
  var new_grid_position := get_entity().grid_position + vector;

  var tile_entities := Grid.get_entities(new_grid_position);
  var tile_is_obstructed := tile_entities.any(func (entity: GridEntity): return entity.solid);
  var tile_contains_player := tile_entities.any(func (entity): return entity is Player2D);

  if tile_contains_player:
    # TODO Reorganize this code to be less garbage.
    #   An actual attack would probably 'bite' the player in some way, dealing damage, and
    #   the player would set their own 'injured' state.
    var player_index := tile_entities.find_custom(func (entity): return entity is Player2D);
    var player := tile_entities[player_index] as Player2D;
    player.set_animation_state('injured');
    exhaust();
    return;

  if tile_is_obstructed:
    return;

  if not self_entity.has_attribute('stun'):
    self_entity.grid_position = new_grid_position;

  exhaust();


func _facing_changed() -> void:
  match get_entity().faced_direction:
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
  var cursor := get_entity().grid_position + dir;

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
