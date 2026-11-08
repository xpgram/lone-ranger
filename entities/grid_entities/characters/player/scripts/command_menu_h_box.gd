## Modifies the textbox layout depending on whether the command menu is visible.
extends HBoxContainer


## Reference to the command menu.
@onready var _command_menu: CommandMenu = %CommandMenu;

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
  _command_menu.visibility_changed.connect(_recalculate_hbox_position);


## Reposition the hbox according to whether the command menu is open.
func _recalculate_hbox_position() -> void:
  _left_spacer.visible = not _command_menu.visible;
  _right_spacer.visible = not _command_menu.visible;

  _cmd_menu_spacer.visible = _command_menu.visible;
  offset_transform_position.y = 0 if _command_menu.visible else 8;
