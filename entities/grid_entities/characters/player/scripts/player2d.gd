## Represents a player entity.
class_name Player2D
extends GridEntity


## Emitted when an action the player would like to perform has been chosen.
signal action_declared(action: FieldActionSchedule, buffer: bool);


## The player's collection of bits and bobs.
@export var inventory: PlayerInventory;


## The [StringName] of this player's current animation.
var current_animation_state: StringName = 'idle';

## A blackboard variable to retain a reference to the player's chosen command menu action.
var _selected_command_menu_action: FieldAction;


##
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

##
@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;

##
@onready var focus_node: FocusableControl = %FocusableControl;

## The player's unique [CommandMenu] instance.
@onready var _command_menu: CommandMenu = %CommandMenu;

## The player's unique [FieldCursor] instance.
@onready var _field_cursor: FieldCursor = %FieldCursor;


func _init() -> void:
  add_to_group(Group.Player);


func _ready() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);
  animation_player.animation_finished.connect(_on_animation_finished);

  _connect_to_ui_subsystems();
  focus_node.grab_focus();


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


## Returns the [FieldActionSchedule] for a Wait action respective to this player.
func get_wait_action() -> FieldActionSchedule:
  return FieldActionSchedule.new(
    FieldActionList.wait,
    FieldActionPlaybill.new(
      self,
      grid_position,
      faced_direction,
    )
  );


## Returns a [FieldActionSchedule] for some action resulting from directional input.
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


## Returns a [FieldActionSchedule] for some action resulting from directional input while
## the brace input is also active.
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


## Returns the [FieldActionSchedule] for some action resulting from an interact input.
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


## Makes signal connections to the player's [CommandMenu] and [FieldCursor] instances.
func _connect_to_ui_subsystems() -> void:
  _command_menu.ui_canceled.connect(_on_command_menu_cancelled);
  _command_menu.action_selected.connect(_on_command_menu_action_selected);

  _field_cursor.ui_canceled.connect(_on_field_cursor_canceled);
  _field_cursor.grid_position_selected.connect(_on_field_cursor_location_selected);

  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  health_component.meter.value_changed.connect(_on_health_changed);
  health_component.meter.empty.connect(_on_health_empty);


## Event handler for [signal CommandMenu.ui_canceled]. [br]
## Reacquires player input focus from sub-UI systems.
func _on_command_menu_cancelled() -> void:
  _selected_command_menu_action = null;
  focus_node.grab_focus();


## Event handler for [signal CommandMenu.action_selected]. [br]
## Saves a reference to the chosen [FeildAction] and advances the sub-UI system to the
## [FieldCursor].
func _on_command_menu_action_selected(action: FieldAction) -> void:
  _selected_command_menu_action = action;
  _command_menu.close();
  _field_cursor.open_from_start();


## Event handler for [signal FieldCursor.ui_canceled]. [br]
## Yields input focus back to the [CommandMenu].
func _on_field_cursor_canceled() -> void:
  _command_menu.open();


## Event handler for [signal FieldCursor.grid_position_selected]. [br]
## Builds and emits a [FieldActionSchedule] for the chosen [FieldAction] and target
## coordinates. Also, yields input focus back to the player.
func _on_field_cursor_location_selected(target_pos: Vector2i) -> void:
  _field_cursor.close();
  focus_node.grab_focus();

  # TODO Command Menu action orientation is obtained from the FieldCursor.
  var orientation := ActionUtils.get_direction_to_target(grid_position, target_pos);

  var playbill := FieldActionPlaybill.new(self, target_pos, orientation);
  var schedule := FieldActionSchedule.new(_selected_command_menu_action, playbill);
  action_declared.emit(schedule, true);


## Closes the player's UI subsystems and forces input focus back into the primary
## character controller.
func _interrupt_ui_subsystems() -> void:
  _field_cursor.close();
  _command_menu.close();
  focus_node.grab_focus();


## Handler for when the player's HP changes value.
func _on_health_changed(value: int, old_value: int) -> void:
  if value < old_value and value != 0:
    _interrupt_ui_subsystems();
    set_animation_state('injured');


# FIXME Add an actual death state and restart sequence instead of whatever this is:
@onready var _starting_position: Vector2i = Grid.get_grid_coords(global_position);
## Handler for when the player's HP is completely emptied.
func _on_health_empty() -> void:
  _interrupt_ui_subsystems();
  grid_position = _starting_position;
  
  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  health_component.meter.value = health_component.meter.maximum;
