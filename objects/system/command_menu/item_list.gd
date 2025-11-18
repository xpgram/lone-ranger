extends ItemList


## Whether the cursor position is remembered the next time this menu is opened after
## closing it.
@export var remember_cursor_position := false;

## The last-selected item index when the menu was last seen.
var remembered_index := 0;

@onready var menu_cursor_sprite := %MenuCursor;


func _ready() -> void:
  _disable_tooltips_for_all_items();
  item_selected.connect(_move_cursor_to_item);


func open() -> void:
  print('open menu');
  show();
  grab_focus();

  if remember_cursor_position:
    _self_select_item(remembered_index);
  else:
    _self_select_item(0);


func close() -> void:
  remembered_index = _get_current_selection_index();
  hide();


func _disable_tooltips_for_all_items() -> void:
  for i in range(item_count):
    set_item_tooltip_enabled(i, false);


func _get_current_selection_index() -> int:
  var selected_items := get_selected_items();
  return (
    0 if selected_items.size() == 0
    else selected_items[0]
  );


func _self_select_item(index: int) -> void:
  # FIXME Remove. Should report 2, 23.0.
  select(2);
  item_selected.emit(index);

  select(index);
  item_selected.emit(index);


func _move_cursor_to_item(index: int) -> void:
  var nums := [
    index,
    get_item_rect(index).get_center().y,
  ];
  print('item:%s rect.center.y = %s' % nums);

  menu_cursor_sprite.position.y = get_item_rect(index).get_center().y;
