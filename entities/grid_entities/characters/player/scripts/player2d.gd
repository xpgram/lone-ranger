## Represents a player entity.
class_name Player2D
extends GridEntity


# [TODO] Finish refactoring Player2D to be less of a junk-drawer.
# [TODO] Think about how to separate PlayablePlayer2D from DirectablePlayer2D.
#     "Directable" meaning the copies. They don't need to know about any "camera", for
#     instance.
# [TODO] Make sure each use of 'subsystem' first checks that subsystem exists.
#     Copied players have the attribute mirror_entity and have no subsystem package (== null).
# [TODO] Break off methods irrelevant to Player2D into this PlayerInterface, and also
#     submodules like animation controller as needed.
# [TODO] (Try to) break off methods relevant to Player2D but irrelevant to Player2D-copies
#     into submodules and such.
# [TODO] Add a get_action_from_input(input: PlayerInputStruct) -> FieldActionSchedule
#   - This may return null.
#   - PlayerInputStruct has two fields:
#       - pressed_action: StringName ("interact", "cancel", "open_menu", etc.)
#       - move_vector: Vector2i
# [TODO] _unhandled_input and _on_move_input both do some preliminary checking, and
#     eventually route their input into this _get_action_from_input(), then emit the
#     field_action_declared() signal with the result, if it wasn't null.
#     The PlayerInputStruct they created as part of this process is stored... somewhere.
#     A child node that adds itself to a public Group, maybe.
# [TODO] Add a replay_saved_action() that is similar to _unhandled_input and
#     _on_move_input, but takes its struct from the public store. Naturally, this method
#     is for the player-copies.


# [TODO] Create a 3D mockup that is mega simplified. No Grid, no collision, yes controls
#     that warp you in a grid-like fashion.
#     Use 2D billboards for characters (yourself, enemies), and use the floor textures on
#     3D models.
#     Port over the pixelation and color shader stuff, too.
#     See how it feels to look at the game in 3D.
#     I imagine it feeling a bit like Pokemon gen 4 and 5.


## Emitted when an action the player would like to perform has been chosen.
signal action_declared(action: FieldActionSchedule, buffer_this: bool);

## Emitted when the coyote fall minigame has concluded. Carries the result of the QTE
## event.
signal coyote_fall_recovered_result(recovered: bool);


## An object for tracking player values, typically ones that change with further gameplay.
## Not all values are kept here, however: health is measured by HealthComponent, a system
## to make it more accessible to other nodes.
@export var stats: PlayerStats;

## @nullable [br]
## A node that contains references to various other player systems.
@export var subsystem: PlayerSubsystemPackage;


# [TODO] An enum instead of strings?
## The [StringName] of this player's current animation.
var current_animation_state: StringName = 'idle';

## Keeps track of coordinates on the Grid previously inhabited by the player.
## Used for trailing or for finding places to teleport the player after a fall
## or death.
var grid_position_ledger := GridPositionLedger.new();

## A lock representing whether the player object is internally busy and should ignore
## interrupting behavior like from player input. [br]
##
## Generally used when the player object is preoccupied with animations or minigames that
## make the current board state unknowable or erratic, or that make it unable to
## participate in the normal procession of game mechanics where it would be unfair to
## proceed without them.
var _busy_lock := MultiPadlock.new();

## @nullable [br]
## A reference to the last-created coyote fall timer.
var _coyote_fall_timer: Timer;

# [TODO] This is clutter.
#     This is less confusing then using `remaining_air_steps = -1` for the same
#     purpose... uh, maybe. But it's an extra value to fret over, and it's
#     certainly bothersome -here-.
#     It'd be nice, I think, if I could change the nature of the idle state. I mean,
#     that's sort of what I'm doing anyway, but less officially. Sometimes Idle is
#     standing and sometimes it's flying, but there is no IdleState struct to track
#     this information. Except for this boolean, right here.
## True if the player is currently floating over a gap with the wings.
var _is_using_wings := false;

# [TODO] This ought to be moved to a UI management node. Player2D doesn't really need
#     to know about this.
## A blackboard variable to retain a reference to the player's chosen command menu action.
var _selected_command_menu_action: FieldAction;

## A reference to the player-controller state machine.
var _state_machine := CallableStateMachine.new();


##
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

##
@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;


