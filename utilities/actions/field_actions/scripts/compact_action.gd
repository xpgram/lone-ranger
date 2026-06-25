class_name Compact_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://dfnf8ej8gvnk6');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity.has_attribute('compactible_to_floor'));


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    # [FIXME] Incorrect check being used here.
    #   This is, more or less, what the stimulus system is for.
    #   Entities that react to being 'compacted' should define a 'spell_compact' stimulus.
    #   compact.gd here only checks that there exist some entities which may react to
    #   being compacted, and if so, asks them to call their own reaction via
    #   Grid.send_stimulus or whatever I called it.

    if entity.name.begins_with('LooseParticles'):
      entity.queue_free();

  # [TODO] How do we know that '2' is a floor? I wish I could define these numbers somewhere.
  #  I think I can get rid of the magic number, at least, by asking BetterTerrain to tell
  #  me which type index is for 'floor' or whatever I've called it.
  Grid.set_tile_type(playbill.target_position, 2);

  return true;
