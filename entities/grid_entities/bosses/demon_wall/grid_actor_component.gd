@warning_ignore('missing_tool')
extends GridActorComponent


const _scene_growl_audio := preload('uid://gefct2wfm524');


@export var hurt_trigger_container: Node;

@export var wall_spot_container: Node;

@export var spikes_container: Node;

@export var turn_timer: Timer;


var activated := false:
  set(value):
    activated = value;

    if activated:
      _on_activated();
    else:
      _on_deactivated();


func _ready() -> void:
  for node in spikes_container.get_children():
    node.hide();

  turn_timer.timeout.connect(_on_turn_timer_timeout);


func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    _on_deactivated();


func act_async() -> void:
  if not activated:
    return;

  _break_boulders();

  var player := ActionUtils.get_player_entity();

  if _is_player_in_hurt_spot():
    _attack_async(player);
    return;

  _advance_tiles_forward();


func _on_activated() -> void:
  if turn_timer.is_stopped():
    turn_timer.start();

  for child in wall_spot_container.get_children():
    var wall_spot := child as GridEntity;
    wall_spot.activate();

  for node in spikes_container.get_children():
    node.show();

  AudioBus.play_audio_scene(_scene_growl_audio, 0.85);

  # Plays boss music.
  Events.enemy_appeared.emit();


func _on_deactivated() -> void:
  # Stops boss music.
  Events.enemy_disappeared.emit();


func _on_turn_timer_timeout() -> void:
  act_async();

  # Speed up the wall over time.
  var next_wait_time := turn_timer.wait_time - 0.5;
  next_wait_time = max(1.0, next_wait_time);
  turn_timer.wait_time = next_wait_time;


## Performs an attack against [param entity].
func _attack_async(entity: GridEntity) -> void:
  # [IMPLEMENT] Animations of any kind.

  var health := Component.getc(entity, HealthComponent) as HealthComponent;

  if health:
    health.value -= 1;


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


func _break_boulders() -> void:
  for child in hurt_trigger_container.get_children():
    var hurt_spot := child as GridEntity;

    var entities := Grid.get_entities(hurt_spot.grid_position);

    for entity in entities:
      if (
          entity != hurt_spot
          and entity is not Player2D
      ):
        entity.queue_free();


##
func _advance_tiles_forward() -> void:
  for child in hurt_trigger_container.get_children():
    var hurt_spot := child as GridEntity;
    hurt_spot.grid_position.x += 1;

  for child in wall_spot_container.get_children():
    var wall_spot := child as GridEntity;
    wall_spot.grid_position.x += 1;

  for node in spikes_container.get_children():
    node.position.x += 16;
