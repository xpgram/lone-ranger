extends GridEntity


@export var activation_trigger: TriggerBox;


func _ready() -> void:
  activation_trigger.entered.connect(_on_activation_trigger);


func _on_activation_trigger(entity: GridEntity) -> void:
  if entity is not Player2D:
    return;

  var actor_component := Component.getc(self, GridActorComponent) as GridActorComponent;

  # FIXME This method is not a property of GridActorComponent generally.
  # FIXME It's also not clear that this 'activated' property runs logic, and that's why we need the conditional.
  if not actor_component.activated:
    actor_component.activated = true;
