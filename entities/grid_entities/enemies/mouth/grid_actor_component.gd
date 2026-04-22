@warning_ignore('missing_tool')
extends GridActorComponent


@export var vision_range := 10;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();


# TODO Reexamine this function implementation later: Is it fine? Do I hate it?
func act_async() -> void:
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
  # TODO FieldActionList.enemy_attack.can_perform(playbill):
  elif is_adjacent:
    @warning_ignore('redundant_await')
    await _attack_async();

  # TODO This is a bandaid patch for _facing_changed() not being a thing on ActorComponents.
  _facing_changed();

  exhaust();


func get_entity() -> Enemy2D:
  return super.get_entity();


## Performs an attack against the global [Player2D] entity.
func _attack_async() -> void:
  # IMPLEMENT Animations of any kind.
  # FIXME Shouldn't this accept an entity parameter and not grab the global player?
  var player := ActionUtils.get_player_entity();
  var health := Component.getc(player, HealthComponent) as HealthComponent;
  health.value -= 1;


# FIXME Oh my god. This function is not connected to anything. I can't believe I never noticed.
func _facing_changed() -> void:
  match get_entity().faced_direction:
    Vector2i.LEFT:
      animated_sprite.flip_h = true;
    Vector2i.RIGHT:
      animated_sprite.flip_h = false;
