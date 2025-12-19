## An API class for a TileMapLayer with Grid terrain data, such as floor and wall geometry.
class_name GridTileMapLayer
extends TileMapLayer


func _ready() -> void:
  add_to_group(Group.TerrainData);


## @nullable [br]
## Returns the [CellTerrainData] for the tile at world position [param global_position].
func get_from_world_coords(global_pos: Vector2) -> CellTerrainData:
  var tile_coords := local_to_map(to_local(global_pos));
  return get_from_grid_coords(tile_coords);


## @nullable [br]
## Returns the [CellTerrainData] for the tile at [param tile_coords].
func get_from_grid_coords(tile_coords: Vector2i) -> CellTerrainData:
  var cell_data := get_cell_tile_data(tile_coords);

  if cell_data and cell_data.has_custom_data(Group.TerrainData):
    return cell_data.get_custom_data(Group.TerrainData) as CellTerrainData;
  
  return null;
