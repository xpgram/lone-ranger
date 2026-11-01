## Modifies the textbox layout depending on whether the command menu is visible.
extends HBoxContainer

# [FIXME] Polish this script.

@onready var _command_menu: CommandMenu = %CommandMenu;

@onready var _left_spacer: Control = $LeftSpacer;

@onready var _right_spacer: Control = $RightSpacer;

@onready var _cmd_menu_spacer: Control = $CmdMenuSpacer;



func _ready() -> void:
  _connect_to_signals();
  _recalculate_hbox_position();


func _connect_to_signals() -> void:
  _command_menu.visibility_changed.connect(_recalculate_hbox_position);


func _recalculate_hbox_position() -> void:
  _left_spacer.visible = not _command_menu.visible;
  _right_spacer.visible = not _command_menu.visible;

  _cmd_menu_spacer.visible = _command_menu.visible;
  offset_transform_position.y = 0 if _command_menu.visible else 8;
