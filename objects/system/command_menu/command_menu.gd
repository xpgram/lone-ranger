extends Node2D


@export var ui_container: Control;
@export var lists: Array[ItemList];

var active_index := 0;


func _ready() -> void:
  ui_container.hide();


func _process(_delta: float) -> void:
  
  if Input.is_action_just_pressed('open_action_menu'):
    if not ui_container.visible:
      ui_container.show();
      _open_submenu(0);
    else:
      active_index = 0;
      ui_container.hide();
  
  elif Input.is_action_just_pressed('interact') and _is_open():
    if active_index == 0:
      active_index = _get_current_submenu_selection_index() + 1;
      active_index = clamp(active_index, 0, lists.size());
      _open_submenu(active_index);
    else:
      active_index = 0;
      ui_container.hide();

  elif Input.is_action_just_pressed('cancel'):
    if active_index != 0:
      active_index = 0;
      _open_submenu(active_index);
    else:
      ui_container.hide();


func _is_open() -> bool:
  return ui_container.visible;


func _open_submenu(index: int) -> void:
  for list in lists:
    list.close();
  
  var open_list := lists[index];
  open_list.open();


func _get_current_submenu_selection_index() -> int:
  var submenu := lists[active_index];
  return submenu.get_selected_items()[0];
