class_name Enemy2D
extends CharacterBody2D

# TODO Standardize in a constants singleton somewhere.
const GRID_SIZE := 16;


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


func act() -> void:
  # TODO Check orthogonal dirs for a player object
  #   Check the grid? Or cast a ray?
  #   Move 1-tile toward player, if found.

  # For testing, just move in a random direction.
  match randi() % 4:
    0:
      move(Vector2( 0, -1));
    1:
      move(Vector2( 0,  1));
    2:
      move(Vector2(-1,  0));
    3:
      move(Vector2( 1,  0));


func move(vector: Vector2) -> void:
  # TODO Check collisions first.
  # TODO Abstract this and Player2D's equivalent.

  position += vector * GRID_SIZE;
  _set_facing(vector);


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
