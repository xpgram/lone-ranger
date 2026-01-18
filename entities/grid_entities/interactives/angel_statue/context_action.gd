extends ContextAction


@export var save_idol: GridEntity;


func can_interact(actor: GridEntity) -> bool:
  var initiated_from_below := (save_idol.grid_position + Vector2i.DOWN == actor.grid_position);
  var actor_facing_self := (actor.faced_direction == Vector2i.UP);

  return initiated_from_below and actor_facing_self;


func perform_interaction_async(actor: GridEntity) -> void:
  if actor is not Player2D:
    return;

  var health_component := Component.get_component(actor, HealthComponent) as HealthComponent;
  health_component.set_hp_to_full();

  # FIXME scuffed private variable access :p
  actor._starting_position = save_idol.grid_position + Vector2i.DOWN;
