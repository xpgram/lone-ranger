## An API class for a TileMapLayer with Grid terrain data, such as floor and wall geometry.
class_name GridTileMapLayer
extends TileMapLayer


# TODO Refactor this to exist in the TileSet type.
## Returned by cell query methods if a cell either does not have terrain data or is itself
## empty.
@export var default_cell_terrain_data: CellTerrainData = CellTerrainData.new();


func _ready() -> void:
  add_to_group(Group.TerrainData);


## Returns the [CellTerrainData] for the tile at world position [param global_position].
func get_from_world_coords(global_pos: Vector2) -> CellTerrainData:
  var tile_coords := local_to_map(to_local(global_pos));
  return get_from_grid_coords(tile_coords);


## Returns the [CellTerrainData] for the tile at [param tile_coords].
func get_from_grid_coords(tile_coords: Vector2i) -> CellTerrainData:
  var cell_data := get_cell_tile_data(tile_coords);
  var terrain_data := default_cell_terrain_data;

  if cell_data and cell_data.has_custom_data(Group.TerrainData):
    terrain_data = cell_data.get_custom_data(Group.TerrainData) as CellTerrainData;
  
  assert(terrain_data != null,
    'No CellTerrainData exists. Cannot fulfill request nor return a default.');

  return default_cell_terrain_data;
