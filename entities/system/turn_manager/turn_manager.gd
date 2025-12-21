class_name TurnManager
extends Node


## Used to lock the turn-execution loop, preventing parallel triggers.
var turn_in_progress := false;

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
    _advance_time(player.get_wait_action());
  );

  # TODO Clean this up: I just wanted to try some demo stuff.
  player.action_declared.connect(func (action: FieldActionSchedule, _buffer: bool):
    _advance_time(action);
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

  # TODO Is this really how I want to do this? Was this meant to go in the perform script?
  #  Oh, it probably was. This will 'expend' your normal abilities, too. :p
  if player_schedule.action.limit_type in [Enums.LimitedUseType.Quantity, Enums.LimitedUseType.MagicDraw]:
    player.inventory.expend(player_schedule.action.action_uid);

  # TODO Get from the player group instead of @export
  player.update_attributes();

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
    await _perform_group_entity_actions_async(Group.NPC);
    await _perform_group_entity_actions_async(Group.Enemy);
    await _perform_group_entity_actions_async(Group.Interactible);

  # Reset for next turn
  var next_time_remaining := new_time_remaining if new_time_remaining > 0 else PartialTime.FULL;
  inaction_timer.start(next_time_remaining);

  if golem_time >= PartialTime.FULL:
    golem_time = PartialTime.NONE;

  turn_in_progress = false;


## For all [GridEntity]'s in group [param entity_group], request and await their turn
## actions and after-effects on the game board.
func _perform_group_entity_actions_async(entity_group: StringName) -> void:
  var include_golems := golem_time >= PartialTime.FULL;

  var actor_components: Array[BoardActorComponent];
  actor_components.assign(
    get_tree()
      .get_nodes_in_group(entity_group)
      .filter(func (entity: GridEntity):
        return (
          Component.has_component(entity, BoardActorComponent)
          and (include_golems or not entity.observes_golem_time)
          # TODO observes_golem_time only makes sense to BoardActor's, so should probably be located there.
        ))
      .map(func (entity: GridEntity): return Component.get_component(entity, BoardActorComponent))
  );

  if actor_components.size() == 0:
    return;

  for actor in actor_components:
    actor.prepare_to_act();

  # This multipass approach allows all entities in a turn-group to act independently of
  # their list order, avoiding scenarios where one entity obstructs the action of another.
  for i in range(3):
    var actor_promises: Array = actor_components \
      .filter(func (actor: BoardActorComponent): return not actor.has_acted()) \
      .map(func (actor: BoardActorComponent): return actor.act_async);

    await Promise.all(actor_promises).finished;

  for actor in actor_components:
    actor.get_entity().update_attributes();

  # FIXME This obviously shouldn't go here.
  if player.current_animation_state == 'injured':
    await get_tree().create_timer(0.5).timeout;


## Trigger a short time break.
func _perform_wait_async() -> void:
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
