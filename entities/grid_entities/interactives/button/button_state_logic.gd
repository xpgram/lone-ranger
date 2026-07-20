
class_name ButtonStateLogic
extends Resource


## Emitted when this button logic is activated or 'powered on'.
signal activated();

## Emitted when this button logic is deactivated or 'powered off'.
signal deactivated();


## Whether this button logic is currently 'on'.
## Setting this value will immediately notify listeners of its state change. [br]
##
## If [member _stays_activated] is `true`, this value cannot be set to `false`
## after it has been set to `true`.
@export var is_activated := false:
  set(value):
    var old_value := is_activated;
    is_activated = value;

    if (
        old_value == is_activated
        or is_activated and _stays_activated
    ):
      return;

    var signal_to_emit := activated if is_activated else deactivated;

    signal_to_emit.emit();
    _notify_powerable_targets();
    _update_persistence_key();

## Whether this button logic can deactivate after being activated.
@export var _stays_activated := false;

## @nullable [br]
## The [PersistenceKeyBool] object to set along with this button logic's
## [member is_activated] state. If this object is null, no persistence key is set.
@export var _persistence_key: PersistenceKeyBool;

## A list of [Node]s that own a [PowerableComponent] to toggle in accordance
## with this button logic's [member is_activated] state. [br]
##
## [Resource] objects cannot have fields that contain [Node] references, so this
## must be set by the resource-owner.
var _powerable_targets := [] as Array[Node];


## Sets the list of target [Node]s to toggle in accordance with this button
## logic's [member is_activated] state. All referenced [Node]s must own a
## [PowerableComponent] to be correctly notified.
func set_powerable_targets(targets: Array[Node]) -> void:
  _powerable_targets = targets;


## Updates the powered state of all [PowerableComponent]s found in this button
## logic's list of [member _powerable_targets] to match this object's
## [member is_activated] state.
func _notify_powerable_targets() -> void:
  if not _powerable_targets:
    return;

  for target in _powerable_targets:
    var powerable := Component.getc(target, PowerableComponent) as PowerableComponent;
    if powerable:
      powerable.powered = is_activated;


## Updates the state of the [member _persistence_key] associated with this
## button logic to match its [member is_activated] state.
func _update_persistence_key() -> void:
  if not _persistence_key:
    return;

  _persistence_key.write(is_activated);
