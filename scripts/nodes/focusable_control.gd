## A node for capturing input focus.
## Useful for plugging regular [Node]s into the input focus system.
##
## I recognize this may be an abuse of Godot's UI focus system, but eh~, I'm experimenting.
class_name FocusableControl
extends Control


func _init() -> void:
  focus_mode = Control.FOCUS_ALL;


## Returns true if this [Control] node or one of its children has input focus. [br]
##
## In combination with [method accept_input], this is an effective means of letting input
## events bubble up the scene tree, but only from focused child to parent.
func has_branch_focus() -> bool:
  return InputFocus.has_branch_focus(self);
