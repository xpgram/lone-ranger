## @static [br]
## A utility script containing string keys for player equipment.
class_name PlayerEquipment


# [TODO] At a time when equipment needs associated sprites, descriptions, etc.,
#   this script will need to be revamped to yield Resources instead of strings.
# [TODO] Should I merge this script with FieldActionList? Since they follow the
#   same pattern.


## All power-granting artefacts that enable player abilities.
static var all_artefacts: Dictionary[String, StringName]:
  get():
    return {
      'shove': shove,
      'wings': wings,
      'sword': sword,
      'hookshot': hookshot,
    };
  set(value):
    pass

## Allows the player to push more objects at once.
const shove := &'shove';

## Allows the player to float over 1 pit.
const wings := &'wings';

## Allows the player to attack adjacent enemies.
const sword := &'sword';

## Allows the player to pull themselves to nearby hitchable objects.
const hookshot := &'hookshot';


## All collectible pieces that bolster stats, are tradeable, or have some
## other purpose.
static var all_collectibles: Dictionary[String, StringName]:
  get():
    return {
      'heart_piece': heart_piece,
    };
  set(value):
    pass

## A chunk of a heart container. A full heart container adds 1 additional health heart to
## the player's maximum HP.
const heart_piece := &'heart_piece';
