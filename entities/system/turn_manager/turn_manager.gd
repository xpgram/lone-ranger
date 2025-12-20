extends Node

@export var player_module: PlayerModule;


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
    await _perform_npc_actions_async();
    await _perform_enemy_actions_async();
    await _perform_object_actions_async();

  # Reset for next turn
  var next_time_remaining := new_time_remaining if new_time_remaining > 0 else PartialTime.FULL;
  inaction_timer.start(next_time_remaining);

  if golem_time >= PartialTime.FULL:
    golem_time = PartialTime.NONE;

  turn_in_progress = false;


## Trigger NPC turn actions.
func _perform_npc_actions_async() -> void:
  var npc_entities: Array[GridEntity];
  npc_entities.assign(get_tree().get_nodes_in_group(Group.NPC));

  var any_npc_acted := false;
  
  for npc in npc_entities:
    if npc.has_method('can_act') and npc.can_act():
      # TODO Use multipass method to make sure all actors do something?
      await npc.act_async();
      npc.update_attributes();
      any_npc_acted = true;

  if any_npc_acted:
    await _perform_wait_async();


## Trigger enemy turn actions.
func _perform_enemy_actions_async() -> void:
  var include_golems := golem_time >= PartialTime.FULL;

  var enemy_entities: Array[Enemy2D];
  enemy_entities.assign(
    get_tree()
      .get_nodes_in_group(Group.Enemy)
      .filter(func (enemy: Enemy2D): return include_golems or not enemy.observes_golem_time)
  );

  for enemy in enemy_entities:
    enemy.prepare_to_act();
  
  # This multipass approach allows all enemies to act independently of their list order,
  # avoiding scenarios where one enemy obsructs the action of another.
  for i in range(3):
    var enemy_promises: Array = enemy_entities \
      .filter(func (enemy: Enemy2D): return not enemy.has_acted()) \
      .map(func (enemy: Enemy2D): return enemy.act_async);

    await Promise.all(enemy_promises).finished;

  for enemy in enemy_entities:
    enemy.update_attributes();

  # FIXME This obviously shouldn't go here.
  if player.current_animation_state == 'injured':
    await get_tree().create_timer(0.5).timeout;


## Trigger passive, interactive object "actions".
func _perform_object_actions_async() -> void:
  var interactive_entities: Array[Interactive2D];
  interactive_entities.assign(get_tree().get_nodes_in_group(Group.Interactible));

  var any_interactive_acted := false;
  
  for interactive in interactive_entities:
    if interactive.has_method('can_act') and interactive.can_act():
      # TODO Use multipass method to make sure all actors do something?
      await interactive.act_async();
      interactive.update_attributes();
      any_interactive_acted = true;

  if any_interactive_acted:
    await _perform_wait_async();


## Trigger a short time break.
func _perform_wait_async() -> void:
  await get_tree().create_timer(0.075).timeout;


## Returns true if the given entity has an 'act' method to call.
func _can_act(entity: GridEntity) -> bool:
  return entity.has_method('act');
