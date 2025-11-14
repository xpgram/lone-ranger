class_name Player2D
extends CharacterBody2D


var facing := Vector2.DOWN;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;


func _ready() -> void:
  Grid.put(self, Grid.get_grid_coords(position))
  animated_sprite.play();


func wait() -> float:
  return PartialTime.NONE;


func spin(vector: Vector2) -> float:
  _set_facing(vector);
  return PartialTime.NONE;


func move(vector: Vector2) -> float:
  var new_world_position := position + (vector * Constants.GRID_SIZE);

  # TODO How do I like the verbosity of this line?
  # TODO Could I give GridEntity a getter property that returns its grid coordinates? That seems better.
  var tile_is_obstructed := (Grid.get_entities(Grid.get_grid_coords(new_world_position)).size() > 0);

  if tile_is_obstructed:
    if vector != facing:
      return spin(vector);
    else:
      return push(vector);

  # FIXME 'Grid.put()' and 'position =' are *highly* dependent on this ordering for no obvious reason.
  #   My unimplemented solution: GridEntity should know its 'last_grid_position' in addition to its current one.
  #   I guess... that would still have implicit side-effects.
  #   Maybe Grid.put() should ask for a 'from_place' more explicitly?
  #   Yeah, probably.
  #   GridEntity will probably have a standard move method anyway, so it'll be responsible regardless.
  Grid.put(self, Grid.get_grid_coords(new_world_position));
  position = new_world_position;
  _set_facing(vector);
  return PartialTime.FULL;


func push(vector: Vector2) -> float:
  # IMPLEMENT Get entity in facing dir, ask them to move, etc.

  var target_pos := Grid.get_grid_coords(position) + Vector2i(vector);
  var entities := Grid.get_entities(target_pos);

  print('pushing %s...' % entities[0].name);
  return PartialTime.FULL;


func _set_facing(vector: Vector2) -> void:
  facing = vector.normalized();

  match facing:
    Vector2.UP:
      animated_sprite.play('idle_up');
      animated_sprite.scale.x = 1;

    Vector2.DOWN:
      animated_sprite.play('idle_down');
      animated_sprite.scale.x = 1;

    Vector2.LEFT:
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = -1;

    Vector2.RIGHT:
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = 1;
