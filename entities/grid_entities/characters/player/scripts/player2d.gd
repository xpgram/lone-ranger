## Represents a player entity.
class_name Player2D
extends GridEntity


## Emitted when an action the player would like to perform has been chosen.
signal action_declared(action: FieldActionSchedule, buffer: bool);

## Emitted when a player leaves a 'busy' state, one which suspends their participation
## in the game proper. [br]
##
## External features that depend on [Player2D] being stable and ready to participate
## should await [method wait_until_affairs_settled_async] as this signal is only emitted
## after some affair has been assumed.
signal _affairs_settled();

## Emitted after a Coyote Fall minigame, indicating whether the recovery QTE was
## successfully performed or not.
signal coyote_fall_recovered_result(recovered: bool);


## The player's collection of bits and bobs.
@export var inventory: PlayerInventory;


## Manages [Player2D] state.
var _state_machine := CallableStateMachine.new();

## The [StringName] of this player's current animation.
var current_animation_state: StringName = 'idle';

## A blackboard variable to retain a reference to the player's chosen command menu action.
var _selected_command_menu_action: FieldAction;

## A grid position that is safe to teleport the player to when they get stuck or lost
## (such as after falling into a pit).
var _last_safe_position: Vector2i;

# TODO Question: Player2D is bound to have tons of little metric numbers like this, do I
#   really want to list them all in this script right here? I could put this in a big
#   numbers repository resource, I guess.
## How many steps the player can take over pits before falling.
var _air_steps_remaining: int = 0;

## [b]Note:[/b] Use [method _unsettle_affairs] instead of setting this value directly. [br]
##
## Whether the player controller is free of preoccupations with animations or minigame-
## like activities that make their current board state unknowable or erratic, or that make
## them unable to participate in the normal procession of board game mechanics where it
## would be unfair to proceed without them.
var _affairs_are_settled := true;

## @nullable [br]
## A reference to the last-created coyote fall timer.
var _coyote_fall_timer: Timer;


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

# FIXME This should be their last reset point, probably something to do with the last seen
#   angel statue when I finally implement those.
## Where the player spawned in.
@onready var _starting_position: Vector2i = Grid.get_grid_coords(global_position);


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
      _state_coyote_fall,
      _state_coyote_fall__exit,
      _state_coyote_fall__move_input
    ]),
    PlayerState.new([
      _state_fall,
    ]),
    PlayerState.new([
      _state_death,
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
    _get_move_action(),
    _get_push_action(),
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
func get_action_from_interact_input() -> FieldActionSchedule:
  var chosen_action: FieldAction = FieldActionList.null_action;

  var playbill := FieldActionPlaybill.new(
    self,
    faced_position,
    faced_direction,
  );

  var actions := [
    FieldActionList.interact,
    _get_sword_action(),
  ];

  for action in actions:
    if action and action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);


## Returns the number of steps the player can take over pits before falling.
func get_air_steps_remaining() -> int:
  return _air_steps_remaining;

## Resets to full the [Player2D]'s air steps.
func reset_air_steps_remaining() -> void:
  _air_steps_remaining = (
    # FIXME Get these numbers from a constants file somewhere.
    1 if inventory.has_equipment(&'wings')
    else 0
  );


## Starts the Coyote Fall minigame, where the [Player2D] animates themselves falling into
## the tile it's facing, and the player has an opportunity to save themselves with a QTE. [br]
##
## The calling script should await [signal coyote_fall_recovered_result] to get the result
## of this QTE.
func start_coyote_fall() -> void:
  _state_machine.switch_to(_state_coyote_fall);


## Indicates the [Player2D] is preoccupied with something that prevents it from
## participating in the game proper. [br]
##
## This is a useful flag for game mechanics that depend on the player state being stable,
## predictable, and "ready to respond."
func _unsettle_affairs() -> void:
  _affairs_are_settled = false;


## Indicates the [Player2D] is free of preoccupations that would prevent it from
## participating in the game proper. [br]
##
## This is a useful flag for game mechanics that depend on the player state being stable,
## predictable, and "ready to respond."
func _settle_affairs() -> void:
  if _affairs_are_settled == false:
      _affairs_settled.emit();
  _affairs_are_settled = true;


## A coroutine that yields when the [Player2D] is not 'busy'. [br]
##
## To be 'busy' means that the [Player2D] is locked in some animation or minigame-like
## activity that makes certain aspects of itself not entirely knowable, or to which it
## would be unfair for a game mechanic to proceed without it. [br]
##
## An example of unsettled affairs: The recovery QTE played when a player is falling.
## During this activity, the player may fall into a pit tile they've moved to, or they may
## retreat quickly to the tile they moved from. In a sense, the player occupies [i]both[/i]
## of these tiles until the QTE has finished, which makes it difficult for other mechanics
## like enemy movement to know which tiles they are allowed to move to.
func wait_until_affairs_settled_async():
  if not _affairs_are_settled:
    await _affairs_settled;



## Sets the animation state to `param state_key`.
func set_animation_state(state_key: StringName) -> void:
  current_animation_state = state_key;
  animation_state_switch.play(state_key, faced_direction);


## Sets the player avatar's handheld item type to [param item_type].
func set_handheld_item(item_type: PlayerHandheldItem.HandheldItemType) -> void:
  $HandheldItem.set_item(item_type);


## Replays the active animation, but with current context, such as the faced direction,
## etc.
func retrigger_animation_state() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);


## Resets the animation state to the idle animation set.
func _on_animation_finished(_from_animation: StringName = '') -> void:
  # FIXME This function is not necessary anymore. 'injured' is a state now.
  #  'item_get!' should also be a state.
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


