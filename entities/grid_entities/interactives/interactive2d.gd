## A parent class for all interactive or passive-effect Grid objects.
class_name Interactive2D
extends GridEntity


func _init() -> void:
  add_to_group(Group.Interactible);
