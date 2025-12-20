## Encapsulates data for terrain objects in a tilemap.
class_name CellTerrainData
extends Resource


## The world-geometry type for terrain objects.
enum GeometryType {
  ## Entities can fall into this type.
  Pit,
  ## Entities can traverse this type.
  Floor,
  ## Entities cannot traverse this type.
  Wall,
};


## The world-geometry type for this terrain object. [br]
## [enum GeometryType.Hole] can be fallen into. [br]
## [enum GeometryType.Floor] can be traversed. [br]
## [enum GeometryType.Wall] cannot be traversed. [br]
@export var geometry_type := GeometryType.Pit;
