class_name Push_FieldAction
extends FieldAction


const scene_push_cloud := preload('uid://hua0n75be2w3');
const stun_attribute_resource := preload('uid://jnysha6rnoxl');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.faced_direction == playbill.target_position
  );

  var tile_obstructed: bool = ActionUtils.place_is_obstructed(playbill.target_position);

  return facing_target and tile_obstructed;


func perform_async(playbill: FieldActionPlaybill,) -> bool:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  var entities := Grid.get_entities(playbill.target_position);
  _try_push_entities(entities, playbill.orientation);

  if actor is Player2D:
    actor.set_animation_state('push');
    await Engine.get_main_loop().create_timer(0.25).timeout;

  return true;


func _try_push_entities(entities: Array[GridEntity], direction: Vector2i) -> void:
  var pushable_entities: Array[GridEntity];
  pushable_entities.assign(
    entities.filter(func (entity: GridEntity): return entity.pushable)
  );

  if pushable_entities.size() == 0:
    return;
  
  var current_position := pushable_entities[0].grid_position;
  var push_to_position := current_position + direction;
  var tile_is_obstructed := ActionUtils.place_is_obstructed(push_to_position);

  if tile_is_obstructed:
    # TODO If entity is not pushable, but is a collidable (i.e. not a wall or something),
    #  have the bumped object do a vibrate animation.
    return;

  for entity in pushable_entities:
    entity.grid_position = push_to_position;

    # TODO Should probably be `if entity.stunnable`, even if such a thing is stored on the enemy class.
    if entity is Enemy2D:
      entity.apply_attribute('stun', stun_attribute_resource.duplicate());

  _create_push_cloud(pushable_entities[0], current_position, direction);


func _create_push_cloud(entry_node: Node, grid_position: Vector2i, direction: Vector2i) -> void:
  var push_cloud := scene_push_cloud.instantiate();
  entry_node.add_sibling(push_cloud);

  push_cloud.position = Grid.get_world_coords(grid_position);
  push_cloud.set_direction(direction);
