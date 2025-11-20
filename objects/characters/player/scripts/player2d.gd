class_name Player2D
extends GridEntity


@onready var animation_player: AnimationPlayer = %AnimationPlayer;
# TODO This was designed to get around AnimationTree, but I dunno. I dunno, man.
@onready var animation_set_player: AnimationSetPlayer = %AnimationSetPlayer;


func _ready() -> void:
  animation_player.play('idle_down');
  animation_player.animation_finished.connect(_on_animation_finished);


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


## Sets the animation state to idle in the current `property facing_direction`.
func reset_animation_to_idle() -> void:
  animation_player.reset();
  animation_set_player.play('idle', facing_direction);


## Resets the animation state to the idle animation set.
func _on_animation_finished(from_animation: StringName = '') -> void:
  var non_resetting_animations: Array[StringName] = [
    &'item_get!',
  ];

  if from_animation in non_resetting_animations:
    return;
  
  reset_animation_to_idle();
