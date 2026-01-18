@warning_ignore('missing_tool')
extends GridActorComponent


var activated := false:
  set(value):
    activated = value;

    if activated:
      _on_activated();


func act_async() -> void:
  if not activated:
    return;
  # Check the hurt triggers for the player:
  #   hurt the player, do nothing
  # if no player:
  #   clear all boulders from the hurt triggers
  #   advance forward one tile
  #   set wall tiles in new locations
  #   set floor tiles in old locations
  pass


func _on_activated() -> void:
  # create walls
  pass


## Performs an attack against the global [Player2D] entity.
func _attack_async() -> void:
  # IMPLEMENT Animations of any kind.
  # FIXME Shouldn't this accept an entity parameter and not grab the global player?
  var player := ActionUtils.get_player_entity();
  var health_component := Component.get_component(player, HealthComponent) as HealthComponent;
  health_component.value -= 1;
