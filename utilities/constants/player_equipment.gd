## @static [br]
## A utility script containing string keys for player equipment.
class_name PlayerEquipment


# [FIXME] We can convert this to an enum.
#   Enums show their proper names in the editor pretty consistently now.
#   And they're iterable like Dictionaries——apparently because they are dictionaries.
#   We'll probably move this to Enums.gd
# [TODO] At some point, the equipment inventory will be revamped. Uh... I guess this script
#  could still exist, though. It would yield Resources like FieldActionList does.


## A chunk of a heart container. A full heart container adds 1 additional health heart to
## the player's maximum HP.
const heart_piece := &'heart_piece';


## Allows the player to push more objects at once.
const shove := &'shove';

## Allows the player to float over 1 pit.
const wings := &'wings';

## Allows the player to attack adjacent enemies.
const sword := &'sword';

## Allows the player to pull themselves to nearby hitchable objects.
const hookshot := &'hookshot';
