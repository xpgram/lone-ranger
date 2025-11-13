class_name Player2D
extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;

const GRID_SIZE := 16;


func _ready() -> void:
  animated_sprite.play();


func move(vector: Vector2) -> void:
  # TODO Check collisions first.
  position += vector * GRID_SIZE;
  _set_facing(vector);


func _set_facing(dir: Vector2) -> void:
  match dir:
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
