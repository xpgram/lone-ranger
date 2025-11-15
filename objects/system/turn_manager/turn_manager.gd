extends Node

@export var player: Player2D;

# TODO It would be nice if these types knew they could only contain objects of such types: Enemy, NPC, Interactive, etc.
@export var npc_container: Node2D;
@export var enemy_container: Node2D;
@export var interactives_container: Node2D;


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


func _advance_time(player_schedule: FieldActionSchedule) -> void:
  # Prevent interruptions during long or async operations.
  # TODO The InactionTimer continues through animations, but it shouldn't fully elapse.
  #   It's worth noting, all the timer does on finish is call _advance_time().
  #   If we're already in _advance_time(), we can probably just ignore it.
  #   We might need to ignore it with a boolean, though.
  #   And if we're doing that, well, I see the inconvenience of early returns now.

  # Player actions:
  # - Action animations, naturally.
  # - Action after-effects,
  #   - such as Move->Travel down stairs
  #   - or Push->Push Boulder->Crush Enemy
  @warning_ignore('redundant_await')
  await player_schedule.action.perform_async(player_schedule.playbill);

  # Return early if the turn timer hasn't elapsed yet.
  var new_time_remaining := inaction_timer.time_left - player_schedule.action.action_time_cost();

  if new_time_remaining > 0:
    inaction_timer.start(new_time_remaining);
    return;

  # - Enemies move / act
  #   - Enemy animations, naturally
  if enemy_container:
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
        # TODO I need a list of promises. But I'm probably gonna have to write that myself.
        enemy.act();

  # - ... Anything else?

  inaction_timer.start(PartialTime.FULL)
