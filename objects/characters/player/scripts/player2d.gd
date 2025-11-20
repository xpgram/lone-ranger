class_name Player2D
extends GridEntity


var current_animation_state: StringName = 'idle';

@onready var animation_player: AnimationPlayer = %AnimationPlayer;

@onready var animation_state_switch: AnimationStateSwitch = %AnimationStateSwitch;


func _ready() -> void:
  animation_state_switch.play(current_animation_state, faced_direction);
  animation_player.animation_finished.connect(_on_animation_finished);


func get_wait_action() -> FieldActionSchedule:
  return FieldActionSchedule.new(
    Wait_FieldAction.new(),
    FieldActionPlaybill.new(
      self,
      grid_position,
      faced_direction,
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
    faced_direction,
  );

  var actions := [
    Interact_FieldAction.new(),
  ];

  for action in actions:
    if action.can_perform(playbill):
      chosen_action = action;
      break;

  return FieldActionSchedule.new(chosen_action, playbill);


## Sets the animation state to `param state_key`.
func set_animation_state(state_key: StringName) -> void:
  current_animation_state = state_key;
  animation_state_switch.play(state_key, faced_direction);


## Resets the animation state to the idle animation set.
func _on_animation_finished(_from_animation: StringName = '') -> void:
  var non_resetting_states: Array[StringName] = [
    &'item_get!',
  ];

  if current_animation_state in non_resetting_states:
    return;
  
  set_animation_state('idle');
