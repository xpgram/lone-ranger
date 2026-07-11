extends GridEntity


@export var activation_trigger: TriggerBox;
@export var deactivation_trigger: TriggerBox;


func _ready() -> void:
  activation_trigger.entered.connect(_on_activation_trigger);
  deactivation_trigger.entered.connect(_on_deactivation_trigger);


func _on_activation_trigger(entity: GridEntity) -> void:
  if entity is not Player2D:
    return;
  _activate_boss();


func _on_deactivation_trigger(entity: GridEntity) -> void:
  if entity is not Player2D:
    return;
  _deactivate_boss();


func _activate_boss() -> void:
  var actor_component := Component.getc(self, GridActorComponent) as GridActorComponent;

  # [FIXME] This method is not a property of GridActorComponent generally.
  # [FIXME] It's also not clear that this 'activated' property runs logic, and that's why we need the conditional.
  if not actor_component.activated:
    actor_component.activated = true;


func _deactivate_boss() -> void:
  var actor_component := Component.getc(self, GridActorComponent) as GridActorComponent;

  # [FIXME] This method is called as a result of PREDELETE, and BooleanSpawner does
  #   some deletion as part of its scene-packing setup, so actor_component ends up
  #   being NIL somehow.
  if actor_component and actor_component.activated:
    actor_component.activated = false;
