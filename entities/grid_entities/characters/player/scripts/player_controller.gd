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
# [TODO] Why did I make this private?
# [TODO] Would this be better phrased as a padlock object?
signal _affairs_settled();


##
@export var inventory: PlayerInventory;

##
@export var _player: Player2D;


##
# [TODO] A child node should be in charge of this, right?
var current_animation_state: StringName = 'idle';

##
var _state_machine := CallableStateMachine.new();

## A blackboard variable to retain a reference to the player's chosen command menu action.
# [TODO] Shouldn't this be elsewhere? It seems structureless here.
var _selected_command_menu_action: FieldAction;
