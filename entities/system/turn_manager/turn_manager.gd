## Responsible for the game's turn system.
class_name TurnManager
extends Node


@export_group('Inaction Timer')

## The timer used to count down missed player turns.
@export var _inaction_timer: HalfTimeCombatTimer;

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

## The GridEntity operated by the player.
@onready var player: Player2D = _get_player_entity();


func _ready() -> void:
  _inaction_timer.start_and_reset();

  _inaction_timer.timeout.connect(func ():
    _advance_time_async(player.get_wait_action());
  );

  # TODO Clean this up: I just wanted to try some demo stuff.
  player.action_declared.connect(func (action: FieldActionSchedule, _buffer: bool):
    _advance_time_async(action);
  );


## Advances in-game events by triggering turn actions for each set of actors on the field.
## [param player_schedule] describes the player's input to this process.
func _advance_time_async(player_schedule: FieldActionSchedule) -> void:
  if _turn_in_progress_padlock.thread_locked():
    return;

  # This prevents the inaction timer from causing any undue effects while the player is in
  # an unstable state.
  await player.wait_until_affairs_settled_async();

  var turn_trigger_time := _inaction_timer.real_time_elapsed;
  var current_round_data := RoundData.new();

  await _conduct_player_turn_async(player_schedule);
  current_round_data.player_acted = player_schedule.action is not Wait_FieldAction;

  var inaction_forgiveness_triggered := (
    _player_is_inaction_forgiveness_eligible(turn_trigger_time, _previous_round_data)
    and current_round_data.player_acted
  );

  if _inaction_timer.finished and not inaction_forgiveness_triggered:
    await _conduct_non_player_turns_async();
    current_round_data.non_players_acted = true;

  _inaction_timer.loop_timers();
  _previous_round_data = current_round_data;

  _turn_in_progress_padlock.unlock();


## Orchestrates turn actions for the player entity, the specifics of which are given by
## [param player_schedule].
func _conduct_player_turn_async(player_schedule: FieldActionSchedule) -> void:
  var player_action := player_schedule.action;
  var playbill := player_schedule.playbill;

  @warning_ignore('redundant_await')
  await player_action.perform_async(player_schedule.playbill);

  # FIXME Inventory should not expend an unexpendable action. This request possibly shouldn't even go here.
  if player_action.limit_type in [Enums.LimitedUseType.Quantity, Enums.LimitedUseType.MagicDraw]:
    player.inventory.expend(player_action.action_uid);
  
  player.update_attributes();

  _inaction_timer.add_time(player_action.action_time_cost);
  await _perform_small_pause_async();


## Returns true if the player is eligible for a free turn as a result of the inaction
## forgiveness mechanic.
func _player_is_inaction_forgiveness_eligible(time_elapsed: float, previous_round: RoundData) -> bool:
  var currently_within_inaction_forgiveness_window := (time_elapsed <= _inaction_forgiveness_window);

  return (
    _inaction_forgiveness_enabled
    and currently_within_inaction_forgiveness_window
    and previous_round.non_players_acted
    and not previous_round.player_acted
  );


## Orchestrates turn actions for non-player entities, batched by entity kind.
func _conduct_non_player_turns_async() -> void:
  await _perform_group_entity_actions_async(Group.NPC);
  await _perform_group_entity_actions_async(Group.Enemy);
  await _perform_group_entity_actions_async(Group.Interactible);


## For all [GridEntity]'s in group [param entity_group], request and await their turn
## actions and after-effects on the game board.
func _perform_group_entity_actions_async(entity_group: StringName) -> void:
  var include_non_golems := _inaction_timer.real_time_finished;
  var include_golems := _inaction_timer.golem_time_finished;

  var actor_components: Array[GridActorComponent];
  actor_components.assign(
    get_tree()
      .get_nodes_in_group(entity_group)
      # TODO I may want to just extract this filter to an indent-zero function.
      .filter(func (entity: GridEntity):
        return (
          Component.has_component(entity, GridActorComponent)
          and (
            (include_non_golems and not entity.observes_golem_time)
            or (include_golems and entity.observes_golem_time)
          )
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


## A class to track metadata about a round of the turn system.
class RoundData extends RefCounted:
  var player_acted := false;
  var non_players_acted := false;
