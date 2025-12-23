## @static [br]
## A utility class containing functions useful to [FieldAction] scripts and the like.
class_name ActionUtils


## Returns true if the cell at [param place] is free of obstructions.
static func is_cell_traversable(place: Vector2, _entity: GridEntity) -> bool:
  var cell := Grid.get_cell(place);
  return (
    not cell_is_wall(cell)
    and not cell_has_collidables(cell)
  );


## Returns true if the cell at [param place] is sturdy ground and free of obstructions.
static func is_cell_idleable(place: Vector2, _entity: GridEntity) -> bool:
  var cell := Grid.get_cell(place);
  return (
    cell_is_floor(cell)
    and not cell_has_collidables(cell)
  );


## Returns true if the cell at [param place] contains some solid, collidable object.
static func is_cell_obstructed(place: Vector2) -> bool:
  var cell := Grid.get_cell(place);
  return cell_is_wall(cell) or cell_has_collidables(cell);


## Returns true if [param cell] is a floor-type tile.
static func cell_is_pit(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Pit;


## Returns true if [param cell] is a floor-type tile.
static func cell_is_floor(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Floor;


## Returns true if [param cell] is a wall-type tile.
static func cell_is_wall(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Wall;


## Returns true if [param cell] has any inhabiting entity that is collidable.
static func cell_has_collidables(cell: Grid.Cell) -> bool:
  return cell.entities \
    .any(func (entity: GridEntity): return entity.solid);


##
static func target_within_range(actor: GridEntity, target: GridEntity, range: int) -> bool:
  if range < 0:
    return false;

  var distance_vector := (actor.grid_position - target.grid_position).abs();
  return (distance_vector.x + distance_vector.y) <= range;


##
static func get_path_to_target(actor: GridEntity, target_pos: Vector2i) -> Array[Vector2i]:
  # TODO Use Godot's built-in AStar2D class.
  #  AStar is generic enough to handle my custom Grid class, it just needs a bit map-to-map
  #  conversion.

  return [];
