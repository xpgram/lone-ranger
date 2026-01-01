## Base class for all enemy types.
class_name Enemy2D
extends GridEntity


func _init() -> void:
  add_to_group(Group.Enemy);


func _ready() -> void:
  _bind_health_listeners();


## Binds signal listeners to signals.
func _bind_health_listeners() -> void:
  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  if health_component:
    health_component.meter.empty.connect(_on_health_empty);


## Handler for when the [Enemy2D]'s HP meter (if it has one) drops to zero.
func _on_health_empty() -> void:
  queue_free();
