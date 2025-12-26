class_name TurnManager
extends Node


@export_group('Inaction Timer')

## Whether the forgiveness window for accidentally missed turns is enabled. [br]
##
## Players who act just after missing their turn, within the accident window, may be given
## a free turn to avoid the seeming unfairness of letting enemies double-act.
@export var _inaction_forgiveness_enabled := true;

## The time in seconds that accidentally missed turns may be forgiven by skipping the
## enemy's next turn.
@export var _inaction_forgiveness_window := 0.5;


## Used to lock the turn-execution loop, preventing parallel triggers.
var _turn_in_progress_padlock := Padlock.new();

## Information about the last-conducted round of player turns.
var _previous_round_data := RoundData.new();

## Increments independently of the inaction timer, and triggers different enemies' turn
## behavior.
var golem_time := 0.0;


## The GridEntity operated by the player.
@onready var player: Player2D = _get_player_entity();

## The timer used to count down missed player turns.
@onready var inaction_timer: Timer = %InactionTimer;


func _ready() -> void:
  inaction_timer.start(PartialTime.FULL);

  inaction_timer.timeout.connect(func ():
    _advance_time_async(player.get_wait_action());
  );

  # TODO Clean this up: I just wanted to try some demo stuff.
  player.action_declared.connect(func (action: FieldActionSchedule, _buffer: bool):
    _advance_time_async(action);
  );

# TODO Remove this block
# advance_time psuedo code
# - lock turn advancer
# - conduct player turn
#   - perform action
#   - decrement inventory
#   - increment player attributes
# - perform a small wait
# - (inaction forgiveness)
# - check real time values, increment golem time; if elapsed:
#   - perform all entity group turn phases
# - reset real time value if necessary, golem time as well
# - unlock turn advancer

## Advances in-game events by triggering turn actions for each set of actors on the field.
## `player_schedule` describes the player's input to this process.
func _advance_time_async(player_schedule: FieldActionSchedule) -> void:
  if _turn_in_progress_padlock.thread_locked():
    return;

  var current_round_data := RoundData.new();

  await _conduct_player_turn_async(player_schedule);
  current_round_data.player_acted = player_schedule.action is not Wait_FieldAction;

  var inaction_forgiveness_triggered := (
    _player_is_inaction_forgiveness_eligible()
    and current_round_data.player_acted
  );

  if _round_timers_elapsed() and not inaction_forgiveness_triggered:
    await _conduct_non_player_turns_async();
    current_round_data.non_players_acted = true;

  _update_round_timers();
  _previous_round_data = current_round_data;

  _turn_in_progress_padlock.unlock();


##
func _conduct_player_turn_async(player_schedule: FieldActionSchedule) -> void:
  var player_action := player_schedule.action;
  var playbill := player_schedule.playbill;

  @warning_ignore('redundant_await')
  await player_action.perform_async(player_schedule.playbill);

  # FIXME Inventory should not expend an unexpendable action. This request possibly shouldn't even go here.
  if player_action.limit_type in [Enums.LimitedUseType.Quantity, Enums.LimitedUseType.MagicDraw]:
    player.inventory.expend(player_action.action_uid);
  
  player.update_attributes();

  _add_time_to_round_timers(player_action.action_time_cost);
  await _perform_small_pause_async(); # TODO Rename function


##
func _player_is_inaction_forgiveness_eligible() -> bool:
  var currently_within_inaction_forgiveness_window := (
    PartialTime.FULL - inaction_timer.time_left <= _inaction_forgiveness_window
  );

  return (
    _inaction_forgiveness_enabled
    and currently_within_inaction_forgiveness_window
    and _previous_round_data.non_players_acted
    and not _previous_round_data.player_acted
  );


##
func _conduct_non_player_turns_async() -> void:
  await _perform_group_entity_actions_async(Group.NPC);
  await _perform_group_entity_actions_async(Group.Enemy);
  await _perform_group_entity_actions_async(Group.Interactible);


##
func _round_timers_elapsed():
  return (
    inaction_timer.time_left <= 0
    or golem_time >= PartialTime.TURN_ELAPSE_LENGTH
  );


##
func _add_time_to_round_timers(time: float) -> void:
  golem_time += time;

  var new_real_time_value := maxf(0, inaction_timer.time_left - time);
  inaction_timer.start(new_real_time_value);


##
func _update_round_timers() -> void:
  if inaction_timer.time_left <= 0:
    inaction_timer.start(PartialTime.FULL);
  
  if golem_time >= PartialTime.TURN_ELAPSE_LENGTH:
    golem_time = PartialTime.NONE;


## For all [GridEntity]'s in group [param entity_group], request and await their turn
## actions and after-effects on the game board.
func _perform_group_entity_actions_async(entity_group: StringName) -> void:
  var include_golems := golem_time >= PartialTime.FULL;

  var actor_components: Array[GridActorComponent];
  actor_components.assign(
    get_tree()
      .get_nodes_in_group(entity_group)
      # TODO I may want to just extract this filter to an indent-zero function.
      .filter(func (entity: GridEntity):
        return (
          Component.has_component(entity, GridActorComponent)
          # TODO observes_golem_time only makes sense to BoardActor's, so should probably be located there.
          and (include_golems or not entity.observes_golem_time)
        ))
      .map(func (entity: GridEntity): return Component.get_component(entity, GridActorComponent))
  );

  if actor_components.size() == 0:
    return;

  for actor in actor_components:
    actor.prepare_to_act();

  # This multipass approach allows all entities in a turn-group to act independently of
  # their list order, avoiding scenarios where one entity obstructs the action of another.
  for i in range(3):
    var actor_promises: Array = actor_components \
      .filter(func (actor: GridActorComponent): return actor.can_act()) \
      .map(func (actor: GridActorComponent): return actor.act_async);

    await Promise.all(actor_promises).finished;

  for actor in actor_components:
    actor.get_entity().update_attributes();

  # FIXME This obviously shouldn't go here.
  if player.current_animation_state == 'injured':
    await get_tree().create_timer(0.5).timeout;


## Trigger a short time break.
func _perform_small_pause_async() -> void:
  await get_tree().create_timer(0.075).timeout;


## Retrieves the player entity from the Player group.
## Throws an error if no players were found.
func _get_player_entity() -> Player2D:
  var players: Array[Player2D];
  players.assign(get_tree().get_nodes_in_group(Group.Player));

  if players.size() == 0:
    push_error('TurnManager: Player2D entity not found.');
    return null;

  return players[0];


##
class RoundData extends RefCounted:
  var player_acted := false;
  var non_players_acted := false;
