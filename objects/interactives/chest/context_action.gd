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
  # FIXME Okay, this is bad file structure.
  #   I'm making changes to the way animations are called, and I forgot where this script
  #   even was for a good second. Having to mine through every game object I've ever made
  #   to find a ContextAction that might touch something I'm updating is misery.
  #   I don't *necessarily* mind that these ContextActions are part of the Chest .tscn,
  #   I kind of dread the thought of the alternative, honestly, but the ContextAction
  #   script can't be located here. It needs to be held with all the others.

  if actor is Player2D:
    actor.faced_direction = Vector2i.DOWN;
    actor.animation_set_player.play('item_get!', actor.faced_direction);
    await get_tree().create_timer(1.0).timeout;

    actor.animation_set_player.play('idle', actor.faced_direction);
