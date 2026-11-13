##
class_name PlayerController
extends Node


# [TODO] Player2D Wishlist:
# - A "location_logger" that takes in a new grid position and either saves or rejects it.
#   - If saved, it's appended to a list of viable respawn locations.
#   - Acceptance includes: save point, hard flooring, stable mechanical flooring, unstable flooring.
#   - When Player2D falls into a pit, it can ask location_logger for the most recent, still-valid location.
#     - still-valid means it's checked again on request.
#     - This also makes previous location management easier: if the hard-flooring spot is occupied by a monster,
#       we can pick a different hard-flooring spot because we'll save multiple.


## Emitted when an action the player would like to perform has been chosen.
signal action_declared(action: FieldActionSchedule, buffer_this: bool);

##
signal coyote_fall_recovered_result(recovered: bool);



##
@export var inventory: PlayerInventory;

##
@export var _player: Player2D;


##
# [TODO] A child node should be in charge of this, right?
# [TODO] An enum instead of strings?
var current_animation_state: StringName = 'idle';

## A lock representing whether the player object is internally busy and should
## ignore interrupting behavior like from player input. [br]
##
## Generally used when the player object is preoccupied with animations or mini-
## game-like activities that make the current board state unknowable or erratic,
## or that make it unable to participate in the normal procession of board game
## mechanics where it would be unfair to proceed without it.
var _busy_lock := Padlock.new();

##
var _state_machine := CallableStateMachine.new();

## A blackboard variable to retain a reference to the player's chosen command menu action.
# [TODO] Shouldn't this be elsewhere? It seems structureless here.
var _selected_command_menu_action: FieldAction;
