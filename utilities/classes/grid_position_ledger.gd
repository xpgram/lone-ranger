## A ledger class for keeping track of recent Grid locations.
class_name GridPositionLedger
extends Resource


## How many recent Grid locations will be tracked. [br]
##
## The "recent locations" list is a historical record of the last `n` Grid
## locations logged. These are contiguous, and so allow duplicate locations.
@export var max_recent_locations := 16;

## How many recovery Grid locations will be tracked. [br]
##
## The "recovery locations" list is a historical record of the last `n` valid
## recovery locations logged. This generally includes any non-brittle tile. [br]
##
## Duplicate locations serve no purpose here, so same-value additions are simply
## lifted to the top of the stack. This means the list is not guaranteed to be
## contiguous.
@export var max_recovery_locations := 16;

## How many stable-recovery locations will be tracked. [br]
##
## The "stable recovery locations" list is a historical record of the last `n`
## fallback-recovery locations logged. Fallback recovery locations have
## stricter terms for what counts as a recovery location, such as not including
## toggleable bridge tiles, so represents locations that are more likely to be
## valid for recovery. [br]
##
## Duplicate locations serve no purpose here, so same-value additions are simply
## lifted to the top of the stack. This means the list is not guaranteed to be
## contiguous.
@export var max_stable_recovery_locations := 8;


## The greatest recovery fallback location. Usually represents a save-point.
var _respawn_point := Vector2i.ZERO;

## A list of recently visited Grid locations. [br]
##
## This list is organized by exclusively by recency, so may contain duplicates.
var _recent_locations := [] as Array[Vector2i];

## A list of recently visited recovery locations. A recovery location includes
## any tile that is non-brittle (e.g. GlassTiles). [br]
##
## This list is organized by recency and contains no duplicates.
var _recent_recovery_locations := [] as Array[Vector2i];

## A list of recently visited, very-stable recovery locations. This list has
## stricter terms for what counts as a recovery location, so tracks places
## that are more likely to be valid for recovery. [br]
##
## This list is organized by recency and contains no duplicates.
var _recent_stable_recovery_locations := [] as Array[Vector2i];


## Sets the respawn point, usually reserved for Save Idols.
func set_respawn_point(place: Vector2i) -> void:
  _respawn_point = place;


## Logs a [param place] on the Grid in the list of recent locations. If the
## given [param place] is not a viable recovery point for [param entity], then
## it will be ignored.
func log_position(place: Vector2i, entity: GridEntity) -> void:
  if not ActionUtils.place_is_standable(place):
    return;

  _recent_locations.append(place);

  _recent_recovery_locations.erase(place);
  _recent_recovery_locations.append(place);

  if ActionUtils.place_is_idleable_and_sturdy(place, entity):
    _recent_stable_recovery_locations.erase(place);
    _recent_stable_recovery_locations.append(place);

  # [TODO] Make sure [-MAX - 1] is the correct math. -1 for end as well, I guess.
  # [TODO] Factor out to a helper function?

  # Enforce list size limits.
  if _recent_locations.size() > max_recent_locations:
    _recent_locations = _recent_locations.slice(-max_recent_locations - 1, -1);

  if _recent_recovery_locations.size() > max_recovery_locations:
    _recent_recovery_locations = _recent_recovery_locations.slice(-max_recovery_locations - 1, -1);

  if _recent_stable_recovery_locations.size() > max_stable_recovery_locations:
    _recent_stable_recovery_locations = _recent_stable_recovery_locations.slice(-max_stable_recovery_locations - 1, -1);


## Returns the most recently logged Grid location, previous to the current one.
func get_last_position() -> Vector2i:
  # [TODO] This needs to return list[-2], not list[-1]: -1 is where the current location is, probably.
  return (
    _recent_locations.back() if _recent_locations.size() == 0
    # [TODO] The entity's current position would be a better value, but we don't have a
    #     reference to such here.
    else Vector2i.ZERO
  );


## Returns the list of most-recently logged Grid locations. This list represents
## a strict history, so may contain duplicates.
func get_recent_positions() -> Array[Vector2i]:
  return _recent_locations;


## Returns a point on the Grid that is a viable recovery point (free of obstructions, etc.)
## that the [param entity] may warp to. [br]
##
## Recovery points are chosen by recency. The most recently inhabited place that
## is also presently occupiable is chosen. If none can be found, defaults to the saved
## respawn point usually reserved for save spots.
func get_recover_point(entity: GridEntity) -> Vector2i:
  # Check recent positions for a safe recovery point.
  for place in _recent_recovery_locations:
    if ActionUtils.place_is_idleable(place, entity):
      return place;

  # Check recent safe tiles, which may reach farther back in play time, for a
  # safe recovery point.
  for place in _recent_stable_recovery_locations:
    if ActionUtils.place_is_idleable(place, entity):
      return place;

  # Default to the save point or some equivalent failing all else.
  return _respawn_point;


## Returns the saved respawn point.
# [TODO] Or a place close to it. Or maybe obstructions near your save point just get demolished.
func get_respawn_point() -> Vector2i:
  return _respawn_point;
