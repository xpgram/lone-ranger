## The hookshot object seen in the world when used by a [Player2D].
@tool
class_name Hookshot_PlayerTool
extends Node2D


const CHAIN_HEAD_RESTING_POSITION_X := -4;


## How far the chain head is from the cannon base. At 0, the chain head rests neatly
## within the interior of the cannon.
@export var chain_length := 0:
  set(value):
    chain_length = value;
    _update_display();

## Sprite representing the head 'claw' segment of the chain.
@export var _head_sprite: Node2D;


func _ready() -> void:
  _update_display();


## Updates the hookshot's visual components to match its current [member chain_length].
func _update_display() -> void:
  _match_chain_to_chain_length();
  _move_chain_head();


## Extends or retracts the chain-segments component to match the current
## [member chain_length].
func _match_chain_to_chain_length() -> void:
  var tiles_travelled := maxi(0, chain_length - 1);
  $Chain.tiled_length = tiles_travelled;


## Moves the chain head sprite to the current end of the chain, as determined from
## [member chain_length].
func _move_chain_head() -> void:
  if chain_length > 0:
    # We must account for the fact that the length=0 and length=1 positions are visually
    # the same on screen; the difference being whether the chain head is loaded in the
    # cannon.
    var tiles_travelled := chain_length - 1;
    _head_sprite.position.x = tiles_travelled * Constants.GRID_SIZE;
  else:
    _head_sprite.position.x = CHAIN_HEAD_RESTING_POSITION_X;
