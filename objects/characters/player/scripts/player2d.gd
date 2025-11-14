class_name Player2D
extends GridEntity


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;


func _ready() -> void:
  animated_sprite.play();


# TODO Refactor these into Skill/Action .tres files.
#   What if an enemy could push blocks too? Do I just *reimplement* that shit? Hell nah.
func wait() -> float:
  return PartialTime.NONE;


func spin(vector: Vector2) -> float:
  return PartialTime.NONE;


func move(vector: Vector2i) -> float:
  var new_grid_position := grid_position + vector;

  grid_position = new_grid_position;

  return PartialTime.FULL;


func push(vector: Vector2i) -> float:
  # IMPLEMENT Get entity in facing dir, ask them to move, etc.

  var target_cell := grid_position + vector;
  var entities := Grid.get_entities(target_cell);

  print('pushing %s...' % entities[0].name);
  return PartialTime.FULL;


func _facing_changed() -> void:
  match facing_direction:
    Vector2i.UP:
      animated_sprite.play('idle_up');
      animated_sprite.scale.x = 1;

    Vector2i.DOWN:
      animated_sprite.play('idle_down');
      animated_sprite.scale.x = 1;

    Vector2i.LEFT:
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = -1;

    Vector2i.RIGHT:
      animated_sprite.play('idle_side');
      animated_sprite.scale.x = 1;
