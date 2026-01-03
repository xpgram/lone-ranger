class_name Compact_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity.has_attribute('compactible_to_floor'));


func perform_async(playbill: FieldActionPlaybill) -> void:
  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    # FIXME Incorrect check being used here.
    # if entity.has_attribute('compactible_to_floor'):
    if entity.name.begins_with('LooseParticles'):
      entity.queue_free();

  var tile_layers: Array[GridTileMapLayer];
  tile_layers.assign(Engine.get_main_loop().get_nodes_in_group(Group.TerrainData));

  BetterTerrain.set_cell(tile_layers[0], playbill.target_position, 2);
  BetterTerrain.update_terrain_area(
    tile_layers[0],
    Rect2i(playbill.target_position, Vector2i(0, 0)),
  );
