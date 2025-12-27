class_name Player2D
extends GridEntity


signal action_declared(action: FieldActionSchedule, buffer: bool);


##
@export var inventory: PlayerInventory;


##
var current_animation_state: StringName = 'idle';


##
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

##
@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;

##
@onready var focus_node: FocusableControl = %FocusableControl;

##
@onready var _command_menu: CommandMenu = %CommandMenu;


func _init() -> void:
  add_to_group(Group.Player);


func _ready() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);
  animation_player.animation_finished.connect(_on_animation_finished);

  # Pass through command menu actions as own actions.
  _command_menu.action_selected.connect(func (action: FieldAction):
    var playbill := FieldActionPlaybill.new(self, faced_position, faced_direction);
    var schedule := FieldActionSchedule.new(action, playbill);
    action_declared.emit(schedule, true);
  );

  # Setup focus control.
  focus_node.grab_focus();
  _command_menu.closed.connect(func (): focus_node.grab_focus());


func _process(_delta: float) -> void:
  if not get_viewport().gui_get_focus_owner():
    focus_node.grab_focus();


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  # If 'brace' is held, then hold position for movement inputs.
  if Input.is_action_pressed('brace'):
    if event.is_action_pressed('move_up'):
      action_declared.emit(get_action_from_brace_move_input(Vector2.UP), false);
      focus_node.accept_event();
      return;

    elif event.is_action_pressed('move_down'):
      action_declared.emit(get_action_from_brace_move_input(Vector2.DOWN), false);
      focus_node.accept_event();
      return;

    elif event.is_action_pressed('move_left'):
      action_declared.emit(get_action_from_brace_move_input(Vector2.LEFT), false);
      focus_node.accept_event();
      return;

    elif event.is_action_pressed('move_right'):
      action_declared.emit(get_action_from_brace_move_input(Vector2.RIGHT), false);
      focus_node.accept_event();
      return;

  elif event.is_action_pressed('move_up'):
    action_declared.emit(get_action_from_move_input(Vector2.UP), false);
    focus_node.accept_event();

  elif event.is_action_pressed('move_down'):
    action_declared.emit(get_action_from_move_input(Vector2.DOWN), false);
    focus_node.accept_event();

  elif event.is_action_pressed('move_left'):
    action_declared.emit(get_action_from_move_input(Vector2.LEFT), false);
    focus_node.accept_event();

  elif event.is_action_pressed('move_right'):
    action_declared.emit(get_action_from_move_input(Vector2.RIGHT), false);
    focus_node.accept_event();

  elif event.is_action_pressed('interact'):
    action_declared.emit(get_interact_action(), false);
    focus_node.accept_event();

  elif event.is_action_pressed('open_action_menu'):
    _command_menu.open_from_start();
    focus_node.accept_event();


func get_wait_action() -> FieldActionSchedule:
  return FieldActionSchedule.new(
    FieldActionList.wait,
    FieldActionPlaybill.new(
      self,
      grid_position,
      faced_direction,
    )
  );


func get_action_from_move_input(direction: Vector2i) -> FieldActionSchedule:
  var chosen_action: FieldAction = FieldActionList.wait;

  var playbill := FieldActionPlaybill.new(
    self,
    grid_position + direction,
    direction,
  );

  var actions := [
    FieldActionList.move,
    FieldActionList.push,
    FieldActionList.spin,
  ] as Array[FieldAction];

  for action in actions:
    if action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);


func get_action_from_brace_move_input(direction: Vector2i) -> FieldActionSchedule:
  var chosen_action: FieldAction = FieldActionList.wait;
  var playbill := FieldActionPlaybill.new(
    self,
    grid_position + direction,
    direction,
  );

  if FieldActionList.spin.can_perform(playbill):
    chosen_action = FieldActionList.spin;

  return FieldActionSchedule.new(chosen_action, playbill);


func get_interact_action() -> FieldActionSchedule:
  var chosen_action: FieldAction = FieldActionList.wait;

  var playbill := FieldActionPlaybill.new(
    self,
    faced_position,
    faced_direction,
  );

  var actions := [
    FieldActionList.interact,
  ];

  for action in actions:
    if action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);


## Sets the animation state to `param state_key`.
func set_animation_state(state_key: StringName) -> void:
  current_animation_state = state_key;
  animation_state_switch.play(state_key, faced_direction);


## Resets the animation state to the idle animation set.
func _on_animation_finished(_from_animation: StringName = '') -> void:
  var non_resetting_states: Array[StringName] = [
    &'item_get!',
  ];

  if current_animation_state in non_resetting_states:
    return;

  set_animation_state('idle');
