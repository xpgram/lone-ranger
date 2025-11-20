class_name Push_FieldAction
extends FieldAction


const scene_push_cloud := preload('uid://hua0n75be2w3');


func action_name() -> String:
  return "Push";


func action_description() -> String:
  return "Move a target one tile over.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func can_perform(playbill: FieldActionPlaybill,) -> bool:
  var cell_entities := Grid.get_entities(playbill.target_position);

  var facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.faced_direction == playbill.target_position
  );

  var tile_obstructed: bool = (
    cell_entities.any(func (entity: GridEntity): return entity.solid)
  );

  return facing_target and tile_obstructed;


func perform_async(playbill: FieldActionPlaybill,) -> void:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  var entities := Grid.get_entities(playbill.target_position);
  _try_push_entities(entities, playbill.orientation);

  if actor is Player2D:
    actor.set_animation_state('push');


func _try_push_entities(entities: Array[GridEntity], direction: Vector2i) -> void:
  var pushable_entities: Array[GridEntity];
  pushable_entities.assign(
    entities.filter(func (entity: GridEntity): return entity.pushable)
  );

  # TODO Is entity is not pushable, but is singular (i.e. is not a wall or something), do a vibrate animation.

  if pushable_entities.size() == 0:
    return;
  
  var current_position := pushable_entities[0].grid_position;
  var push_to_position := current_position + direction;
  var tile_is_obstructed := (
    Grid.get_entities(push_to_position)
      .any(func (entity: GridEntity): return entity.solid)
  );

  if tile_is_obstructed:
    # TODO If push fails, do a vibrate animation instead.
    return;

  for entity in pushable_entities:
    entity.grid_position = push_to_position;

    # TODO Should probably be `if entity.stunnable`; player, enemy, and npc should inherit from a LivingEntity class.
    if entity is Enemy2D:
      entity.tags['stun'] = EntityTagData.new();

  _create_push_cloud(pushable_entities[0], current_position, direction);


func _create_push_cloud(entry_node: Node, grid_position: Vector2i, direction: Vector2i) -> void:
  var push_cloud := scene_push_cloud.instantiate();
  push_cloud.position = Grid.get_world_coords(grid_position);
  push_cloud.set_direction(direction);

  entry_node.add_sibling(push_cloud);
