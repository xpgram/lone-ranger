##
class_name PlayerController
extends Node


# [TODO] Player2D Wishlist:
# - None. Yay~


##
signal coyote_fall_recovered_result(recovered: bool);

# [TODO] The players container, not just one player.
#     Or maybe we'll have a main one and also a separate container for the copies?
## A reference to the player avatar object.
@export var player: Player2D;


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
  _connect_component_signals();
  _connect_input_signals();
  _connect_ui_subsystem_signals();


func _process(_delta: float) -> void:
  _catch_input_focus_when_focus_lost();


func _unhandled_input(event: InputEvent) -> void:
  player.handle_input(event);


func _on_move_input(input_vector: Vector2i) -> void:
  player.handle_move_input(input_vector);


func _connect_component_signals() -> void:
  # [TODO] Is this really where I want this? But where else would it go?
  inventory.heart_container_completed.connect(_on_heart_container_completed);


func _connect_input_signals() -> void:
  _move_input_repeater.input_triggered.connect(_on_move_input);


func _connect_ui_subsystem_signals() -> void:
  pass


func _catch_input_focus_when_focus_lost() -> void:
  if not get_viewport().gui_get_focus_owner():
    focus_node.grab_focus();