func _init() -> void:
  # [FIXME] Problem: How does a new Player2D know not to add itself to the player group
  #     if the only way to tell it it's a copy is _after_ initialization?
  # How can we solve this...
  #  - Inheritance: override the _init method.
  #  - Ask player group pullers (who mostly use ActionUtils anyway) to filter the list of "players"
  #    down to the real player (or non-real ones).
  #  - Rediscover why this is in _init anyway, and move it to _ready. (I believe Player needs to be added
  #    to the player group quickly so that other objects can reference them. It's acting as a distinct
  #    game setup phase.)
  #
  # If I need distinct game setup phases... maybe I should add Events that a game-controller can call
  # in sequence in its own ready step. This would be after Godot's other setup phases are all completed.
  # But this way, objects could define _ready, add a listener for Events.post_setup_1 or whatever, and
  # do what they need to there instead.
  add_to_group(Group.Player);


func _ready() -> void:
  super._ready();
  _assemble_machine_states();
  _connect_signals();
  _set_starting_values();


## Delegates an [InputEvent] to the object's current state handler for inputs.
func _unhandled_input(event: InputEvent) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.input(event);


## Delegates an input [Vector2i] to the object's current state handler for movement
## inputs.
func _on_move_input(input_vector: Vector2i) -> void:
  var state := _state_machine.get_state() as PlayerState;
  state.move_input(input_vector);


## Builds the Player2D state machine out of its state-related functions.
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
    # [TODO] Coyote fall should be a feature of PlayerController, or at least should be
    #     some conversation betweeen the controller and Player2D.
    PlayerState.new([
      _state_coyote_fall,
      _state_coyote_fall__exit,
      _state_coyote_fall__move_input,
    ]),
    PlayerState.new([
      _state_fall,
    ]),
    # [TODO] Death and sleep have different effects when you're a copy. How do we do that?
    #     I guess they need to know whether they're "main" or not.
    PlayerState.new([
      _state_death,
    ]),
    PlayerState.new([
      _state_sleep,
    ]),
  ]);

  _state_machine.switch_to(_state_idle);


func _set_starting_values() -> void:
  grid_position_ledger.set_revive_point(grid_position);
  grid_position_ledger.log_position(grid_position);

  animation_state_switch.play(current_animation_state, faced_direction);


func _connect_signals() -> void:
  _connect_component_signals();
  _connect_subsystem_signals();
  _connect_to_ui_subsystems();


## Connects to signals emitted by owned [Component]s.
func _connect_component_signals() -> void:
  var health := Component.getc(self, HealthComponent) as HealthComponent;
  health.value_changed.connect(_on_health_changed);
  health.empty.connect(_on_health_empty);

  animation_player.animation_finished.connect(_on_animation_finished);


## Connects to signals from child objects.
func _connect_subsystem_signals() -> void:
  if not subsystem:
    return;

  subsystem.inventory.equipment_changed.connect(_on_equipment_changed__recalc_stats);
  subsystem.inventory.heart_container_completed.connect(_on_heart_container_completed);

  subsystem.move_input_repeater.input_triggered.connect(_on_move_input);


## Connects to signals from the player's user-interface objects, like the Command Menu,
## the Field Cursor, the Dialogue Box, the health meter, etc.
func _connect_to_ui_subsystems() -> void:
  if not subsystem:
    return;

  subsystem.command_menu.ui_canceled.connect(_on_command_menu_cancelled);
  subsystem.command_menu.action_selected.connect(_on_command_menu_action_selected);
  subsystem.command_menu.action_inspected.connect(_on_command_menu_action_inspected);

  subsystem.field_cursor.ui_canceled.connect(_on_field_cursor_canceled);
  subsystem.field_cursor.grid_position_selected.connect(_on_field_cursor_location_selected);

  subsystem.dialogue_bubble.dialogue_closed.connect(_on_dialogue_bubble_closed);



## Returns if or when the player object is no longer busy handling an unstable state,
## such as a minigame QTE, some complicated animation, etc.
func affairs_settled_async() -> void:
  await _busy_lock.until_all_unlocked_async();


