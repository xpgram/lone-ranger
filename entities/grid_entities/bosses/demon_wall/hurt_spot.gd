extends GridEntity



func _ready() -> void:
  super._ready();
  entity_moved.connect(_on_entity_moved);


func _on_entity_moved() -> void:
  var entities := Grid.get_entities(grid_position);

  # for entity in entities:
  #   if entity is Player2D:
  #     _attack_async();


func _on_free_fall() -> void:
  pass;


## Performs an attack against the global [Player2D] entity.
func _attack_async() -> void:
  # IMPLEMENT Animations of any kind.
  # FIXME Shouldn't this accept an entity parameter and not grab the global player?
  var player := ActionUtils.get_player_entity();
  var health_component := Component.get_component(player, HealthComponent) as HealthComponent;
  health_component.value -= 1;
