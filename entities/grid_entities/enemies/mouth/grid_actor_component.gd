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
  var line := ActionUtils.get_coordinate_line(self_entity.grid_position, direction, inter_distance);
  var adjacent := (line.size() == 0);
  var can_see_player: bool = line.all(func (pos: Vector2i): return ActionUtils.is_cell_transparent(pos));

  if not can_see_player:
    return;

  var playbill := FieldActionPlaybill.new(
    self_entity,
    self_entity.grid_position + direction,
    direction
  );

  if not adjacent and FieldActionList.move.can_perform(playbill):
    @warning_ignore('redundant_await')
    await FieldActionList.move.perform_async(playbill);
  # TODO FieldActionList.enemy_attack.can_perform(playbill):
  else:
    _attack();
  
  exhaust();


func get_entity() -> Enemy2D:
  return super.get_entity();


func _attack() -> void:
  # IMPLEMENT This isn't a real attack. Not to mention, Player2D can handle its own hurt animation.
  var player := ActionUtils.get_player_entity();
  player.set_animation_state('injured');


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
