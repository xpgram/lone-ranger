## @tool [br]
##
##
@tool
class_name HealthComponent
extends BaseComponent


@export var meter: IntMeter;


func _ready() -> void:
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
