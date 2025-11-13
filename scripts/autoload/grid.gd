extends Node

## A struct containing a list of world entities.
class Cell:
  var entities := [] as Array[Node2D];

## The map of all grid cells.
var _map: Dictionary[StringName, Cell];


## Returns an array of entities from a Cell.
func get_entities(place: Vector2) -> Array[Node2D]:
  var entities := [] as Array[Node2D];
  var place_key := _get_key(place);

  if _map.has(place_key):
    entities.assign(_map[place_key].entities);
  
  return entities;


## Inserts an entity into the grid at position 'place'.
func put(entity: Node2D, place: Vector2) -> void:
  var place_key := _get_key(place);

  # Using math, try to remove object from its old cell.
  var old_place := Vector2(
    int(entity.position.x / Constants.GRID_SIZE),
    int(entity.position.y / Constants.GRID_SIZE),
  );
  remove(entity, old_place);

  # Place object in the desired cell.
  _try_create_cell(place_key);
  _map[place_key].entities.append(entity);


## Removes an entity from the grid at position 'place'.
func remove(object: Node2D, place: Vector2) -> void:
  var place_key := _get_key(place);

  if not _map.has(place_key):
    return;

  # Filter object from the cell's list of entities.
  var cell := _map[place_key];
  cell.entities = cell.entities.filter(func (entity): return entity != object);

  _try_destroy_cell(place_key);


## Removes all data from all known Cells.
func clear_map() -> void:
  _map.clear();


## Returns the dictionary map key for a grid position.
func _get_key(place: Vector2) -> StringName:
  return str(place);


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
