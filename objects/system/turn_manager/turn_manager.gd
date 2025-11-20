extends Node

@export var player: Player2D;

# TODO It would be nice if these types knew they could only contain objects of such types: Enemy, NPC, Interactive, etc.
@export var npc_container: Node2D;
@export var enemy_container: Node2D;
@export var interactives_container: Node2D;

## Used to lock the turn-execution loop, preventing parallel triggers.
var turn_in_progress := false;

@onready var inaction_timer: Timer = %InactionTimer;


func _ready() -> void:
  inaction_timer.start(PartialTime.FULL);

  inaction_timer.timeout.connect(func ():
    _advance_time(player.get_wait_action());
  );


func _unhandled_input(event: InputEvent) -> void:
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

  var new_time_remaining := inaction_timer.time_left - player_schedule.action.action_time_cost();

  # Other turn actions
  if new_time_remaining <= 0:
    await _perform_npc_actions_async();
    await _perform_enemy_actions_async();
    await _perform_object_actions_async();
    _update_entity_attributes();

  # Reset for next turn
  var next_time_remaining := new_time_remaining if new_time_remaining > 0 else PartialTime.FULL;
  inaction_timer.start(next_time_remaining);

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

  var enemies: Array[Enemy2D];
  enemies.assign(
    # TODO Is it better to double loop like this or spawn push_clouds in a different layer?
    enemy_container.get_children()
      .filter(func (child): return child is Enemy2D)
  );

  for enemy in enemies:
    enemy.prepare_to_act();

  # This multipass approach allows enemies to all act independently of list order.
  for i in range(3):
    var enemies_to_act: Array[Enemy2D];
    enemies_to_act.assign(
      enemies.filter(func (enemy): return not enemy.has_acted())
    );

    for enemy in enemies_to_act:
      # TODO This should be a list of promises to await so all enemies act in unison.
      @warning_ignore('redundant_await')
      await enemy.act_async();

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
