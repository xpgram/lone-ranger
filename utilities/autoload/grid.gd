@tool
extends Node


## The map of all grid cells.
var _map: Dictionary[StringName, InternalCell];


## Inserts an entity into the grid at position 'place'.
func put(entity: GridEntity, place: Vector2) -> void:
  if Engine.is_editor_hint():
    return;

  var place_key := _get_key(place);

  # Ensure that entities are not double-placed in the given cell.
  remove(entity, place);

  # Place entity in the desired cell.
  _try_create_cell(place_key);
  _map[place_key].entities.append(entity);


## Removes an entity from the grid at position 'place'.
func remove(entity: GridEntity, place: Vector2) -> void:
  if Engine.is_editor_hint():
    return;

  var place_key := _get_key(place);

  if not _map.has(place_key):
    return;

  # Filter entity from the cell's list of entities.
  var cell := _map[place_key];
  cell.entities = cell.entities.filter(func (cell_entity): return cell_entity != entity);

  _try_destroy_cell(place_key);


## Removes all data from all known Cells.
func clear_map() -> void:
  _map.clear();


## Returns the array of entities at a Cell.
func get_entities(place: Vector2) -> Array[GridEntity]:
  var entities := [] as Array[GridEntity];
  var place_key := _get_key(place);

  if _map.has(place_key):
    entities.assign(_map[place_key].entities);
  
  return entities;


## Returns an array of [CellTerrainData] for the tile at [param place].
## If the array is empty, no tilemap data exists in the terrain-data group.
func get_tile_data(place: Vector2) -> Array[CellTerrainData]:
  var terrain_data: Array[CellTerrainData];

  terrain_data.assign(
    get_tree()
      .get_nodes_in_group(Group.TerrainData)
      .map(func (layer: GridTileMapLayer): return layer.get_from_grid_coords(place))
  );

  return terrain_data;


## Returns a struct containing all information about a grid cell.
func get_cell(place: Vector2) -> Cell:
  var cell := Cell.new();
  cell.tile_data = get_tile_data(place)[0]; # TODO [0] here is silly.
  cell.entities = get_entities(place);
  return cell;


## Given a world-space vector, return its equivalent position on the Grid.
func get_grid_coords(vector: Vector2) -> Vector2i:
  return Vector2i(
    (vector / Constants.GRID_SIZE).floor()
  );


## Given a Grid position, returns the world-space vector for that Grid Cell's center.
func get_world_coords(place: Vector2i) -> Vector2:
  return Vector2(place * Constants.GRID_SIZE);


## Returns the dictionary map key for a grid position.
func _get_key(place: Vector2) -> StringName:
  return &"%sx %sy" % [int(place.x), int(place.y)];


## If a grid position does not have an [InternalCell], creates one.
func _try_create_cell(place_key: String) -> void:
  if not _map.has(place_key):
    _map[place_key] = InternalCell.new();


## If a grid position's [InternalCell] has no occupiers, releases it from system memory.
func _try_destroy_cell(place_key: String) -> void:
  if (
    _map.has(place_key)
    and _map[place_key].entities.size() == 0
  ):
    _map.erase(place_key);


## @internal-only [br]
## A struct containing a list of grid entities and other important cell information not
## described by the tilemap.
##
## Use [class Cell] for the public API cell data.
class InternalCell:
  var entities := [] as Array[GridEntity];


## A struct containing a list of grid entities and other important cell information.
class Cell:
  var tile_data: CellTerrainData;
  var entities: Array[GridEntity];
