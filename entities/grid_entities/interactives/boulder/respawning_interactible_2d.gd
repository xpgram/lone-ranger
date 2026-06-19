class_name RespawningInteractive2D
extends Interactive2D

# [FIXME] This is a patch-fix for boulder objects which needed this "respawn after
# board reset events" feature.
#
# I think the fix we actually need are puzzle-related persistence keys.
# A puzzle setup either spawns normally or spawns pre-finished depending on
# whether something has happened (key = true), and a board reset simply
# triggers one of these checks.
#
# For how to save 'starting' and 'finished' puzzle states, uh, yeah that seems
# hard, so we should just use .tscn's.
#
# A container node called PersistenceKeySwitch or something has these properties:
#   key: string
#   false set: .tscn | none
#   true set: .tscn | none
# If either 'false' or 'true' are none, they just won't spawn.
# Also, ... it doesn't have to be a tscn, does it? It could be a node in the tree.
# It _should_ be a node in the tree, in a lot of cases; puzzles would be hard to
# quickly adjust in the scene if I had to open their individual scene to do it.
#
# So, the true and false buckets... need to be disincluded from the game loop.
# They take up memory at most. I guess they have to take up memory, huh.
# But anyway, whichever one spawns, it gets copy-instantiated from the inactive
# branch. Hm. Okay, yeah. That works.
#
# Mentioning for completion's sake: the copy-spawned stuff either goes in its own
# 'active set' container, or the references to each object get saved, so they can
# be handily deleted later.
#
# Let's call the persistence key version a PersistenceKeySpawner. Then, we can
# use a Spawner with only one branch, the 'saved set', to respawn enemies and
# puzzle elements the same way but without the persistence check.


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
