extends ContextAction


@export var chest: ChestEntity;


func can_interact(actor: GridEntity) -> bool:
  var initiated_from_below := (chest.grid_position + Vector2i.DOWN == actor.grid_position);
  var actor_facing_self := (actor.faced_direction == Vector2i.UP);

  return not chest.is_open and initiated_from_below and actor_facing_self;


func perform_interaction_async(actor: GridEntity) -> void:
  chest.is_open = true;
  actor.faced_direction = Vector2i.DOWN;

  if actor is Player2D:
    _give_items_to_actor(actor);
    $Audio/ChestOpen.play();
    await _play_animation_async(actor);


## Add the chest's contents to the inventory of [param actor].
func _give_items_to_actor(actor: Player2D) -> void:
  for item in chest.contents:
    actor.inventory.add_item(item);

    # TODO If such a message is logged, it should probably be logged by the inventory itself.
    print('%s obtained %s %s...' % [actor.name, item.quantity, item.action.action_name]);

  for equipment in chest.equipment_contents:
    actor.inventory.add_equipment(equipment);

    # TODO If such a message is logged, it should probably be logged by the inventory itself.
    print('%s obtained %s...' % [actor.name, equipment]);

  # FIXME This is scuffed as hell, and should not be here.
  if chest.heart_pieces > 0:
    for i in range(chest.heart_pieces):
      actor.inventory.add_equipment('heart_piece');

    var total_heart_pieces: float = actor.inventory._equipment \
      .filter(func (equipment): return equipment == 'heart_piece') \
      .size();
    # 2 HP is 1 heart container, but half containers are not allowed. Also, base is 2 containers.
    var num_heart_containers := int(total_heart_pieces / 2) * 2 + 4;

    var health_component := Component.get_component(actor, HealthComponent) as HealthComponent;
    health_component.maximum = num_heart_containers;

    print('%s obtained %s heart pieces!' % [actor.name, chest.heart_pieces]);


## Plays a scripted animation using [param actor].
func _play_animation_async(actor: Player2D) -> void:
  actor.set_animation_state('item_get!');
  await get_tree().create_timer(1.0).timeout;
  actor.set_animation_state('idle');

  # TODO This should trigger a dialogue box, shouldn't it?
