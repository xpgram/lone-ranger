## Represents a player entity.
class_name Player2D
extends GridEntity


## Emitted when an action the player would like to perform has been chosen.
signal action_declared(action: FieldActionSchedule, buffer: bool);


## The player's collection of bits and bobs.
@export var inventory: PlayerInventory;


##
var _state_machine := CallableStateMachine.new();

## The [StringName] of this player's current animation.
var current_animation_state: StringName = 'idle';

## A blackboard variable to retain a reference to the player's chosen command menu action.
var _selected_command_menu_action: FieldAction;

## A grid position that is safe to teleport the player to when they get stuck or lost
## (such as after falling into a pit).
var _last_safe_position: Vector2i;


##
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

##
@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;

##
@onready var focus_node: FocusableControl = %FocusableControl;

##
@onready var _move_input_repeater: InputAxisRepeater = %MoveInputRepeater;

## The player's unique [CommandMenu] instance.
@onready var _command_menu: CommandMenu = %CommandMenu;

## The player's unique [FieldCursor] instance.
@onready var _field_cursor: FieldCursor = %FieldCursor;

##
@onready var _shader_rect: ScreenSpaceShader = %ScreenSpaceShaderRect


func _init() -> void:
  add_to_group(Group.Player);


func _ready() -> void:
  super._ready();

  animation_state_switch.play(current_animation_state, faced_direction);
  animation_player.animation_finished.connect(_on_animation_finished);

  _assemble_machine_states();
  _bind_inherited_signals();
  _bind_input_signals();

  _connect_to_ui_subsystems();
  focus_node.grab_focus();


func _process(_delta: float) -> void:
  if not get_viewport().gui_get_focus_owner():
    focus_node.grab_focus();


func _unhandled_input(event: InputEvent) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.input(event);


## Responds to movement input events, where [param input_vector] is the direction to move
## in.
func _on_move_input(input_vector: Vector2i) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.move_input(input_vector);


## Builds the Player2D state machine out of its state-related functions.
func _assemble_machine_states() -> void:
  _state_machine.add_states([
    PlayerState.new([
      _state_idle,
      _state_idle__input,
      _state_idle__move_input
    ]),
    PlayerState.new([
      _state_injured,
    ]),
    PlayerState.new([
      _state_falling,
      _state_falling__input,
      _state_falling__move_input
    ]),
  ]);

  _state_machine.switch_to(_state_idle);


## Attaches callbacks to signals emitted by the extended script.
func _bind_inherited_signals() -> void:
  entity_moved.connect(_on_entity_moved);


## Attaches callbacks to input monitor signals.
func _bind_input_signals() -> void:
  _move_input_repeater.input_triggered.connect(_on_move_input);


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


## Replays the active animation, but with current context, such as the faced direction,
## etc.
func retrigger_animation_state() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);


## Resets the animation state to the idle animation set.
func _on_animation_finished(_from_animation: StringName = '') -> void:
  # FIXME This is not necessary anymore; 'injured' won't end on its own, player state can
  #   control which animations are active and when.
  #
  #   Except this is necessary for animations like "Item Get!", I think.
  #   Actually, see this? Why does item_get! not reset again? I don't remember.
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
  health_component.value_changed.connect(_on_health_changed);
  health_component.empty.connect(_on_health_empty);

  health_component.value_changed.connect(func (value: int, _old_Value: int):
    if value != 0:
      # FIXME The color used probably shouldn't be defined here.
      _shader_rect.pulse_color(
        Color.from_hsv(352.0 / 360.0, 0.75, 1.0),
        Color.from_hsv(  8.0 / 360.0, 0.75, 1.0),
      );
  );


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
    _state_machine.switch_to(_state_injured);


# FIXME Add an actual death state and restart sequence instead of whatever this is:
@onready var _starting_position: Vector2i = Grid.get_grid_coords(global_position);
## Handler for when the player's HP is completely emptied.
func _on_health_empty() -> void:
  _interrupt_ui_subsystems();
  grid_position = _starting_position;

  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  health_component.set_hp_to_full();


