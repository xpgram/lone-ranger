@warning_ignore('missing_tool')
extends GridActorComponent


@export var hurt_trigger_container: Node;

@export var wall_spot_container: Node;

@export var turn_timer: Timer;


var activated := false:
  set(value):
    activated = value;

    if activated:
      _on_activated();


func _ready() -> void:
  turn_timer.timeout.connect(_on_turn_timer_timeout);


func act_async() -> void:
  if not activated:
    return;
  
  if _is_player_in_hurt_spot():
    _attack_async();
    return;

  _advance_tiles_forward();


func _on_activated() -> void:
  if turn_timer.is_stopped():
    turn_timer.start();

  for child in wall_spot_container.get_children():
    var wall_spot := child as GridEntity;
    wall_spot.activate();


func _on_turn_timer_timeout() -> void:
  act_async();

  # Speed up the wall over time.
  var next_wait_time := turn_timer.wait_time - 0.5;
  next_wait_time = max(1.0, next_wait_time);
  turn_timer.wait_time = next_wait_time;


## Performs an attack against the global [Player2D] entity.
func _attack_async() -> void:
  # IMPLEMENT Animations of any kind.
  # FIXME Shouldn't this accept an entity parameter and not grab the global player?
  var player := ActionUtils.get_player_entity();
  var health_component := Component.get_component(player, HealthComponent) as HealthComponent;
  health_component.value -= 1;


##
func _is_player_in_hurt_spot() -> bool:
  var player := ActionUtils.get_player_entity();
  var result := false;

  if not player:
    return result;

  for child in hurt_trigger_container.get_children():
    var hurt_spot := child as GridEntity;
    if player.grid_position == hurt_spot.grid_position:
      result = true;

  return result;


##
func _advance_tiles_forward() -> void:
  for child in hurt_trigger_container.get_children():
    var hurt_spot := child as GridEntity;
    hurt_spot.grid_position.x += 1;

  for child in wall_spot_container.get_children():
    var wall_spot := child as GridEntity;
    wall_spot.grid_position.x += 1;
