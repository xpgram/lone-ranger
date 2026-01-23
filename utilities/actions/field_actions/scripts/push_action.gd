class_name Push_FieldAction
extends FieldAction


const scene_push_cloud := preload('uid://hua0n75be2w3');
const scene_bump_audio := preload('uid://cvkl4d3g51ocn');
const scene_scrape_audio := preload('uid://ckshk52e1bn74');
const stun_attribute_resource := preload('uid://jnysha6rnoxl');


## How many objects in sequence may be pushed at once.
@export var _push_length := 1;

## A measure of how heavy the objects pushed may be.
@export var _push_strength := 1;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.faced_direction == playbill.target_position
  );
  var tile_obstructed: bool = ActionUtils.place_is_obstructed(playbill.target_position);

  return facing_target and tile_obstructed;


func perform_async(playbill: FieldActionPlaybill,) -> bool:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  var cells_to_push_reversed := _get_cells_to_push(playbill.target_position, playbill.orientation);
  cells_to_push_reversed.reverse();

  for cell in cells_to_push_reversed:
    _try_push_entities(cell.entities, playbill.orientation);

  # TODO Maybe _try_push_entities() should just return a boolean?
  var entities_were_pushed := not ActionUtils.place_is_obstructed(playbill.target_position);

  if entities_were_pushed:
    _create_push_cloud(actor, playbill.target_position, playbill.orientation);
    Events.one_shot_sound_emitted.emit(scene_scrape_audio);
  else:
    Events.one_shot_sound_emitted.emit(scene_bump_audio);

  if actor is Player2D:
    # TODO Use actor.play_one_shot_animation('push', true) to interrupt the player's idle
    #  animation with a player-input pause (true).
    actor.set_animation_state('push');
    await Engine.get_main_loop().create_timer(0.25).timeout;

  return true;


## Returns a list of [Grid.Cell] that may be affected by the push, starting at position
## [param from] and extending in [param direction]. The list is at most size
## [member _push_length], but may be less if the line of pushed objects contains a gap.
func _get_cells_to_push(from: Vector2i, direction: Vector2i) -> Array[Grid.Cell]:
  var grid_cells := [] as Array[Grid.Cell];
  var cursor := from;

  for i in range(_push_length):
    var cell := Grid.get_cell(cursor);
    var cell_is_empty := cell.entities.size() == 0;

    if cell_is_empty:
      break;

    grid_cells.append(cell);
    cursor += direction;

  return grid_cells;


## Attempts to push the given [param entities] along the [param direction] vector. If the
## given [param entities] are not all pushable, or if the target position is not
## occupiable, the [param entities] will be 'bumped' instead.
func _try_push_entities(entities: Array[GridEntity], direction: Vector2i) -> void:
  if entities.size() == 0:
    return;

  var current_position := entities[0].grid_position;
  var push_to_position := current_position + direction;
  var tile_is_obstructed := ActionUtils.place_is_obstructed(push_to_position);
  var entities_not_pushable := not _all_entities_pushable(entities);

  if tile_is_obstructed or entities_not_pushable:
    Grid.notify_entities_async(current_position, Stimulus.bumped);

  else:
    for entity in entities:
      entity.grid_position = push_to_position;

      if entity is Enemy2D:
        entity.apply_attribute('stun', stun_attribute_resource.duplicate());


## Returns true if all entities in [param entities] are pushable. If at least one entity
## is too heavy, or non-pushable by some other means, returns false.
func _all_entities_pushable(entities: Array[GridEntity]) -> bool:
  return entities.all(func (entity: GridEntity):
    # TODO Entities need a weight value to measure _push_strength against.
    var strength_matched := _push_strength > 0;
    return entity.pushable and strength_matched;
  );


## Creates a push cloud effect node as a sibling of [param entry_node] at
## [param grid_position] facing [param direction].
func _create_push_cloud(entry_node: Node, grid_position: Vector2i, direction: Vector2i) -> void:
  var push_cloud := scene_push_cloud.instantiate();
  entry_node.add_sibling(push_cloud);

  push_cloud.global_position = Grid.get_world_coords(grid_position);
  push_cloud.set_direction(direction);