# [TODO] Could this be a part of the animation submodule?
#     If it were public, right? Isn't this public method for other scripts, like the
#     FieldAction for using the Hookshot, to work with?
## @nullable [br]
## Returns the node object associated with [param item_type], or null if no association
## exists.
func get_handheld_tool(item_type: PlayerHandheldItem.HandheldItemType) -> Node2D:
  return $HandheldItem.get_tool_node(item_type);


## Resets to full all player stats that represent exhaustion, such as HP.
func replenish_all() -> void:
  var health := Component.getc(self, HealthComponent) as HealthComponent;
  health.set_hp_to_full();


# [TODO] Why is this public, again?
## Replays the active animation, but with current context, such as the faced direction,
## etc.
func retrigger_animation_state() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);


## Sets the animation state to `param state_key`.
func set_animation_state(state_key: StringName) -> void:
  current_animation_state = state_key;
  animation_state_switch.play(state_key, faced_direction);


# [TODO] Could this be a part of the animation submodule?
#     If those modules were public, I think. This method is for scripts like Hookshot_FieldAction
#     to use, if I remember.
## Sets the player avatar's handheld item type to [param item_type].
func set_handheld_item(item_type: PlayerHandheldItem.HandheldItemType) -> void:
  $HandheldItem.set_item(item_type);


## Starts the Coyote Fall minigame, where the [Player2D] animates themselves falling into
## the tile it's facing, and the player has an opportunity to save themselves with a QTE. [br]
##
## The calling script should await [signal coyote_fall_recovered_result] to get the result
## of this QTE.
func start_coyote_fall() -> void:
  _state_machine.switch_to(_state_coyote_fall);


## Sets the animation state to a variant of the idle animation dependent on environment
## context.
func trigger_idle_animation_state() -> void:
  # [TODO] Instead of trigger_idle(), shouldn't set_animation('idle') assume an idle variant?
  #     We could set is_flying on the animation object, and it would interpret all animation
  #     state calls thusly.
  #     This could work out better, anyway, because not every animation state has wings enabled.
  #     Like, Push doesn't, right? But if the wings were a separate feature, enabled with
  #     whatever animation was active whenever the wings were being used, everything would
  #     work wonderfully.
  if (
      not ActionUtils.place_is_standable(grid_position)
      and _is_using_wings
  ):
    set_animation_state('flying');
  else:
    set_animation_state('idle');


## Triggers the player state 'sleep', which behaves somewhat like 'death' in that the
## player is sent back to their last checkpoint and the world's state is reset.
func trigger_sleep() -> void:
  _state_machine.switch_to(_state_sleep);


#region Move to submodule script
# [TODO] Dialogue Package
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
  if not subsystem:
    return;

  subsystem.dialogue_bubble.start(resource, cue, extra_game_states);


# [TODO] Dialogue Package
## Starts a dialogue bubble to read out the scene described by [param scene].
func start_inspect_dialogue(scene: InspectObject_DialogueScene) -> void:
  if not subsystem:
    return;

  subsystem.dialogue_context_inspection_target.target = scene.inspection_subject;
  subsystem.dialogue_bubble.start(scene.dialogue_resource, scene.dialogue_cue, scene.extra_game_states);


# [TODO] These are provided by the public property 'subsystem', so... I guess they're unnecessary.
# [TODO] UI Package / Camera Package
## Returns a reference to the player's camera-view shader interface.
func get_cam_view_shader() -> PlayerCameraViewShader:
  if not subsystem:
    return null;

  return subsystem.world_shader_rect;


# [TODO] UI Package / Camera Package
## Returns a reference to the player's HUD shader interface.
func get_hud_shader() -> PlayerHUDShader:
  if not subsystem:
    return null;

  return subsystem.hud_shader_rect;


# [TODO] UI Package / Camera Package
## Returns a reference to the player's screen-space shader interface.
func get_screen_shader() -> PlayerScreenSpaceShader:
  if not subsystem:
    return null;

  return subsystem.screen_shader_rect;


# [TODO] Move to an input-focus-manager node.
#     The command menu process is (potentially) fairly complicated. Not all commands are routed
#     through the FieldCursor, maybe, or maybe they need you to select two places, etc.
#     So, Player2D shouldn't handle that, an InputFocusDelegator node should, and Player2D
#     should just invoke it from the outside.
#     Player2D emits pause() or command_menu(), and InputFocusDelegator responds to it by
#     shifting focus to the relevant context.
## Event handler for [signal CommandMenu.action_selected]. [br]
## Saves a reference to the chosen [FeildAction] and advances the sub-UI system to the
## [FieldCursor].
func _on_command_menu_action_selected(action: FieldAction) -> void:
  if not subsystem:
    return;

  _selected_command_menu_action = action;
  subsystem.command_menu.close();
  subsystem.field_cursor.open_from_start(action);


