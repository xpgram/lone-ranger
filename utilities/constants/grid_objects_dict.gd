## @static [br]
## A utility script containing constants for UIDs to [GridObject] scenes and a
## dictionary for iterating through said objects.
class_name GridObjectsDict


# [TODO] Refactor this to search the grid_entities directory for valid objects
#   and auto-compose the dictionary of all_objects.
#   - The dictionary keys are also CLI words: should it be that these are intentional?


## A list of resource UIDs to [GridObject] scenes known to [GridObjectsDict]. [br]
##
## Note that this property is not auto-generated from the project directory, and
## is therefore not a comprehensive list. In particular, any object which has
## no function without configuration, like a button which needs a 'when pressed'
## target, is excluded from the list.
static var all_object_uids: Dictionary[String, String]:
  get():
    return {
      'boulder': boulder,
      'bull': enemy_bull,
      'diamond': enemy_diamond,
      'glass_tile': glass_tile,
      'leech': enemy_leech,
      'loose_particles': loose_particles,
      'platform_statue': platform_statue,
      'save_statue': save_statue,
      'maggot': enemy_maggot,
      'mouth': enemy_mouth,
    };
  set(value):
    pass


const boulder := 'uid://oysxdqutfm51';
const glass_tile := 'uid://6imckxwaw70b';
const loose_particles := 'uid://cqx4i6o5f7y0t';
const platform_statue := 'uid://dowqydii3t2w0';
const save_statue := 'uid://cieqoiwkjqwtb';

const enemy_bull := 'uid://bby6nr1v10a5c';
const enemy_diamond := 'uid://cokxrxu6mgxob';
const enemy_leech := 'uid://cwpfqmqnobovf';
const enemy_maggot := 'uid://v76t6hfbja7y';
const enemy_mouth := 'uid://hd6tv01qq0ed';
