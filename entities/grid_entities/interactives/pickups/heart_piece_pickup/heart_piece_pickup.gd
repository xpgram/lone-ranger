class_name HeartPiecePickup
extends PickupInteractive2D


func _on_collide(entity: GridEntity) -> void:
  if entity is not Player2D:
    return;
  _add_heart_piece_to_player(entity);
  queue_free();


func _add_heart_piece_to_player(player: Player2D) -> void:
  player.inventory.add_equipment(PlayerEquipment.heart_piece);
