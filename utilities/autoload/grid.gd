@tool
extends Node


## The map of all grid cells.
var _map: Dictionary[StringName, InternalCell];


## Inserts an object into the grid at position 'place'.
func put(object: GridObject, place: Vector2) -> void:
  if Engine.is_editor_hint():
    return;

  var place_key := _get_key(place);

  # Ensure that objects are not double-placed in the moved-to cell.
  remove(object, place);

  _try_create_cell(place_key);
  var collided_objects := get_objects(place);

  # Place object in the desired cell.
  _map[place_key].objects.append(object);

  # Run collisions.
  for collided_object in collided_objects:
    # TODO Add function signature: Who was collided with?
    object.react_async(Stimulus.object_collision, [collided_object]);
    collided_object.react_async(Stimulus.object_collision, [object]);


## Removes an object from the grid at position 'place'.
func remove(object: GridObject, place: Vector2) -> void:
  if Engine.is_editor_hint():
    return;

  var place_key := _get_key(place);

  if not _map.has(place_key):
    return;

  var cell := _map[place_key];

  if object not in cell.objects:
    return;

  # Filter object-to-remove from the cell's list of objects.
  cell.objects = cell.objects.filter(func (cell_object): return cell_object != object);

  # Run collisions.
  for cell_object in cell.objects:
    cell_object.react_async(Stimulus.object_separation, [object]);

  _try_destroy_cell(place_key);


## Removes all data from all known Cells.
func clear_map() -> void:
  _map.clear();


## Returns an array of [GridEntity] objects found at [param place] on the Grid. [br]
##
## [b]Note:[/b] This list may not contain all [GridObject]'s found at the same location.
## For that, use [method get_objects] instead.
func get_entities(place: Vector2) -> Array[GridEntity]:
  var objects := get_objects(place);

  var entities: Array[GridEntity];
  entities.assign(objects.filter(func (object): return object is GridEntity));

  return entities;


## Returns an array of [GridObject] objects found at [param place] on the Grid.
func get_objects(place: Vector2) -> Array[GridObject]:
  var objects := [] as Array[GridObject];
  var place_key := _get_key(place);

  if _map.has(place_key):
    objects.assign(_map[place_key].objects);

  return objects;


## Sets the [param terrain_type] of a tile at [param place] in the world [TileMapLayer]. [br]
##
## Use [param terrain_type] -1 to erase cells.
func set_tile_type(place: Vector2i, terrain_type: int) -> void:
  var tilemap := _get_tilemap();
  var update_dimensions := Rect2i(place, Vector2.ZERO);

  BetterTerrain.set_cell(tilemap, place, terrain_type);
  BetterTerrain.update_terrain_area(tilemap, update_dimensions);


## Invokes the [GridObject] stimulus reaction system by notifying the objects at
## [param place] that [param stimulus_name] has occurred.
func notify_objects_async(place: Vector2i, stimulus_name: StringName) -> void:
  var objects := get_objects(place);
  var notify_promises: Array[Promise];

  for object in objects:
    var promise := Promise.new(func ():
      await object.react_async(stimulus_name);
    );
    notify_promises.append(promise);

  await Promise.all(notify_promises).finished;


## Returns an array of [CellTerrainData] for the tile at [param place].
## If the array is empty, no tilemap data exists in the terrain-data group.
func get_tile_data(place: Vector2) -> CellTerrainData:
  var tilemap := _get_tilemap();

  if not tilemap:
    return CellTerrainData.new();

  return tilemap.get_from_grid_coords(place);


## Returns a struct containing all information about the grid cell at [param place].
func get_cell(place: Vector2) -> Cell:
  var cell := Cell.new();
  cell.tile_data = get_tile_data(place);
  cell.objects = get_objects(place);
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


## @nullable [br]
## Returns the world [TileMapLayer] from the global layers group.
func _get_tilemap() -> GridTileMapLayer:
  var tile_layers: Array[GridTileMapLayer];
  tile_layers.assign(get_tree().get_nodes_in_group(Group.TerrainData));

  if tile_layers.size() == 0:
    push_error('Grid: No tile map layers found.');

  return tile_layers[0];


## If a grid position does not have an [InternalCell], creates one.
func _try_create_cell(place_key: String) -> void:
  if not _map.has(place_key):
    _map[place_key] = InternalCell.new();


## If a grid position's [InternalCell] has no occupiers, releases it from system memory.
func _try_destroy_cell(place_key: String) -> void:
  if (
    _map.has(place_key)
    and _map[place_key].objects.size() == 0
  ):
    _map.erase(place_key);


## @internal-only [br]
## A struct containing a list of [GridObject]'s and other important cell information not
## described by the tilemap.
##
## Use [class Cell] for the public API cell data.
class InternalCell extends RefCounted:
  var objects := [] as Array[GridObject];


## A struct containing a list of [GridObject]'s and other important cell information.
class Cell extends RefCounted:
  var tile_data: CellTerrainData;
  var objects: Array[GridObject];
