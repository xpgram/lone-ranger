## @tool [br]
## A component to model the Powerable interface. [br]
##
## This is useful for [GridObject]s like buttons or switches that supply power
## or otherwise activate other mechanical [Grid] nodes.
@tool
class_name PowerableComponent
extends BaseComponent


## Emitted when the object is first activated or supplied power.
signal powered_on();

## Emitted when the object is first deactivated or its power is cut.
signal powered_off();


## Whether the object is activated or power is being supplied.
@export var powered := false:
  set(value):
    var old_value := powered;
    powered = value;

    if old_value != powered:
      if powered:
        _on_powered_on();
        powered_on.emit();
      else:
        _on_powered_off();
        powered_off.emit();


## An overridable handler for [signal powered_on] events that is called before
## the signal is emitted.
func _on_powered_on() -> void:
  pass


## An overridable handler for [signal powered_off] events that is called before
## the signal is emitted.
func _on_powered_off() -> void:
  pass