## Returns the [FieldAction] variant the [Player2D] will use for movement.
func _get_move_action() -> FieldAction:
  return FieldActionList.move;


## Returns the [FieldAction] variant the [Player2D] will use for pushing objects.
func _get_push_action() -> FieldAction:
  return (
    FieldActionList.shove if inventory.has_equipment('shove')
    else FieldActionList.push
  );


## Returns the [FieldAction] variant the [Player2D] will use for melee attacks.
func _get_sword_action() -> FieldAction:
  return (
    FieldActionList.sword_strike if inventory.has_equipment('sword')
    else FieldActionList.null_action
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


## Handler for when the player's HP is completely emptied.
func _on_health_empty() -> void:
  _state_machine.switch_to(_state_death);


func _on_entity_moved() -> void:
  if ActionUtils.place_is_idleable(grid_position, self):
    _last_safe_position = grid_position;
    reset_air_steps_remaining();

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
  if _air_steps_remaining <= 0:
    _state_machine.switch_to(_state_fall);
  else:
    _air_steps_remaining -= 1;


## The idle state is the "at rest" state. All, or most, player gameplay features can be
## accessed from here.
func _state_idle() -> void:
  set_animation_state('idle');


func _state_idle__exit() -> void:
  _interrupt_ui_subsystems();


func _state_idle__input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  elif event.is_action_pressed('interact'):
    var action_schedule := get_action_from_interact_input();
    if action_schedule.action != FieldActionList.null_action:
      action_declared.emit(get_action_from_interact_input(), false);
    focus_node.accept_event();

  elif event.is_action_pressed('open_action_menu'):
    _command_menu.open_from_start();
    focus_node.accept_event();


func _state_idle__move_input(input_vector: Vector2i) -> void:
  if Input.is_action_pressed('brace'):
    action_declared.emit(get_action_from_brace_move_input(input_vector), false);
  else:
    action_declared.emit(get_action_from_move_input(input_vector), false);


## The injured state handles player flinch animations and input suspension after losing HP.
func _state_injured() -> void:
  _unsettle_affairs();

  set_animation_state('injured');
  await get_tree().create_timer(0.5).timeout;
  _state_machine.switch_to(_state_idle);

  _settle_affairs();


## The coyote fall state occurs when the player is risking a fall into a pit or hole. This
## state runs a QTE minigame that succeeds or fails, and reports this result via
## [signal coyote_fall_recovered_result].
func _state_coyote_fall() -> void:
  _unsettle_affairs();

  set_animation_state('coyote_fall');

  # TODO A utils method for one-shot, auto-freeing Timers would be nice.
  #   The get_tree() method is nice for waits, but if such a timer ever needs to be
  #   cancelled, it has nothing to work with.
  _coyote_fall_timer = Timer.new();
  _coyote_fall_timer.wait_time = 0.75;
  _coyote_fall_timer.autostart = true;
  add_child(_coyote_fall_timer);

  _coyote_fall_timer.timeout.connect(func ():
    if not _state_machine.is_state(_state_coyote_fall):
      return;
    coyote_fall_recovered_result.emit(false);
  );


func _state_coyote_fall__exit() -> void:
  if _coyote_fall_timer:
    _coyote_fall_timer.stop();
    _coyote_fall_timer.queue_free();
  _settle_affairs();


func _state_coyote_fall__move_input(input_vector: Vector2i) -> void:
  if input_vector + faced_direction != Vector2i.ZERO:
    return;

  coyote_fall_recovered_result.emit(true);
  _state_machine.switch_to(_state_idle);


## The fall state is a transition state that handles the animation and effects of falling
## into a pit or hole.
func _state_fall() -> void:
  _unsettle_affairs();

  hide();

  # TODO A utils for creating one-shot vfx like this would be nice.
  var fall_effect := _scene_object_fall.instantiate() as OneShotEffect;
  fall_effect.position = position;
  add_sibling(fall_effect);
  await fall_effect.animation_finished;

  grid_position = _last_safe_position;

  show();

  # FIXME Put this damn thing in an @onready already.
  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  health_component.value -= 1;

  _settle_affairs();


## The death state handles death animations and resets some player systems before
## triggering a revive at the last checkpoint.
func _state_death() -> void:
  _unsettle_affairs();

  _interrupt_ui_subsystems();
  set_animation_state('injured');

  var fade_out_time := 1.5;
  var fade_in_time := 1.0;
  var fade_transition := Tween.TRANS_SINE;

  # Fade out.
  await get_tree().create_timer(0.5).timeout;
  var fade_tween := get_tree().create_tween();
  fade_tween.set_trans(fade_transition);
  fade_tween.set_ease(Tween.EASE_IN);
  fade_tween.tween_method(_shader_rect.set_fade_in, 1.0, 0.0, fade_out_time);
  await fade_tween.finished;

  # Reset player state.
  set_animation_state('idle');
  grid_position = _starting_position;
  faced_direction = Vector2i.DOWN;

  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  health_component.set_hp_to_full();

  # Fade in.
  await get_tree().create_timer(3.0).timeout;
  fade_tween = get_tree().create_tween();
  fade_tween.set_trans(fade_transition);
  fade_tween.set_ease(Tween.EASE_OUT);
  fade_tween.tween_method(_shader_rect.set_fade_in, 0.0, 1.0, fade_in_time);
  await fade_tween.finished;

  _state_machine.switch_to(_state_idle);

  _settle_affairs();


class PlayerState extends CallableState:
  func _get_role_keywords() -> Array[StringName]:
    return super._get_role_keywords() + ([
      &'move_input'
    ] as Array[StringName]);

  func move_input(vector: Vector2i) -> void:
    _call_role_func(&'move_input', [vector]);
