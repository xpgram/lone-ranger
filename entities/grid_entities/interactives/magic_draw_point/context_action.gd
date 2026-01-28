extends ContextAction


const _scene_draw_magic_audio := preload('uid://o853vd8awsyr');


@export var _draw_point: MagicDrawPointEntity;


func can_interact(actor: GridEntity) -> bool:
  return (actor.faced_position == _draw_point.grid_position);


func _perform_interaction_async(actor: GridEntity) -> void:
  if (
      not _draw_point.is_drawable()
      or actor is not Player2D
  ):
    return;

  AudioBus.play_audio_scene(_scene_draw_magic_audio);
  _give_magic_to_player(actor);
  await get_tree().create_timer(0.5).timeout;


## Add the draw point's magic contents to the [param player]'s inventory.
func _give_magic_to_player(player: Player2D) -> void:
  var magic_item := _draw_point.magic_item;

  player.inventory.add_item(magic_item);

  # TODO If such a message is logged, it should probably be logged by the inventory itself.
  print("%s obtained %s %s..." % [player.name, magic_item.quantity, magic_item.action.action_name]);
