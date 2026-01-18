class_name DiggableSpotEntity
extends GridEntity


func _on_spell_activated__raise() -> void:
  # TODO Create an item pickup.
  queue_free();
