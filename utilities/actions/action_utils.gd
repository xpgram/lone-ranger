## @static [br]
##
##
class_name ActionUtils


##
static func is_cell_traversable(place: Vector2) -> bool:
  var cell := _get_cell_data(place);
  return cell_has_no_walls(cell) and cell_has_no_obstructions(cell);


##
static func is_cell_idleable(place: Vector2, _entity: GridEntity) -> bool:
  var cell := _get_cell_data(place);
  return (
    cell_has_floor(cell)
    and cell_has_no_walls(cell)
    and cell_has_no_obstructions(cell)
  );


##
static func cell_has_floor(cell: CellData) -> bool:
  return cell.tile_data \
    .any(func (terrain_data: CellTerrainData): return terrain_data.geometry_type == CellTerrainData.GeometryType.Floor)


##
static func cell_has_no_walls(cell: CellData) -> bool:
  return cell.tile_data \
    .all(func (terrain_data: CellTerrainData): return terrain_data.geometry_type != CellTerrainData.GeometryType.Wall)


##
static func cell_has_no_obstructions(cell: CellData) -> bool:
  return cell.entities \
    .all(func (entity: GridEntity): return not entity.solid);


# TODO It would be nice if Grid could return this package itself.
##
static func _get_cell_data(place: Vector2) -> CellData:
  var cell_data := CellData.new();
  cell_data.tile_data = Grid.get_tile_data(place);
  cell_data.entities = Grid.get_entities(place);
  return cell_data;


# TODO This type should exist in Grid, ideally.
##
class CellData:
  var tile_data: Array[CellTerrainData];
  var entities: Array[GridEntity];
