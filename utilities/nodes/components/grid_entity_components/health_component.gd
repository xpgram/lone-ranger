## @tool [br]
##
##
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

  if Engine.is_editor_hint():
    return;
  
  _bind_signals();


##
func _bind_signals() -> void:
  meter.empty.connect(_on_empty);


##
func _on_empty() -> void:
  var component_owner := get_component_owner();

  if component_owner is GridEntity:
    # TODO Call grid_entity.die(), a function that extenders may use to play animations
    #  or do some other biz. Also configures GridEntity to not be pushable, among other
    #  things.
    component_owner.queue_free();
