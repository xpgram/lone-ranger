## A dev-only spell to delete all player interactible objects at some location.
## This does not include infrastructural objects, like TriggerBoxes, etc.
class_name DeleteObjects_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://dje6ncwpv7kxg');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var grid_objects := Grid.get_objects(playbill.target_position);
  return grid_objects.any(_object_is_deletable);


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  var grid_objects := Grid.get_objects(playbill.target_position);
  var deletable := grid_objects.filter(_object_is_deletable) as Array[GridObject];

  for object in deletable:
    print("Deleted %s" % object.name)
    object.queue_free();

  return true;


func _object_is_deletable(object: GridObject) -> bool:
  return (
    object is not Player2D
    and (
      object is Enemy2D
      or object is Interactive2D
    )
  );