# [TODO] Move to an input-focus-manager node.
## Responds to 'inspect' inputs signaled by the command menu.
func _on_command_menu_action_inspected(action: FieldAction) -> void:
  if not subsystem:
    return;

  var dialogue = DialogueManager.create_resource_from_text(action.action_hint);
  subsystem.dialogue_bubble.start(dialogue);


# [TODO] Move to an input-focus-manager node.
## Event handler for [signal CommandMenu.ui_canceled]. [br]
## Reacquires player input focus from sub-UI systems.
func _on_command_menu_cancelled() -> void:
  if not subsystem:
    return;

  _selected_command_menu_action = null;
  subsystem.focus_node.grab_focus();


# [TODO] Move to an input-focus-manager node.
## Event handler for [signal FieldCursor.ui_canceled]. [br]
## Yields input focus back to the [CommandMenu].
func _on_field_cursor_canceled() -> void:
  if not subsystem:
    return;

  subsystem.command_menu.open();


# [TODO] Move to an input-focus-manager node.
## Event handler for [signal FieldCursor.grid_position_selected]. [br]
## Builds and emits a [FieldActionSchedule] for the chosen [FieldAction] and target
## coordinates. Also, yields input focus back to the player.
func _on_field_cursor_location_selected(target_pos: Vector2i) -> void:
  if not subsystem:
    return;

  var orientation := ActionUtils.get_direction_to_target(grid_position, target_pos);

  var playbill := FieldActionPlaybill.new(self, target_pos, orientation);
  var schedule := FieldActionSchedule.new(_selected_command_menu_action, playbill);

  if _selected_command_menu_action.can_perform(playbill):
    subsystem.field_cursor.close();
    subsystem.focus_node.grab_focus();
    action_declared.emit(schedule, true);
  else:
    subsystem.field_cursor.play_error();


# [TODO] Move to an input-focus-manager node.
## Responds to the dialogue bubble being closed and releasing input focus.
func _on_dialogue_bubble_closed() -> void:
  if not subsystem:
    return;

  if subsystem.command_menu.visible:
    subsystem.command_menu.regrab_focus();


# [TODO] Move to an input-focus-manager node.
## Closes the player's UI subsystems and forces input focus back into the primary
## character controller.
func _interrupt_ui_subsystems() -> void:
  if not subsystem:
    return;

  subsystem.field_cursor.close();
  subsystem.command_menu.close();
  subsystem.dialogue_bubble.close();
  subsystem.focus_node.grab_focus();


# [TODO] Move to an input-focus-manager node.
## Closes player UI subsystems that are unrelated to combat and other essential
## game mechanics.
func _interrupt_nonemergency_ui_subsystems() -> void:
  if not subsystem:
    return;

  subsystem.dialogue_bubble.close();
  # [FIXME] Improve input focus management.
#endregion Move to submodule script


## Resets the animation state to the idle animation set.
func _on_animation_finished(_from_animation: StringName = '') -> void:
  # [FIXME] This function is not necessary anymore. 'injured' is a state now.
  #  'item_get!' should also be a state.
  var non_resetting_states: Array[StringName] = [
    &'item_get!',
  ];

  if current_animation_state in non_resetting_states:
    return;

  trigger_idle_animation_state();


# [TODO] Player copies don't need this.
## Reassess the player's equipment and modify their stats accordingly.
func _on_equipment_changed__recalc_stats(items: Array[StringName]) -> void:
  stats.air_steps_remaining.maximum = (
    1 if items.has(PlayerEquipment.wings)
    else 0
  );


# [TODO] This should be _on_facing_changed, right? But it's defined in GridEntity.
func _facing_changed() -> void:
  retrigger_animation_state();


func _on_free_fall() -> void:
  if stats.air_steps_remaining.is_empty():
    _is_using_wings = false;
    _state_machine.switch_to(_state_fall);
  else:
    _is_using_wings = true;
    stats.air_steps_remaining.value -= 1;


