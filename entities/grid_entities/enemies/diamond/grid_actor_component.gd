@warning_ignore('missing_tool')
extends GridActorComponent


@export var vision_range := 6;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


# [TODO] Reexamine this function implementation later: Is it fine? Do I hate it?
func act_async() -> void:
  var self_entity := get_entity();
  var player := ActionUtils.get_player_entity();

  if not ActionUtils.target_pos_within_range(self_entity, player.grid_position, vision_range):
    _power_diamond_down();
    exhaust();
    return;

  var path := ActionUtils.get_path_to_target(
    self_entity,
    player.grid_position,
    vision_range,
    func (place: Vector2i):
      return (
        ActionUtils.place_is_idleable(place, self_entity)
        or place == player.grid_position
      );
  );

  if path.size() == 0 and self_entity.grid_position != player.grid_position:
    _power_diamond_down();
    exhaust();
    return;

  _power_diamond_up();

  var move_direction := path[0] - self_entity.grid_position;
  var inter_distance := self_entity.distance_to(player) - 1;
  var is_adjacent := (inter_distance == 0);
  var is_last_pos_adjacent := (VectorUtils.grid_distance(self_entity.grid_position, player.get_last_position()) == 1);

  # When close, prefer to move toward wherever the player just was.
  if (inter_distance == 1 and is_last_pos_adjacent):
    move_direction = player.get_last_position() - self_entity.grid_position;

  var playbill := FieldActionPlaybill.new(
    self_entity,
    self_entity.grid_position + move_direction,
    move_direction,
  );

  if is_adjacent:
    @warning_ignore('redundant_await')
    await _attack_async(player);
  elif _can_move(playbill):
    @warning_ignore('redundant_await')
    await FieldActionList.move.perform_async(playbill);

  exhaust();


func get_entity() -> Enemy2D:
  return super.get_entity();


func _can_move(playbill: FieldActionPlaybill) -> bool:
  var is_idleable := ActionUtils.place_is_idleable(playbill.target_position, playbill.performer);
  var can_perform := FieldActionList.move.can_perform(playbill);
  return is_idleable and can_perform;


## Performs an attack against [param entity].
func _attack_async(entity: GridEntity) -> void:
  # [IMPLEMENT] Animations of any kind.

  var health := Component.getc(entity, HealthComponent) as HealthComponent;

  if health:
    health.value -= 1;


func _facing_changed() -> void:
  match get_entity().faced_direction:
    Vector2.UP:
      animated_sprite.scale.x = -1;
    Vector2.DOWN:
      animated_sprite.scale.x = 1;
    Vector2.LEFT:
      animated_sprite.scale.x = -1;
    Vector2.RIGHT:
      animated_sprite.scale.x = 1;


func _power_diamond_up() -> void:
  if animated_sprite.animation != 'active':
    animated_sprite.play('active');


func _power_diamond_down() -> void:
  if animated_sprite.animation != 'inactive':
    animated_sprite.play('inactive');
