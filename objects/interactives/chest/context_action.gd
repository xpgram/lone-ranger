extends ContextAction


@export var chest: ChestEntity;


func can_interact(actor: GridEntity) -> bool:
  var initiated_from_below := (chest.grid_position + Vector2i.DOWN == actor.grid_position);
  var actor_facing_self := (actor.facing_direction == Vector2i.UP);

  return not chest.is_open and initiated_from_below and actor_facing_self;


func perform_interaction_async(actor: GridEntity) -> void:
  chest.is_open = true;

  print('%s obtained a %s...' % [actor.name, chest.contents]);
  # TODO contents is a struct type, including... I guess I'm not sure.
  # TODO initiator.has_node('Inventory')
  # TODO initiator.inventory.add(contents.item * contents.number)

  var dirs := [
    Vector2i.RIGHT,
    Vector2i.UP,
    Vector2i.LEFT,
    Vector2i.DOWN,
  ];

  actor.facing_direction = Vector2i.DOWN;
  await get_tree().create_timer(0.25).timeout;

  for dir in dirs:
    actor.facing_direction = dir;
    await get_tree().create_timer(0.05).timeout;

  await get_tree().create_timer(0.25).timeout;
