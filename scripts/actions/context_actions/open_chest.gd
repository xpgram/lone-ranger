extends ContextAction


@export var chest: ChestEntity;


func can_interact(actor: GridEntity) -> bool:
  var initiated_from_below := (chest.grid_position + Vector2i.DOWN == actor.grid_position);
  var actor_facing_self := (actor.faced_direction == Vector2i.UP);

  return not chest.is_open and initiated_from_below and actor_facing_self;


func perform_interaction_async(actor: GridEntity) -> void:
  chest.is_open = true;

  print('%s obtained a %s...' % [actor.name, chest.contents]);
  # TODO contents is a struct type, including... I guess I'm not sure.
  # TODO initiator.has_node('Inventory')
  # TODO initiator.inventory.add(contents.item * contents.number)

  if actor is Player2D:
    actor.faced_direction = Vector2i.DOWN;
    actor.set_animation_state('item_get!');
    await get_tree().create_timer(1.0).timeout;

    actor.set_animation_state('idle');
