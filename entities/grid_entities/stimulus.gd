## A collection of event-keys for the [GridEntity] stimulus reaction system.
class_name Stimulus


## When a [GridEntity] is knocked into by a kinetic force, but not enough to move it.
const bumped := &'bumped';

# TODO Add support for function signatures that accept data to GridEntity.
## When a [GridEntity] moves onto the same tile as another [GridEntity].
## [codeblock]func (entity: GridEntity) -> void; [/codeblock]
const entity_collision := &'entity_collision';

## When a [GridEntity] moves away from the same tile as another [GridEntity].
## [codeblock]func (entity: GridEntity) -> void; [/codeblock]
const entity_separation := &'entity_separation';

## When a [GridEntity] is positioned over a floor space. [br]
##
## This signal is specifically useful when a floor tile is created beneath an already
## falling entity.
const is_over_ground := &'is_over_ground';

## When a [GridEntity] is positioned over a floorless space.
const is_over_pit := &'is_over_pit';

## When a [GridEntity] is bumped directly, and not through other objects. This effect is
## typically used for bump effects that may trigger secrets or unlock secret passages.
const secret_knock := &'secret_knock';
