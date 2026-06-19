class_name RespawningInteractive2D
extends Interactive2D

# [FIXME] This is a patch-fix for boulder objects which needed this "respawn after
# board reset events" feature.


func _on_free_fall() -> void:
  # [FIXME] Ported and modded from GridEntity
  if has_attribute('floating'):
    return;
  
  await get_tree().create_timer(0.5).timeout;

  var fall_effect := _scene_object_fall.instantiate();
  fall_effect.position = position;
  add_sibling(fall_effect);

  # queue_free();
  _deactivate();


func _on_board_reset_declared() -> void:
  super._on_board_reset_declared();
  _activate();


func _activate() -> void:
  visible = true;
  solid = true;


func _deactivate() -> void:
  visible = false;
  solid = false;
