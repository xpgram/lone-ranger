class_name Player2D
extends GridEntity


@onready var animation_player: AnimationPlayer = %AnimationPlayer;


func _ready() -> void:
  animation_player.play('idle_down');


func _facing_changed() -> void:
  match facing_direction:
    Vector2i.UP:
      animation_player.reset();
      animation_player.play('idle_up');

    Vector2i.DOWN:
      animation_player.reset();
      animation_player.play('idle_down');

    Vector2i.LEFT:
      animation_player.reset();
      animation_player.play('idle_left');

    Vector2i.RIGHT:
      animation_player.reset();
      animation_player.play('idle_right');


func get_wait_action() -> FieldActionSchedule:
  return FieldActionSchedule.new(
    Wait_FieldAction.new(),
    FieldActionPlaybill.new(
      self,
      grid_position,
      facing_direction,
    )
  );


func get_action_from_move_input(direction: Vector2i) -> FieldActionSchedule:
  var chosen_action: FieldAction = Wait_FieldAction.new();

  var playbill := FieldActionPlaybill.new(
    self,
    grid_position + direction,
    direction,
  );

  var actions := [
    Move_FieldAction.new(),
    Push_FieldAction.new(),
    Spin_FieldAction.new(),
  ] as Array[FieldAction];

  for action in actions:
    if action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);


func get_interact_action() -> FieldActionSchedule:
  var chosen_action: FieldAction = Wait_FieldAction.new();

  var playbill := FieldActionPlaybill.new(
    self,
    faced_position,
    facing_direction,
  );

  var actions := [
    Interact_FieldAction.new(),
  ];

  for action in actions:
    if action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);
