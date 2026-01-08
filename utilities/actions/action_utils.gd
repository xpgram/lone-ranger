## @static [br]
## A utility class containing functions useful to [FieldAction] scripts and the like.
class_name ActionUtils


## Returns true if [param cell] has any inhabiting entity that is collidable.
static func cell_has_collidables(cell: Grid.Cell) -> bool:
  return cell.entities \
    .any(func (entity: GridEntity): return entity.solid);


## Returns true if [param cell] is a floor-type tile.
static func cell_is_floor(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Floor;


## Returns true if [param cell] is a floor-type tile.
static func cell_is_pit(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Pit;


## Returns true if [param cell] is a wall-type tile.
static func cell_is_wall(cell: Grid.Cell) -> bool:
  return cell.tile_data.geometry_type == CellTerrainData.GeometryType.Wall;


## Returns an array of [Vector2i] coordinates on the Grid in the shape of a line extending
## from [param from] in direction [param direction]. Does not include [param from] in the
## result.
static func get_coordinate_line(from: Vector2i, direction: Vector2i, distance: int) -> Array[Vector2i]:
  var grid_positions := [] as Array[Vector2i];
  var cursor := from + direction;

  for i in range(distance):
    grid_positions.append(cursor);
    cursor += direction;

  return grid_positions;


## Returns a [Vector2i] in one of the four cardinal directions closest to the angle
## between [param from] and [param to]. [br]
## If [param from] and [param to] are the same position, returns [Vector2i.ZERO].
static func get_direction_to_target(from: Vector2, to: Vector2) -> Vector2i:
  if from == to:
    return Vector2i.ZERO;
  
  var difference_vector := to - from;
  var angle := Vector2.RIGHT.angle_to(difference_vector);
  angle = round(angle / Math.HALF_PI) * Math.HALF_PI;
  return Vector2.from_angle(angle).round();


## Returns an array of [Vector2i] instructions that if followed would lead [param actor]
## to [param target_pos]. If no path could be found, the returned array will be empty.
static func get_path_to_target(actor: GridEntity, target_pos: Vector2i) -> Array[Vector2i]:
  # IMPLEMENT Use QueueSearch to build a path toward a breadth-found target.
  # TODO Or use Godot's built-in AStar2D class.
  #  AStar is generic enough to handle my custom Grid class, it just needs a bit map-to-map
  #  conversion.

  return [];


## @nullable [br]
## Returns the player instance if it has been added to the scene. If no player is found,
## returns null instead.
static func get_player_entity() -> Player2D:
  var players: Array = Engine.get_main_loop().get_nodes_in_group(Group.Player);
  return players[0] if players.size() > 0 else null;


## Returns true if the cell at [param place] is sturdy ground and free of obstructions.
static func is_cell_idleable(place: Vector2i, _entity: GridEntity) -> bool:
  var cell := Grid.get_cell(place);
  return (
    cell_is_floor(cell)
    and not cell_has_collidables(cell)
  );


## Returns true if the cell at [param place] contains some solid, collidable object.
static func is_cell_obstructed(place: Vector2i) -> bool:
  var cell := Grid.get_cell(place);
  return cell_is_wall(cell) or cell_has_collidables(cell);


## Returns true if the cell at [param place] contains no objects or properties that would
## obstruct vision lines.
static func is_cell_transparent(place: Vector2i) -> bool:
  return not is_cell_obstructed(place);


## Returns true if the cell at [param place] is free of obstructions.
static func is_cell_traversable(place: Vector2i, _entity: GridEntity) -> bool:
  var cell := Grid.get_cell(place);
  return (
    not cell_is_wall(cell)
    and not cell_has_collidables(cell)
  );


## Returns true if the cell at [param place] is a pit-type tile.
static func place_is_floor(place: Vector2i) -> bool:
  var cell := Grid.get_cell(place);
  return cell_is_floor(cell);


## Returns true if the cell at [param place] is a floor-type tile.
static func place_is_pit(place: Vector2i) -> bool:
  var cell := Grid.get_cell(place);
  return cell_is_pit(cell);


## Returns true if the cell at [param place] is a wall-type tile.
static func place_is_wall(place: Vector2i) -> bool:
  var cell := Grid.get_cell(place);
  return cell_is_wall(cell);


## Returns true if [param target_pos] is on the same row or column as [param actor] and
## within the grid distance [param grid_range].
static func target_pos_within_line_range(actor: GridEntity, target_pos: Vector2i, grid_range: int) -> bool:
  if grid_range < 0:
    return false;

  var in_line := (actor.grid_position.x == target_pos.x or actor.grid_position.y == target_pos.y);
  var in_range := target_pos_within_range(actor, target_pos, grid_range);
  return in_line and in_range;



## Returns true if [param target_pos] is within the grid distance [param grid_range] from
## [param actor].
static func target_pos_within_range(actor: GridEntity, target_pos: Vector2i, grid_range: int) -> bool:
  if grid_range < 0:
    return false;

  var distance_vector := (actor.grid_position - target_pos).abs();
  return (distance_vector.x + distance_vector.y) <= grid_range;
