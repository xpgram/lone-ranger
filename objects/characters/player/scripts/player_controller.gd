extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;

const GRID_SIZE := 16;


func _ready() -> void:
  animated_sprite.play();


func _physics_process(delta: float) -> void:

  # This is fine for now, but I think this needs to be event driven?
  # - We need to act *when* a direction input is pressed.
  # - It must update the field in particular order, starting with the Player.
  # - Point three.
  var input := Input.get_vector(
    'move_left',
    'move_right',
    'move_up',
    'move_down',
    0.25,
  );

  # Limit movement to one axis at a time.
  if input.x != 0:
    input.y = 0;

  var vector_inputs_pressed := [
    Input.is_action_just_pressed('move_up'),
    Input.is_action_just_pressed('move_down'),
    Input.is_action_just_pressed('move_left'),
    Input.is_action_just_pressed('move_right'),
  ];

  if vector_inputs_pressed.any(func (pressed): return pressed):
    _move_self(input);


func _unhandled_input(event: InputEvent) -> void:
  if not event is InputEventAction:
    return;

  var action_event := event as InputEventAction;

  match action_event.action:
    'move_up':
      _move_self(Vector2(0, -1));
    'move_down':
      _move_self(Vector2(0, 1));
    'move_left':
      _move_self(Vector2(-1, 0));
    'move_right':
      _move_self(Vector2(1, 0));


func _move_self(vector: Vector2) -> void:
  # TODO Check collisions first.
  position += vector * GRID_SIZE;
