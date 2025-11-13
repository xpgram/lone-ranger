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
      _player_move(Vector2( 0, -1))
    );
  
  elif event.is_action('move_down'):
    _advance_time(func ():
      _player_move(Vector2( 0,  1))
    );

  elif event.is_action('move_left'):
    _advance_time(func ():
      _player_move(Vector2(-1,  0))
    );

  elif event.is_action('move_right'):
    _advance_time(func ():
      _player_move(Vector2( 1,  0))
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
  #   - ... Anything else?

  inaction_timer.start(15)


func _player_wait() -> void:
  pass


func _player_move(vector: Vector2) -> void:
  player.move(vector);
