## @static [br]
##
##
class_name ActionUtils


##
static func is_cell_traversable(place: Vector2, _entity: GridEntity) -> bool:
  var cell := get_cell_data(place);
  return not cell_has_wall(cell) and not cell_has_entity_obstructions(cell);


##
static func is_cell_idleable(place: Vector2, _entity: GridEntity) -> bool:
  var cell := get_cell_data(place);
  return (
    cell_has_floor(cell)
    and not cell_has_wall(cell)
    and not cell_has_entity_obstructions(cell)
  );


##
static func is_cell_obstructed(place: Vector2) -> bool:
  var cell := get_cell_data(place);
  return cell_has_wall(cell) or cell_has_entity_obstructions(cell);


##
static func cell_has_floor(cell: CellData) -> bool:
  return cell.tile_data \
    .any(func (terrain_data: CellTerrainData): return terrain_data.geometry_type == CellTerrainData.GeometryType.Floor)


##
static func cell_has_wall(cell: CellData) -> bool:
  return cell.tile_data \
    .any(func (terrain_data: CellTerrainData): return terrain_data.geometry_type == CellTerrainData.GeometryType.Wall)


##
static func cell_has_entity_obstructions(cell: CellData) -> bool:
  return cell.entities \
    .any(func (entity: GridEntity): return entity.solid);


# TODO It would be nice if Grid could return this package itself.
##
static func get_cell_data(place: Vector2) -> CellData:
  var cell_data := CellData.new();
  cell_data.tile_data = Grid.get_tile_data(place);
  cell_data.entities = Grid.get_entities(place);
  return cell_data;


# TODO This type should exist in Grid, ideally.
##
class CellData:
  var tile_data: Array[CellTerrainData];
  var entities: Array[GridEntity];
