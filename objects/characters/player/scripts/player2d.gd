class_name Player2D
extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;


func _ready() -> void:
  Grid.put(self, Grid.get_grid_coords(position))
  animated_sprite.play();


func move(vector: Vector2) -> void:
  var new_world_position := position + (vector * Constants.GRID_SIZE);

  # TODO How do I like the verbosity of this line?
  # TODO Could I give GridEntity a getter property that returns its grid coordinates? That seems better.
  # Basic collision detection: do not move into an occupied Cell.
  if Grid.get_entities(Grid.get_grid_coords(new_world_position)).size() > 0:
    return;

  # FIXME 'Grid.put()' and 'position =' are *highly* dependent on this ordering for no obvious reason.
  #   My unimplemented solution: GridEntity should know its 'last_grid_position' in addition to its current one.
  #   I guess... that would still have implicit side-effects.
  #   Maybe Grid.put() should ask for a 'from_place' more explicitly?
  #   Yeah, probably.
  #   GridEntity will probably have a standard move method anyway, so it'll be responsible regardless.
  Grid.put(self, Grid.get_grid_coords(new_world_position));
  position = new_world_position;
  _set_facing(vector);


func _set_facing(vector: Vector2) -> void:
  match vector:
    # Up
    Vector2( 0, -1):
      animated_sprite.play('idle_up');
      animated_sprite.scale.x = 1;
    
    # Down
    Vector2( 0,  1):
      animated_sprite.play('idle_down');
      animated_sprite.scale.x = 1;
    
    # Left
    Vector2(-1,  0):
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = -1;
    
    # Right
    Vector2( 1,  0):
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = 1;
