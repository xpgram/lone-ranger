@warning_ignore('missing_tool')
extends GridActorComponent


enum Facing {
  LEFT,
  RIGHT,
};


@export var _initial_facing := Facing.RIGHT;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  animated_sprite.play();

  var self_entity := get_entity();
  match _initial_facing:
    Facing.LEFT:
      self_entity.faced_direction = Vector2i.LEFT;
    Facing.RIGHT:
      self_entity.faced_direction = Vector2i.RIGHT;


# TODO Reexamine this function implementation later: Is it fine? Do I hate it?
func act_async() -> void:
  var self_entity := get_entity();
  var player := ActionUtils.get_player_entity();

  var is_adjacent := self_entity.faced_position == player.grid_position;

  var playbill := FieldActionPlaybill.new(
    self_entity,
    self_entity.faced_position,
    self_entity.faced_direction,
  );

  if is_adjacent:
    @warning_ignore('redundant_await')
    await _attack_async();

  elif _can_move(playbill):
    await _perform_move_async(playbill);

  else:
    match self_entity.faced_direction:
      Vector2i.LEFT:
        self_entity.faced_direction = Vector2i.RIGHT;
      Vector2i.RIGHT:
        self_entity.faced_direction = Vector2i.LEFT;
    _facing_changed();

  exhaust();


func get_entity() -> Enemy2D:
  return super.get_entity();


func _can_move(playbill: FieldActionPlaybill) -> bool:
  var is_idleable := ActionUtils.place_is_idleable(playbill.target_position, playbill.performer);
  var can_perform := FieldActionList.move.can_perform(playbill);
  return is_idleable and can_perform;


func _perform_move_async(playbill: FieldActionPlaybill) -> void:
  @warning_ignore('redundant_await')
  await FieldActionList.move.perform_async(playbill);


## Performs an attack against the global [Player2D] entity.
func _attack_async() -> void:
  # IMPLEMENT Animations of any kind.
  # FIXME Shouldn't this accept an entity parameter and not grab the global player?
  var player := ActionUtils.get_player_entity();
  var health_component := Component.get_component(player, HealthComponent) as HealthComponent;
  health_component.value -= 1;


func _facing_changed() -> void:
  match get_entity().faced_direction:
    Vector2i.LEFT:
      animated_sprite.flip_h = true;
    Vector2i.RIGHT:
      animated_sprite.flip_h = false;
