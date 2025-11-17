extends Node


## A struct containing a list of world entities.
class Cell:
  var entities := [] as Array[GridEntity];

## The map of all grid cells.
var _map: Dictionary[StringName, Cell];


## Returns an array of entities from a Cell.
func get_entities(place: Vector2) -> Array[GridEntity]:
  var entities := [] as Array[GridEntity];
  var place_key := _get_key(place);

  if _map.has(place_key):
    entities.assign(_map[place_key].entities);
  
  return entities;


## Inserts an entity into the grid at position 'place'.
func put(entity: GridEntity, place: Vector2) -> void:
  var place_key := _get_key(place);

  # Ensure that entities are not double-placed in the given cell.
  remove(entity, place);

  # Place entity in the desired cell.
  _try_create_cell(place_key);
  _map[place_key].entities.append(entity);


## Removes an entity from the grid at position 'place'.
func remove(entity: GridEntity, place: Vector2) -> void:
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


## If a grid position does not have a Cell, creates one.
func _try_create_cell(place_key: String) -> void:
  if not _map.has(place_key):
    _map[place_key] = Cell.new();


## If a grid position's Cell has no occupiers, releases it from system memory.
func _try_destroy_cell(place_key: String) -> void:
  if (
    _map.has(place_key)
    and _map[place_key].entities.size() == 0
  ):
    _map.erase(place_key);
