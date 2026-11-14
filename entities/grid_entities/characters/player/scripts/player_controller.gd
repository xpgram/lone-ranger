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


# [TODO] Wait, I can't have this. I have to access this through Player2D, don't I?
## A reference to the animation player.
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

# [TODO] This... may need to stay in Player2D. I'm not sure.
##
@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;

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

# [TODO] This should be given to the position ledger in _ready().
## Where the player spawned in.
@onready var _revive_position: Vector2i = Grid.get_grid_coords(player.global_position);


func _init() -> void:
  add_to_group(Group.Player);


func _ready() -> void:
  _assemble_machine_states();
  _set_starting_values();

  _connect_component_signals();
  _connect_input_signals();
  _connect_ui_subsystem_signals();


func _process(_delta: float) -> void:
  _catch_input_focus_when_focus_lost();


func _unhandled_input(event: InputEvent) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.input(event);


func _on_move_input(input_vector: Vector2i) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.move_input(input_vector);


func _assemble_machine_states() -> void:
  _state_machine.add_states([
    PlayerState.new([
      _state_idle,
      _state_idle__input,
      _state_idle__move_input,
    ]),
    PlayerState.new([
      _state_injured,
    ]),
    PlayerState.new([
      _state_coyote_fall,
      _state_coyote_fall__exit,
      _state_coyote_fall__move_input,
    ]),
    PlayerState.new([
      _state_fall,
    ]),
    PlayerState.new([
      _state_death,
    ]),
    PlayerState.new([
      _state_sleep,
    ]),
  ]);

  _state_machine.switch_to(_state_idle);


func _set_starting_values() -> void:
  _grid_position_ledger.set_respawn_point(player.grid_position);

  # [TODO] This should definitely be a member call, like player.set_animation('idle') or something.
  animation_state_switch.play(current_animation_state, player.faced_direction);


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




## A [CallableState] that provides additional state methods for Player2D objects.
class PlayerState extends CallableState:

  func _get_role_keywords() -> Array[StringName]:
    return super._get_role_keywords() + ([
    &'move_input'
    ] as Array[StringName]);

  func move_input(vector: Vector2i) -> void:
    _call_role_func(&'move_input', [vector]);
