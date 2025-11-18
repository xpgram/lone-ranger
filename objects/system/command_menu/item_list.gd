extends ItemList


## Whether the cursor position is remembered the next time this menu is opened after
## closing it.
@export var remember_cursor_position := false;

@onready var menu_cursor := %MenuCursor;


func _ready() -> void:
  item_selected.connect(_move_cursor_to_item);

  # Default to the first option.
  # FIXME Doesn't work. _ready() happens too early, I presume.
  select(0);
  item_selected.emit(0);


func open() -> void:
  show();
  if not remember_cursor_position:
    _self_select_item(0);


func close() -> void:
  hide();
  # TODO Do I need to save an index number here to remember cursor position?


func _self_select_item(index: int) -> void:
  select(index);
  item_selected.emit(index);


func _move_cursor_to_item(index: int) -> void:
  menu_cursor.position.y = get_item_rect(index).get_center().y;
