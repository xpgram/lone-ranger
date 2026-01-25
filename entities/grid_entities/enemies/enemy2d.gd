## Base class for all enemy types.
class_name Enemy2D
extends GridEntity


func _init() -> void:
  add_to_group(Group.Enemy);


func _ready() -> void:
  super._ready();
  _bind_health_listeners();


func _exit_tree() -> void:
  super._exit_tree();


## Binds signal listeners to signals.
func _bind_health_listeners() -> void:
  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  if health_component:
    health_component.empty.connect(_on_health_empty);


## Handler for when the [Enemy2D]'s HP meter (if it has one) drops to zero. [br]
##
## If overriding, note that this function normally calls [code]queue_free()[/code].
func _on_health_empty() -> void:
  _disable_actor_component();
  queue_free();


func _on_free_fall() -> void:
  _disable_actor_component();
  super._on_free_fall();


## Tells the actor component to refuse all behavior requests.
func _disable_actor_component() -> void:
  var actor_component := Component.get_component(self, GridActorComponent) as GridActorComponent;
  if actor_component:
    actor_component.disable();
