## @static [br]
## A utility script containing string keys for spawnable grid objects.
class_name GridObjectsDict


static var all_objects: Dictionary[String, PackedScene]:
  get():
    return {
      'boulder': boulder,
    };
  set(value):
    pass


# [FIXME] Doesn't this preload via this global dictionary require that all
#   entities be loaded into memory at all times? That's probably bad, right?
#   I guess I should iterate over the ./entities directory?
#
#   I guess I could also just save the path/uid and load it at the time it's
#   requested. Meaning, this is not a Dictionary of PackedScenes.
const boulder := preload("res://entities/grid_entities/interactives/boulder/boulder.tscn");
