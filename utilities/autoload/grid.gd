@tool
extends Node


## The map of all grid cells.
var _map: Dictionary[StringName, InternalCell];


## Inserts [param object] into the Grid at position [param place]. If given, will also
## remove [param object] from [param from]. [br]
##
## [b]Warning:[/b] [param from] is a convenience for moving single-cell objects around,
## this method will not stop you from adding multiple object references to different
## places on the Grid. [br]
##
## This method will send collision [Stimulus] to objects at [param place] and [param from]
## if [param object] was successfully added or removed from those locations. The
## separation [Stimulus] at [param from] occurs before collisions at [param place] do.
func put(object: GridObject, place: Vector2, from: Vector2 = Vector2.INF) -> void:
  if Engine.is_editor_hint():
    return;

  var to_place_key := _get_key(place);
  var from_place_key := _get_key(from);

  var object_removed := false;
  var object_added := false;

  # We must finish moving the object on the map before running collision checks so that
  # the object has a referenceable position on the board during collision callbacks.
  if from != Vector2.INF:
    object_removed = _remove_from_map(object, from_place_key);
  object_added = _add_to_map(object, to_place_key);

  if to_place_key == from_place_key:
    # Only signal the 'added' collision if the object really was added.
    if object_added and not object_removed:
      _notify_collision(object, place);
  else:
    if object_removed:
      _notify_separation(object, from);
    if object_added:
      _notify_collision(object, place);


## Removes [param object] from the Grid at position [param place]. [br]
##
## If you are calling [method remove] before [method put], you should instead call
## [code]Grid.put(object, to, from)[/code] to [b]avoid double-emitting collision
## events.[/b] [br]
##
## This method will send collision [Stimulus] to objects at [param place] if
## [param object] was successfully removed.
func remove(object: GridObject, place: Vector2) -> void:
  if Engine.is_editor_hint():
    return;

  var object_removed := _remove_from_map(object, _get_key(place));
  if object_removed:
    _notify_separation(object, place);


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


## Returns true if [param object] is located at [param place] on the Grid.
func has_object(object: GridObject, place: Vector2) -> bool:
  var place_key := _get_key(place);

  if not _map.has(place_key):
    return false;

  var cell := _map[place_key];
  return cell.objects.has(object);


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


## Tries to add [param object] to the Grid at [param place_key] and returns true if the
## operation was successful. [br]
##
## If [param object] already exists at the location given, this will count as a failure to
## add and this method will return false.
func _add_to_map(object: GridObject, place_key: String) -> bool:
  if Engine.is_editor_hint():
    return false;

  _try_create_cell(place_key);
  var cell := _map[place_key];
  var object_was_added := false;

  if not cell.objects.has(object):
    cell.objects.append(object);
    object_was_added = true;

  return object_was_added;


## Tries to remove [param object] from the Grid at [param place_key] and returns true if
## the operation was successful.
func _remove_from_map(object: GridObject, place_key: String) -> bool:
  if (
      Engine.is_editor_hint()
      or not _map.has(place_key)
  ):
    return false;

  var cell := _map[place_key];
  var original_list_size := cell.objects.size();

  cell.objects = cell.objects.filter(func (cell_object): return cell_object != object);
  _try_destroy_cell(place_key);

  return cell.objects.size() != original_list_size;


## Emits collision [Stimulus] to all objects at [param place] that [param object] is
## colliding with them.
func _notify_collision(object: GridObject, place: Vector2) -> void:
  var collided_objects := get_objects(place);

  for collided_object in collided_objects:
    if collided_object == object:
      continue;
    object.react_async(Stimulus.object_collision, [collided_object]);
    collided_object.react_async(Stimulus.object_collision, [object]);


## Emits collision [Stimulus] to all objects at [param place] that [param object] is
## ending a collision with them.
func _notify_separation(object: GridObject, place: Vector2) -> void:
  var detached_objects := get_objects(place);

  for detached_object in detached_objects:
    if detached_object == object:
      continue;
    object.react_async(Stimulus.object_separation, [detached_object]);
    detached_object.react_async(Stimulus.object_separation, [object]);


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
