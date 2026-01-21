## The hookshot object seen in the world when used by a [Player2D].
@tool
class_name Hookshot_PlayerTool
extends Node2D


## How far the chain head is from the cannon base. At 0, the chain head rests neatly
## within the interior of the cannon.
@export var chain_length := 0:
  set(value):
    chain_length = value;
    _update_display();

## Whether the head is lodged into something. Affects the texture used for the chain head.
@export var head_lodged := false:
  set(value):
    head_lodged = value;
    _update_display();

## Resets hookshot properties such that the chain and head are fully seated inside the
## cannon.
@export_tool_button('Reset to Loaded Position')
var tool_button_reset_to_loaded_position = reset_to_loaded_position;


func _ready() -> void:
  _update_display();


## Updates the hookshot's visual components to match its current [member chain_length].
func _update_display() -> void:
  _match_chain_to_chain_length();
  _move_chain_head();


## Extends or retracts the chain-segments component to match the current
## [member chain_length].
func _match_chain_to_chain_length() -> void:
  $Chain.tiled_length = chain_length;


## Moves the chain head sprite to the current end of the chain, as determined from
## [member chain_length].
func _move_chain_head() -> void:
  $Head.position.x = chain_length * Constants.GRID_SIZE;
  $Head.set_lodged(head_lodged);


## Resets hookshot properties such that the chain and head are fully seated inside the
## cannon.
func reset_to_loaded_position() -> void:
  chain_length = 0;
  head_lodged = false;
