## A ledger class for keeping track of recent Grid locations.
class_name GridPositionLedger
extends RefCounted


const MAX_RECENT_POSITIONS := 16;

const MAX_RECENT_STURDY_POSITIONS := 5;


## On death, where an entity may respawn.
var _respawn_point := Vector2i.ZERO;

## A list of recently inhabited Grid locations.
var _recent_positions := [] as Array[Vector2i];

## A list of recently inhabited, stable-flooring Grid locations. This excludes
## unstable tiles like breakable-glass flooring.
var _recent_sturdy_positions := [] as Array[Vector2i];


## Sets the respawn point, usually reserved for Save Idols.
func set_respawn_point(place: Vector2i) -> void:
  _respawn_point = place;


## Logs a [param place] on the Grid in the list of recent locations. If the
## given [param place] is not a viable recovery point for [param entity], then
## it will be ignored.
func log_position(place: Vector2i, entity: GridEntity) -> void:
  if not ActionUtils.place_is_standable(place):
    return;

  _recent_positions.erase(place);
  _recent_positions.append(place);

  if ActionUtils.place_is_idleable_and_sturdy(place, entity):
    _recent_sturdy_positions.erase(place);
    _recent_sturdy_positions.append(place);

  # [TODO] Make sure [-MAX - 1] is the correct math. -1 for end as well, I guess.
  # [TODO] Factor out to a helper function?
  if _recent_positions.size() > MAX_RECENT_POSITIONS:
    _recent_positions = _recent_positions.slice(-MAX_RECENT_POSITIONS - 1, -1);

  if _recent_sturdy_positions.size() > MAX_RECENT_STURDY_POSITIONS:
    _recent_sturdy_positions = _recent_sturdy_positions.slice(-MAX_RECENT_STURDY_POSITIONS - 1, -1);


## Returns a point on the Grid that is a viable recovery point (free of obstructions, etc.)
## that the [param entity] may warp to. [br]
##
## Recovery points are chosen by recency. The most recently inhabited place that
## is also presently occupiable is chosen. If none can be found, defaults to the saved
## respawn point usually reserved for save spots.
func get_recover_point(entity: GridEntity) -> Vector2i:
  # Check recent positions for a safe recovery point.
  for place in _recent_positions:
    if ActionUtils.place_is_idleable(place, entity):
      return place;

  # Check recent safe tiles, which may reach farther back in play time, for a
  # safe recovery point.
  for place in _recent_sturdy_positions:
    if ActionUtils.place_is_idleable(place, entity):
      return place;

  # Default to the save point or some equivalent failing all else.
  return _respawn_point;


## Returns the saved respawn point.
# [TODO] Or a place close to it. Or maybe obstructions near your save point just get demolished.
func get_respawn_point() -> Vector2i:
  return _respawn_point;
