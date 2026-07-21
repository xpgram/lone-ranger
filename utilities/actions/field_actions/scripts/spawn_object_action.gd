## A dev-only spell to spawn some object at some location.
class_name SpawnObject_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://dje6ncwpv7kxg');


var object_scene: PackedScene;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  # [TODO] This can_spawn_here check depends on which object you're trying to spawn.
  return (
    not ActionUtils.place_is_obstructed(playbill.target_position)
    and ActionUtils.place_is_floor(playbill.target_position)
  );


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  if not object_scene:
    return true;

  var object := object_scene.instantiate() as GridObject;

  # [FIXME] This adds the object to the PlayerModule instead of the entities node.
  playbill.performer.add_sibling(object);
  playbill.get_parent().move_child(object, 0);

  object.grid_position = playbill.target_position;

  return true;