func _on_entity_moved() -> void:
  if ActionUtils.place_is_idleable(grid_position, self):
    _last_safe_position = grid_position;

  # FIXME Consider that this is a side-effect. Are we sure this won't interfere with
  #   FieldAction scripted animations? They set an animation, then move the actor, not
  #   realizing that movement also sets the animation?
  #
  #   The falling state is handled via Stimulus, maybe resting neatly on solid ground
  #   should also trigger a Stimulus.
  set_animation_state('idle');


func _facing_changed() -> void:
  retrigger_animation_state();


func _on_free_fall() -> void:
  # TODO Implement fall certainty (cannot move further spaces while falling)
  # TODO Implement fall recovery (can retreat to safe position while falling)
  # TODO Implement turn consistency (enemies do not act until falling is complete)
  # TODO Implement fall animation (for now, can be simple shaking)

  # _on_free_fall needs to change the player's state.
  # While we are in the Falling state,
  #   TurnManager considers the Player 'busy' and will not advance time,
  #   Most Player inputs are ignored, leaving only the retreat button,
  #   A timer is started, which will trigger the fall's effects when finished.
  #
  # What does player state look like in this turn-based game?
  # I'm gonna think about it in the shower, maybe.

  # CallableStateMachine needs to implement the struct assembler and unhandled_input.
  # Player2D changes which unhandled_input it uses depending on its state.

  _state_machine.switch_to(_state_falling);


## The Idle state enter function.
func _state_idle() -> void:
  set_animation_state('idle');

  # IMPLEMENT Should nullify Player2D's busy status, allowing TurnManager to advance time again.
  pass


func _state_idle__exit() -> void:
  _interrupt_ui_subsystems();


func _state_idle__input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  elif event.is_action_pressed('interact'):
    action_declared.emit(get_interact_action(), false);
    focus_node.accept_event();

  elif event.is_action_pressed('open_action_menu'):
    _command_menu.open_from_start();
    focus_node.accept_event();


func _state_idle__move_input(input_vector: Vector2i) -> void:
  if Input.is_action_pressed('brace'):
    action_declared.emit(get_action_from_brace_move_input(input_vector), false);
  else:
    action_declared.emit(get_action_from_move_input(input_vector), false);


## The Injured state enter function.
func _state_injured() -> void:
  # FIXME The animation state has something that prevents input. I don't know how.
  #   This injured state should be sufficient, now, so that needs to be removed.
  # TODO Also, the injured animation should loop now.
  set_animation_state('injured');

  # IMPLEMENT Should notify TurnManager somehow that Player2D is busy.

  await get_tree().create_timer(0.5).timeout;
  _state_machine.switch_to(_state_idle);


## The Falling state enter function.
func _state_falling() -> void:
  set_animation_state('coyote_fall');
  # IMPLEMENT Should notify TurnManager somehow that Player2D is busy.

  # FIXME If falling kills you, you get teleported somewhere while still in the falling state.
  #   This ought to be fixed just fine by a proper death state, which I need for animations anyway.
  # FIXME This timer needs to be reset between different falls.
  get_tree().create_timer(0.75).timeout.connect(func ():
    if not _state_machine.is_state(_state_falling):
      return;

    # Injure and reset player position.
    grid_position = _last_safe_position;

    var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
    health_component.value -= 1;
  );


func _state_falling__input(_event: InputEvent) -> void:
  # IMPLEMENT Should accept nothing. 'Floating' or 'standing' is probably where flying movements happen.
  pass


func _state_falling__move_input(input_vector: Vector2i) -> void:
  if input_vector + faced_direction != Vector2i.ZERO:
    return;

  grid_position += input_vector;
  _state_machine.switch_to(_state_idle);


class PlayerState extends CallableState:
  func _get_default_role() -> StringName:
    return &'enter';

  func _get_role_keywords() -> Array[StringName]:
    var keywords: Array[StringName];
    keywords.assign(
      super._get_role_keywords() + [
        &'move_input'
      ]
    );

    return keywords;

  func move_input(vector: Vector2i) -> void:
    _call_role_func(&'move_input', [vector]);
