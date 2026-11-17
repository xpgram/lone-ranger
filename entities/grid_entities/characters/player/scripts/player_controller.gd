##
class_name PlayerController
extends Node


## A reference to the player avatar object.
@export var player: Player2D;

## A reference to the container node for all the Player2D copy-entities.
@export var copied_players_container: Node;


## A lock representing whether the player object is internally busy and should
## ignore interrupting behavior like from player input. [br]
##
## Generally used when the player object is preoccupied with animations or mini-
## game-like activities that make the current board state unknowable or erratic,
## or that make it unable to participate in the normal procession of board game
## mechanics where it would be unfair to proceed without it.
var _busy_lock := Padlock.new();

# [TODO] Intuition tells me this ought to be packaged somewhere, but...
#     The coyote state needs to know about it somewhere. And this object is its blackboard.
## @nullable [br]
## A reference to the last-created coyote fall timer.
var _coyote_fall_timer: Timer;

# [FIXME] Some state, like Injured, actually _is_ unique to each Player2D.
#     What do we wanna do?
## A reference to the player-controller state machine.
var _state_machine := CallableStateMachine.new();

## A blackboard variable to retain a reference to the player's chosen command menu action.
# [TODO] Shouldn't this be elsewhere? It seems structureless here.
var _selected_command_menu_action: FieldAction;


##
@onready var focus_node: FocusableControl = %FocusableControl;

##
@onready var _move_input_repeater: InputAxisRepeater = %MoveInputRepeater;

## The player's unique [CommandMenu] instance.
@onready var _command_menu: CommandMenu = %CommandMenu;

## The player's unique dialogue bubble instance.
@onready var _dialogue_bubble: ThoughtsDialogueBubble = %ThoughtsDialogueBubble;

## The player's unique [FieldCursor] instance.
@onready var _field_cursor: FieldCursor = %FieldCursor;

## A reference to the Rect that handles the game world, screen space shader effects.
@onready var _world_shader_rect: PlayerCameraViewShader = %CamViewShader;

## A reference to the Rect that handles HUD-only screen space shader effects.
@onready var _hud_shader_rect: PlayerHUDShader = %UIShaderCanvasGroup;

## A reference to the Rect that handles wholistic screen space shader effects.
@onready var _screen_shader_rect: PlayerScreenSpaceShader = %ScreenSpaceShader;

# [TODO] This should be named more clearly. This is the dialogue context node for the "Inspect" subject.
## A reference to the dialogue context object for inspect-object scenes.
@onready var _dialogue_inspection_target: NodeRetargeter = %DialogueInspectionTarget;


func _ready() -> void:
  _move_input_repeater.input_triggered.connect(_on_move_input);


func _unhandled_input(event: InputEvent) -> void:
  player.handle_input(event);

  # [TODO]
  # save input
  # get copied_players
  # replay input for each copied player.


func _on_move_input(input_vector: Vector2i) -> void:
  player.handle_move_input(input_vector);

  # [TODO]
  # save input
  # get copied_players
  # replay input for each copied player.


# [FIXME] Not yet connected to anything. Scripts used to use player2d to access this method.
#   Do we add PlayerController to a global group? Do we use Events to send dialogue scenes?
#   Do we provide the controller to scripts via the player2d? I might be okay with that... maybe.
## Starts a dialogue bubble to read out the scene described by [param resource].
## If [param resource] is `null`, does nothing. [br]
##
## [param cue] is the script-cue to start from. Otherwise, the script will start
## from line 0. [br]
##
## [param extra_game_states] is a list of node contexts, in order, that the
## script may check for game state values.
func start_dialogue(
    resource: DialogueResource,
    cue := "",
    extra_game_states := [],
) -> void:
  _dialogue_bubble.start(resource, cue, extra_game_states);


# [FIXME] Not yet connected to anything. Scripts used to use player2d to access this method.
## Starts a dialogue bubble to read out the scene described by [param scene].
func start_inspect_dialogue(scene: InspectObject_DialogueScene) -> void:
  _dialogue_inspection_target.target = scene.inspection_subject;
  _dialogue_bubble.start(scene.dialogue_resource, scene.dialogue_cue, scene.extra_game_states);


func _catch_input_focus_when_focus_lost() -> void:
  if not get_viewport().gui_get_focus_owner():
    focus_node.grab_focus();
