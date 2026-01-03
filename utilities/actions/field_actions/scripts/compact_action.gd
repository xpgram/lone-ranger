class_name Compact_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity.has_attribute('compactible_to_floor'));


func perform_async(playbill: FieldActionPlaybill) -> void:
  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    if entity.has_attribute('compactible_to_floor'):
      entity.queue_free();

  var tile_layers: Array[GridTileMapLayer];
  tile_layers.assign(Engine.get_main_loop().get_nodes_in_group(Group.TerrainData));

  var changeset := BetterTerrain.create_terrain_changeset(tile_layers[0], {
    playbill.target_position: 2,
  });
  BetterTerrain.apply_terrain_changeset(changeset);
