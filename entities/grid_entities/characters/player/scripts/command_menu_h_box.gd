## Modifies the textbox layout depending on whether the command menu is visible.
extends HBoxContainer


## The player subsystems node.
@onready var _subsystem: PlayerSubsystemPackage = %SubsystemPackage;

## Spacer to the far-left of the hbox.
@onready var _left_spacer: Control = $LeftSpacer;

## Spacer to the far-right of the hbox.
@onready var _right_spacer: Control = $RightSpacer;

## Spacer between the text bubble and command menu.
@onready var _cmd_menu_spacer: Control = $CmdMenuSpacer;



func _ready() -> void:
  _connect_to_signals();
  _recalculate_hbox_position();


func _connect_to_signals() -> void:
  _subsystem.command_menu.visibility_changed.connect(_recalculate_hbox_position);


## Reposition the hbox according to whether the command menu is open.
func _recalculate_hbox_position() -> void:
  var cmd_menu_is_visible := _subsystem.command_menu.visible;

  _left_spacer.visible = not cmd_menu_is_visible;
  _right_spacer.visible = not cmd_menu_is_visible;

  _cmd_menu_spacer.visible = cmd_menu_is_visible;
  offset_transform_position.y = 0 if cmd_menu_is_visible else 8;
