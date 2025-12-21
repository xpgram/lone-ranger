## Base class for all enemy types.
class_name Enemy2D
extends GridEntity


# TODO With the addition of BaseComponent, there doesn't seem to be anything for Enemy2D
#  (or NPC2D, or Interactive2D) to do besides add itself to a special group.
#  This doesn't seem like an inheritance problem.


func _init() -> void:
  add_to_group(Group.Enemy);
