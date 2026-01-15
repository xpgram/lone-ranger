@warning_ignore('missing_tool')
extends GridActorComponent


@export var vision_range := 10;

var _is_charging := false:
  set(value):
    _is_charging = value;
    _facing_changed();

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D;


func _ready() -> void:
  animated_sprite.play();


func act_async() -> void:
  if _is_charging:
    await _charge_forward_in_faced_direction_async();
  else:
    await _idle_until_player_seen_async();


func _charge_forward_in_faced_direction_async() -> void:
  var self_entity := get_entity();
  var player := ActionUtils.get_player_entity();

  var is_player_adjacent := self_entity.faced_position == player.grid_position;

  var playbill := FieldActionPlaybill.new(
    self_entity,
    self_entity.faced_position,
    self_entity.faced_direction,
  );

  if is_player_adjacent:
    @warning_ignore('redundant_await')
    await _attack_async();
    _is_charging = false;

  elif FieldActionList.move.can_perform(playbill):
    @warning_ignore('redundant_await')
    await FieldActionList.move.perform_async(playbill);

  else:
    _is_charging = false;

  exhaust();


func _idle_until_player_seen_async() -> void:
  var self_entity := get_entity();
  var player := ActionUtils.get_player_entity();

  if not ActionUtils.target_pos_within_line_range(self_entity, player.grid_position, vision_range):
    exhaust();
    return;

  var direction := ActionUtils.get_direction_to_target(self_entity.grid_position, player.grid_position);
  var inter_distance := self_entity.distance_to(player) - 1;
  var coords_line := ActionUtils.get_coordinate_line(self_entity.grid_position, direction, inter_distance);
  var is_adjacent := (coords_line.size() == 0);
  var can_see_player: bool = coords_line.all(func (pos: Vector2i): return ActionUtils.place_is_transparent(pos));

  if not can_see_player:
    return;

  var playbill := FieldActionPlaybill.new(
    self_entity,
    self_entity.grid_position + direction,
    direction,
  );

  if not is_adjacent and FieldActionList.move.can_perform(playbill):
    @warning_ignore('redundant_await')
    await FieldActionList.move.perform_async(playbill);
    _is_charging = true;

  elif is_adjacent:
    @warning_ignore('redundant_await')
    await _attack_async();

  exhaust();


func get_entity() -> Enemy2D:
  return super.get_entity();


func _attack_async() -> void:
  var player := ActionUtils.get_player_entity();
  var health_component := Component.get_component(player, HealthComponent) as HealthComponent;
  health_component.value -= 1;


func _facing_changed() -> void:
  if not _is_charging:
    animated_sprite.play('idle');
  
  else:
    animated_sprite.flip_h = false;

    match get_entity().faced_direction:
      Vector2i.UP:
        animated_sprite.play('charge_up');
      Vector2i.DOWN:
        animated_sprite.play('charge_down');
      Vector2i.LEFT:
        animated_sprite.play('charge_left');
        animated_sprite.flip_h = true;
      Vector2i.RIGHT:
        animated_sprite.play('charge_right');
