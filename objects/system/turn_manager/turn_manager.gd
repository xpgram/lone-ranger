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

  var new_time_remaining := inaction_timer.time_left - player_schedule.action.action_time_cost();

  # Other turn actions
  if new_time_remaining <= 0:
    await _perform_npc_actions_async();
    await _perform_enemy_actions_async();
    await _perform_object_actions_async();

  # Reset for next turn
  var next_time_remaining := new_time_remaining if new_time_remaining > 0 else PartialTime.FULL;
  inaction_timer.start(next_time_remaining);

  turn_in_progress = false;


## Trigger NPC turn actions.
func _perform_npc_actions_async() -> void:
  if not npc_container or npc_container.get_child_count() == 0:
    return;
  
  await _perform_wait_async();


## Trigger enemy turn actions.
func _perform_enemy_actions_async() -> void:
  if not enemy_container or enemy_container.get_child_count() == 0:
    return;

  await _perform_wait_async();
  
  var enemies: Array[Enemy2D];
  enemies.assign(enemy_container.get_children());

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
      await enemy.act();


## Trigger passive, interactive object "actions".
func _perform_object_actions_async() -> void:
  if not interactives_container or interactives_container.get_child_count() == 0:
    return;

  # TODO This should only be if an object actually does anything.
  if false:
    await _perform_wait_async();


# TODO I don't think this method ought to be official. It slows things down too much.
#   But it remains true that if an enemy pushes something, a delay before and after they
#   act helps communicate the sequence of events.
#   Also, does Void Stranger allow the tail-end of your push to overlap the beginning of a
#   mimic's push? I dunno.
## Trigger a short time break.
func _perform_wait_async() -> void:
  await get_tree().create_timer(0.1).timeout;
