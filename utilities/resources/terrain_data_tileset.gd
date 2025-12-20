##
class_name TerrainDataTileSet
extends TileSet


# IMPLEMENT This class is unfinished. Maybe.
# - The old tileset info, including all sources, custom data, and better-terrain data
#   must be ported over.
# - It would be nice if GridTileMapLayer did not need to know what a 'default terrain
#   data' was, i.e., this class just returned it naturally when asked.


const CUSTOM_DATA_LAYER_TYPE_OBJECT := 15;


@export var _default_terrain_data: CellTerrainData = CellTerrainData.new();


func _init() -> void:
  add_custom_data_layer(0);
  set_custom_data_layer_name(0, 'terrain_data');
  set_custom_data_layer_type(0, CUSTOM_DATA_LAYER_TYPE_OBJECT);


func get_default_terrain_data() -> CellTerrainData:
  return _default_terrain_data;


func get_cell_terrain_data() -> void:
  pass
