## Recieves and delegates user input to any controlled [Player2D] objects.
class_name PlayerInputReciever
extends Node


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


# [TODO] These methods are unnecessary. I'm going to have the copy players manage themselves
#     a little more. They'll add themselves to a group, and either they or something else will
#     save the last input for them, which they can just replay later.
func _unhandled_input(event: InputEvent) -> void:
  player.handle_input(event);

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
