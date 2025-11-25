extends Node

@export var player_module: PlayerModule;

# TODO It would be nice if these types knew they could only contain objects of such types: Enemy, NPC, Interactive, etc.
@export var npc_container: Node2D;
@export var enemy_container: Node2D;
@export var interactives_container: Node2D;


## Used to lock the turn-execution loop, preventing parallel triggers.
var turn_in_progress := false;

## Increments independently of the inaction timer, and triggers different enemies' turn
## behavior.
var golem_time := 0.0;


## The GridEntity operated by the player.
@onready var player := player_module.get_entity();

## The timer used to count down missed player turns.
@onready var inaction_timer: Timer = %InactionTimer;


func _ready() -> void:
  inaction_timer.start(PartialTime.FULL);

  inaction_timer.timeout.connect(func ():
    _advance_time(player.get_wait_action());
  );

  # TODO Clean this up: I just wanted to try some demo stuff.
  player.action_declared.connect(func (action: FieldActionSchedule):
    _advance_time(action);
  );


func _unhandled_input(event: InputEvent) -> void:
  # TODO Move this into Player2D, let Player2D communicate control impulses with action_declared
  #   We can also have a signal action_impulse or something, if we need distinction between
  #   a menu-selected thing (which may need to be buffered/rejected) and a button-press
  #   thing (which should feel immediate, and otherwise discarded).
  if not event.is_pressed():
    return;

  if event.is_action('move_up'):
    _advance_time(
      player.get_action_from_move_input(Vector2.UP)
    );

  elif event.is_action('move_down'):
    _advance_time(
      player.get_action_from_move_input(Vector2.DOWN)
    );

  elif event.is_action('move_left'):
    _advance_time(
      player.get_action_from_move_input(Vector2.LEFT)
    );

  elif event.is_action('move_right'):
    _advance_time(
      player.get_action_from_move_input(Vector2.RIGHT)
    );

  elif event.is_action('interact'):
    _advance_time(
      player.get_interact_action()
    );


## Advances in-game events by triggering turn actions for each set of actors on the field.
## `player_schedule` describes the player's input to this process.
func _advance_time(player_schedule: FieldActionSchedule) -> void:
  # Prevent interruptions during long or async operations.
  if turn_in_progress:
    return;
  turn_in_progress = true;

  # Player action
  @warning_ignore('redundant_await')
  await player_schedule.action.perform_async(player_schedule.playbill);
  await _perform_wait_async();
  # TODO 1 wait_async should be called every turn.
  #   More than 1 may be called depending on what else is happening.
  #   Figure out how to orchestrate that.
  #   But do it *after* adding NPCs and objects that can act independently.

  var action_time_cost := player_schedule.action.get_variable_action_time_cost()
  var new_time_remaining := inaction_timer.time_left - action_time_cost;

  golem_time += action_time_cost;

  # Other turn actions
  if new_time_remaining <= 0:
    await _perform_npc_actions_async();
    await _perform_enemy_actions_async();
    await _perform_object_actions_async();
    _update_entity_attributes();

  # Reset for next turn
  var next_time_remaining := new_time_remaining if new_time_remaining > 0 else PartialTime.FULL;
  inaction_timer.start(next_time_remaining);

  if golem_time >= PartialTime.FULL:
    golem_time = PartialTime.NONE;

  turn_in_progress = false;


## Trigger NPC turn actions.
func _perform_npc_actions_async() -> void:
  if not npc_container or npc_container.get_child_count() == 0:
    return;

  var children := npc_container.get_children();
  if not children.any(_can_act):
    return;

  await _perform_wait_async();

  # TODO Multipass?
  for interactive in interactives_container.get_children():
    await interactive.act();


## Trigger enemy turn actions.
func _perform_enemy_actions_async() -> void:
  if not enemy_container or enemy_container.get_child_count() == 0:
    return;

  var include_golems := golem_time >= PartialTime.FULL;

  # TODO This area needs to be cleaned up for readability.
  #  Keep all Enemy2Ds, but exclude golems, unless include_golems is true.
  var enemies: Array[Enemy2D];
  enemies.assign(
    # TODO Is it better to double loop like this or spawn push_clouds in a different layer?
    enemy_container.get_children().filter(func (child):
      if child is not Enemy2D:
        return false;

      var enemy := child as Enemy2D;
      return (
        not enemy.observes_golem_time
        or include_golems
      ))
  );

  for enemy in enemies:
    enemy.prepare_to_act();

  # This multipass approach allows all enemies to act independently of their list order.
  for i in range(3):
    var enemy_promises: Array = enemies \
      .filter(func (enemy: Enemy2D): return not enemy.has_acted()) \
      .map(func (enemy: Enemy2D): return enemy.act_async);

    await Promise.all(enemy_promises).finished;

  # FIXME This obviously shouldn't go here.
  if player.current_animation_state == 'injured':
    await get_tree().create_timer(0.5).timeout;


## Trigger passive, interactive object "actions".
func _perform_object_actions_async() -> void:
  if not interactives_container or interactives_container.get_child_count() == 0:
    return;

  var children := interactives_container.get_children();
  if not children.any(_can_act):
    return;

  await _perform_wait_async();

  # TODO Multipass?
  for interactive in interactives_container.get_children():
    await interactive.act();


## Update all entity attribute counters and status effect states.
func _update_entity_attributes() -> void:
  # FIXME We have an off-by-one error.
  #  Entities should update their attributes after their own actions, not in one big step.
  #  This one big step strategy doesn't work because either the player or the enemies end
  #  up suffering this issue:
  #    -> player applies stun
  #    -> stun updates, clears
  #    -> enemy acts without being stunned
  #  So all entities should self-manage in some way. Or at least, their completed actions,
  #  including Wait, must be followed by their own attribute update step.
  player.update_attributes();

  for npc: GridEntity in npc_container.get_children():
    npc.update_attributes();

  for enemy in enemy_container.get_children():
    # FIXME VisualEffects are probably just not necessary on this layer.
    #  I should send them elsewhere and think about z-index later.
    if enemy is Enemy2D:
      enemy.update_attributes();

  for object: GridEntity in interactives_container.get_children():
    object.update_attributes();


## Trigger a short time break.
func _perform_wait_async() -> void:
  await get_tree().create_timer(0.075).timeout;


## Returns true if the given entity has an 'act' method to call.
func _can_act(entity: GridEntity) -> bool:
  return entity.has_method('act');
