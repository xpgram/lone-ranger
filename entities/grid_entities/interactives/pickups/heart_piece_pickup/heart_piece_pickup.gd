class_name HeartPiecePickup
extends PickupInteractive2D


func _on_collide(entity: GridEntity) -> void:
  if entity is not Player2D:
    return;
  _add_heart_piece_to_player(entity);
  queue_free();


func _add_heart_piece_to_player(player: Player2D) -> void:
  # FIXME This is scuffed as hell, and should not be here. (borrowed from open_chest.gd)
  player.inventory.add_equipment('heart_piece');

  var total_heart_pieces: float = player.inventory._equipment \
    .filter(func (equipment): return equipment == 'heart_piece') \
    .size();
  # 2 HP is 1 heart container, but half containers are not allowed. Also, base is 2 containers.
  var num_heart_containers := int(total_heart_pieces / 2) * 2 + 4;

  var health := Component.getc(player, HealthComponent) as HealthComponent;
  health.maximum = num_heart_containers;

  print('%s obtained %s heart pieces!' % [player.name, 1]);