func _on_grid_position_changed(to_pos: Vector2i, from_pos: Vector2i) -> void:
  super._on_grid_position_changed(to_pos, from_pos);

  grid_position_ledger.log_position(to_pos);

  if ActionUtils.place_is_standable(to_pos):
    stats.air_steps_remaining.set_to_full();

  # [FIXME] Consider that this is a side-effect. Are we sure this won't interfere with
  #   FieldAction scripted animations? They set an animation, then move the actor, not
  #   realizing that movement also sets the animation?
  #
  #   The falling state is handled via Stimulus, maybe resting neatly on solid ground
  #   should also trigger a Stimulus.
  trigger_idle_animation_state();


# [TODO] Player copies don't need this. They shouldn't even collide with heart container pieces.
## Handler for when the player's inventory has a new number of fully complete heart
## containers.
func _on_heart_container_completed() -> void:
  if not subsystem:
    return;

  # [TODO] Some of this ought to be... inside the HealthComponent maybe? A wrapper
  #   to such, maybe?
  var base_containers := 2;
  var total_containers := subsystem.inventory.get_heart_containers_count() + base_containers;
  var total_max_hp := 2 * total_containers;

  var health := Component.getc(self, HealthComponent) as HealthComponent;

  var new_max_hp := total_max_hp - health.maximum;
  health.maximum = total_max_hp;
  health.value += new_max_hp;


## Handler for when the player's HP changes value.
func _on_health_changed(value: int, old_value: int) -> void:
  if value < old_value and value != 0:
    _state_machine.switch_to(_state_injured);


## Handler for when the player's HP is completely emptied.
func _on_health_empty() -> void:
  _state_machine.switch_to(_state_death);


# [TODO] This is player2d-specific, but even so, it's not something that player copies need.
#     If is_copy, this method should do nothing.
## Moves the player to the last checkpoint position, resets their health and animation
## state.
func _send_player_back_to_checkpoint() -> void:
  grid_position = grid_position_ledger.get_revive_point();
  faced_direction = Vector2i.DOWN;

  replenish_all();
  Events.board_reset_declared.emit();

  # [TODO] This should be a 'wake up' animation.
  trigger_idle_animation_state();


#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####

## The idle state is the "at rest" state. All, or most, player gameplay features can be
## accessed from here.
func _state_idle() -> void:
  trigger_idle_animation_state();


func _state_idle__input(event: InputEvent) -> void:
  if not subsystem or not subsystem.focus_node.has_focus():
    return;

  elif Input.is_action_pressed('brace'):
    if event.is_action_pressed('interact'):
      var action_schedule := PlayerInputUtils.get_brace_interact_action(self);
      if action_schedule.action != FieldActionList.null_action:
        action_declared.emit(action_schedule, false);
      subsystem.focus_node.accept_event();

  elif event.is_action_pressed('interact'):
    var action_schedule := PlayerInputUtils.get_interact_action(self);
    if action_schedule.action != FieldActionList.null_action:
      action_declared.emit(action_schedule, false);
    subsystem.focus_node.accept_event();

  elif event.is_action_pressed('open_action_menu'):
    subsystem.command_menu.open_from_start();
    subsystem.focus_node.accept_event();

  elif event.is_action_pressed('inspect'):
    var action_schedule := PlayerInputUtils.get_inspect_action(self);
    if action_schedule.action != FieldActionList.null_action:
      action_declared.emit(action_schedule, false);
    subsystem.focus_node.accept_event();


func _state_idle__move_input(input_vector: Vector2i) -> void:
  if Input.is_action_pressed('brace'):
    action_declared.emit(PlayerInputUtils.get_brace_dpad_action(self, input_vector), false);
  else:
    action_declared.emit(PlayerInputUtils.get_dpad_action(self, input_vector), false);


## The injured state handles player flinch animations and input suspension after losing HP.
func _state_injured() -> void:
  _busy_lock.lock("injured_state");

  set_animation_state('injured');
  $Audio/PlayerHurt.play();

  _interrupt_nonemergency_ui_subsystems();

  await get_tree().create_timer(0.5).timeout;
  _state_machine.switch_to(_state_idle);

  _busy_lock.unlock("injured_state");


