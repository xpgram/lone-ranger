## A collection of event-keys for the [GridEntity] stimulus reaction system.
class_name Stimulus


## When a [GridEntity] is knocked into by a kinetic force, but not enough to move it.
const bumped := &'bumped';

## When a [GridEntity] is positioned over a floor space. [br]
##
## This signal is specifically useful when a floor tile is created beneath an already
## falling entity.
const is_over_ground := &'is_over_ground';

## When a [GridEntity] is positioned over a floorless space.
const is_over_pit := &'is_over_pit';
