## @tool [br]
##
## A [BaseComponent] to manage an entity's HP value. This component emits signals when its
## values change, which is the preferred method of checking the HP state.
@tool
class_name HealthComponent
extends BaseComponent


@export var meter: IntMeter;


func _ready() -> void:
  # FIXME All enemies share the same IntMeter resource, so they all die together, lmao.
  #  This might be a good case for IntMeter being a Node. It just seemed annoying to implement that.
  #  IntMeter's simple purpose has grown pretty extravagant anyway, so eh.
  #  It's either that, or we let HealthComponent extend IntMeter extend BaseComponent, which...
  #  I guess would be fine? It would require the fewest changes.
  meter = meter.duplicate();

  # TODO Consider making IntMeter the component instead of a resource of the component.
