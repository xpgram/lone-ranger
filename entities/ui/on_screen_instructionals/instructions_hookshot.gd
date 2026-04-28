extends Label


var _instructions_shown := false;


func _ready() -> void:
  modulate.a = 0.0;


func _process(_delta: float) -> void:
  if _instructions_shown:
    return;

  var player := ActionUtils.get_player_entity();

  if not player.inventory.has_equipment(PlayerEquipment.hookshot):
    return;

  _instructions_shown = true;

  var alpha_tween := get_tree().create_tween();
  alpha_tween.tween_property(self, 'modulate:a', 0.0, 1.5);
  alpha_tween.tween_property(self, 'modulate:a', 1.0, 1.5);