## The coyote fall state occurs when the player is risking a fall into a pit or hole. This
## state runs a QTE minigame that succeeds or fails, and reports this result via
## [signal coyote_fall_recovered_result].
func _state_coyote_fall() -> void:
  _busy_lock.lock("coyote_fall_state");

  set_animation_state('coyote_fall');

  # [TODO] A utils method for one-shot, auto-freeing Timers would be nice.
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

  _busy_lock.unlock("coyote_fall_state");


func _state_coyote_fall__move_input(input_vector: Vector2i) -> void:
  if input_vector + faced_direction != Vector2i.ZERO:
    return;

  coyote_fall_recovered_result.emit(true);
  _state_machine.switch_to(_state_idle);


## The fall state is a transition state that handles the animation and effects of falling
## into a pit or hole.
func _state_fall() -> void:
  _busy_lock.lock("fall_state");

  await get_tree().create_timer(0.25).timeout;

  hide();

  # [TODO] A utils for creating one-shot vfx like this would be nice.
  var fall_effect := _scene_object_fall.instantiate() as OneShotEffect;
  fall_effect.position = position;
  add_sibling(fall_effect);
  await fall_effect.animation_finished;

  grid_position = grid_position_ledger.get_recover_point(self);

  show();

  # [FIXME] Put this damn thing in an @onready already.
  var health := Component.getc(self, HealthComponent) as HealthComponent;
  health.value -= 1;
  # [FIXME] This is a little confusing, isn't it? We use health.value to trigger
  #     the Injured state, which then transitions to Idle.
  #     In other words, state_fall transitions to state_idle via a side effect.
  #     ...
  #     I'm not entirely sure how this should work, though.
  #     If the Injured state could be a layer above the other states, I guess
  #     that could make sense, but that's not how any of this is implemented.
  #     I don't have cascading player states.

  _busy_lock.unlock("fall_state");


## The death state handles death animations and resets some player systems before
## triggering a revive at the last checkpoint.
func _state_death() -> void:
  if not subsystem:
    # [TODO] If this is a copy-player, it needs to queue_free. I'll think about this later.
    return;

  _busy_lock.lock("death_state");

  _interrupt_ui_subsystems();
  set_animation_state('injured');
  $Audio/PlayerHurt.play();

  # [TODO] Add a shader coordinator node to manage effect like this.
  #    "Brightness" must be applied to the world and the HUD separately, but
  #    we often want them to work together. Calling both like we're doing
  #    here is fine, but should be handled by an intermediary for effects
  #    coordination.
  subsystem.hud_shader_rect.fade_out_async(1.5, 0.5);
  await subsystem.world_shader_rect.fade_out_async(1.5, 0.5);

  _send_player_back_to_checkpoint();

  subsystem.hud_shader_rect.fade_in_async(1.0, 2.0);
  await subsystem.world_shader_rect.fade_in_async(1.0, 2.0);

  _state_machine.switch_to(_state_idle);
  _busy_lock.unlock("death_state");


## The sleep state handles sleep animations and resets some player systems before
## triggering a 'wake up' at the last checkpoint. [br]
##
## This state transition is similar to [method _state_death], but uses different
## animations.
func _state_sleep() -> void:
  if not subsystem:
    # [TODO] If this is a copy-player, it can't be sent back anywhere. Right now, it does nothing,
    #     but there could be a neat, unique interraction here. An actual sleep state, like an enemy's.
    _state_machine.switch_to(_state_idle);
    return;

  _busy_lock.lock("sleep_state");

  _interrupt_ui_subsystems();
  # [TODO] Play a sleeping animation.
  # set_animation_state('falling_asleep');

  subsystem.hud_shader_rect.fade_out_async(1.5, 0.5);
  await subsystem.world_shader_rect.fade_out_async(1.5, 0.5);

  _send_player_back_to_checkpoint();

  subsystem.hud_shader_rect.fade_in_async(1.0, 2.0);
  await subsystem.world_shader_rect.fade_in_async(1.0, 2.0);

  _state_machine.switch_to(_state_idle);
  _busy_lock.unlock("sleep_state");


class PlayerState extends CallableState:
  func _get_role_keywords() -> Array[StringName]:
    return super._get_role_keywords() + ([
      &'move_input'
    ] as Array[StringName]);

  func move_input(vector: Vector2i) -> void:
    _call_role_func(&'move_input', [vector]);
