## A parent class for all interactive or passive-effect Grid objects.
class_name Interactive2D
extends GridEntity


func _init() -> void:
  add_to_group(Group.Interactible);


## @override [br]
## By default, interactibles do not fall into the void.
func _on_free_fall() -> void:
  # [FIXME] Is it better to have this be a toggleable option via GridEntity?
  #   The problem is that overriding this method completely circumvents such a toggle.
  #   Unless the Grid singleton does the pre-signal checking?
  pass;
