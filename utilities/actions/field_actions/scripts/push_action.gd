class_name Push_FieldAction
extends FieldAction


const scene_push_cloud := preload('uid://hua0n75be2w3');

const scene_bump_audio := preload('uid://cvkl4d3g51ocn');
const scene_scrape_audio := preload('uid://ckshk52e1bn74');
const scene_cast_audio := preload('uid://dje6ncwpv7kxg');

const stun_attribute_resource := preload('uid://jnysha6rnoxl');


## How many objects in sequence may be pushed at once.
@export var _push_length := 1;

## A measure of how heavy the objects pushed may be.
@export var _push_strength := 1;

## Whether this action is capable of performing a [Stimulus.secret_knock] effect.
@export var _can_secret_knock := true;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var answer := false;

  match action_type:
    Enums.FieldActionType.Ability:
      answer = _can_perform_ability(playbill);
    Enums.FieldActionType.Magic:
      answer = _can_perform_magic(playbill);

  return answer;


## The ability variant of the can_perform function. Assumes it is invoked by movement
## inputs, so certain facts like "is not targeting self" are always true.
func _can_perform_ability(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  var target_pos := playbill.target_position;

  var target_is_obstructed: bool = ActionUtils.place_is_obstructed(playbill.target_position);
  var actor_is_facing_adjacent_target := (actor.faced_position == target_pos);

  return (
    target_is_obstructed
    and actor_is_facing_adjacent_target
  );


## The castable magic variant of the can_perform function.
func _can_perform_magic(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  var target_pos := playbill.target_position;
  var target_distance_vector := target_pos - actor.grid_position;

  var target_is_not_self: bool = (actor.grid_position != target_pos);
  var actor_is_inline: bool = (target_distance_vector.x == 0 or target_distance_vector.y == 0);

  return (
    target_is_not_self
    and actor_is_inline
  );


func perform_async(playbill: FieldActionPlaybill,) -> bool:
  var answer := false;

  match action_type:
    Enums.FieldActionType.Ability:
      answer = await perform_as_ability_async(playbill);
    Enums.FieldActionType.Magic:
      answer = await perform_as_magic_async(playbill);

  return answer;


## The ability variant of the perform_async function. Assumes it is invoked by movement
## inputs, so certain facts like "is not targeting self" are always true.
func perform_as_ability_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  var entities_were_pushed := _try_push_cell(playbill.target_position, playbill.orientation, _push_length);

  if entities_were_pushed:
    _create_push_cloud(actor, playbill.target_position, playbill.orientation);
    Events.one_shot_sound_emitted.emit(scene_scrape_audio);
  else:
    Events.one_shot_sound_emitted.emit(scene_bump_audio);
    if _can_secret_knock:
      Grid.notify_entities_async(playbill.target_position, Stimulus.secret_knock);

  if actor is Player2D:
    # TODO Use actor.play_one_shot_animation('push', true) to interrupt the player's idle
    #  animation with a player-input pause (true).
    actor.set_animation_state('push');
    await Engine.get_main_loop().create_timer(0.25).timeout;

  return true;


## The castable magic variant of the perform_async function.
func perform_as_magic_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  ActionUtils.play_cast_animation(actor, actor.faced_direction);
  Events.one_shot_sound_emitted.emit(scene_cast_audio);
  await Engine.get_main_loop().create_timer(0.20).timeout;

  # Exit early if the cell is not magic pushable.
  if ActionUtils.place_is_wall(playbill.target_position):
    return true;

  # Exit early with animation if there was nothing to push.
  if not ActionUtils.place_is_obstructed(playbill.target_position):
    var reverse_orientation := -playbill.orientation;
    _create_push_cloud(actor, playbill.target_position, reverse_orientation);
    Events.one_shot_sound_emitted.emit(scene_scrape_audio);
    return true;

  # Try to push entities and animate accordingly.
  var entities_were_pushed := _try_push_cell(playbill.target_position, playbill.orientation, _push_length);

  if entities_were_pushed:
    _create_push_cloud(actor, playbill.target_position, playbill.orientation);
    Events.one_shot_sound_emitted.emit(scene_scrape_audio);
  else:
    Events.one_shot_sound_emitted.emit(scene_bump_audio);

  await Engine.get_main_loop().create_timer(0.05).timeout;

  return true;


## A recursive function that attempts to push entities on the Grid at [param place] along
## the [param direction] vector. If the entities are not all pushable, or if the target
## position is not occupiable, the entities will be [Stimulus.bumped] instead.
##
## When calling this function for the first time, [param push_power] is equivalent to how
## many sequential objects are pushable at once.
func _try_push_cell(place: Vector2i, direction: Vector2i, push_power: int) -> bool:
  if push_power < 1:
    return false;

  var next_place := place + direction;

  var collidable_entities := ActionUtils.get_collidable_entities_at(place);
  var cell_is_pushable = (
    not ActionUtils.place_is_wall(place)
    and collidable_entities.all(_entity_is_pushable)
  );
  var next_push_successful := true;

  if cell_is_pushable and ActionUtils.place_is_obstructed(next_place):
    next_push_successful = _try_push_cell(next_place, direction, push_power - 1);

  if not cell_is_pushable or not next_push_successful:
    Grid.notify_entities_async(place, Stimulus.bumped);
    return false;

  for entity in collidable_entities:
    entity.grid_position = next_place;

    if entity is Enemy2D:
      entity.apply_attribute('stun', stun_attribute_resource.duplicate());

  return true;


## Returns true if all entities in [param entities] are pushable. If at least one entity
## is too heavy, or non-pushable by some other means, returns false.
func _entity_is_pushable(entity: GridEntity) -> bool:
  # TODO Entities need a weight value to measure _push_strength against.
  var strength_matched := _push_strength > 0;
  return entity.pushable and strength_matched;


## Creates a push cloud effect node as a sibling of [param entry_node] at
## [param grid_position] facing [param direction].
func _create_push_cloud(entry_node: Node, grid_position: Vector2i, direction: Vector2i) -> void:
  var push_cloud := scene_push_cloud.instantiate();
  entry_node.add_sibling(push_cloud);

  push_cloud.global_position = Grid.get_world_coords(grid_position);
  push_cloud.set_direction(direction);
