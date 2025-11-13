extends Node

@export var player: Player2D;

# TODO It would be nice if these types knew they could only contain objects of such types: Enemy, NPC, Interactive, etc.
@export var npc_container: Node2D;
@export var enemy_container: Node2D;
@export var interactives_container: Node2D;


@onready var inaction_timer: Timer = %InactionTimer;


func _ready() -> void:
  inaction_timer.start(15);

  inaction_timer.timeout.connect(func ():
    _advance_time(_player_wait);
  );


func _unhandled_input(event: InputEvent) -> void:
  if not event.is_pressed():
    return;

  if event.is_action('move_up'):
    _advance_time(func ():
      _player_move(Vector2.UP)
    );

  elif event.is_action('move_down'):
    _advance_time(func ():
      _player_move(Vector2.DOWN)
    );

  elif event.is_action('move_left'):
    _advance_time(func ():
      _player_move(Vector2.LEFT)
    );

  elif event.is_action('move_right'):
    _advance_time(func ():
      _player_move(Vector2.RIGHT)
    );


func _advance_time(player_action: Callable) -> void:
  # Prevent interruptions during long or async operations.
  inaction_timer.stop();

  player_action.call();
  # - Turn animations happen here, naturally.

  # - If turn spent:
  #   - Player may travel down stairs (high priority interactives)
  #   - Blocks are pushed, enemies are crushed

  #   - Enemies move / act
  #     - Enemy animations, naturally
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
        enemy.act();

  #   - ... Anything else?

  inaction_timer.start(15)


func _player_wait() -> void:
  pass


func _player_move(vector: Vector2) -> void:
  player.move(vector);
