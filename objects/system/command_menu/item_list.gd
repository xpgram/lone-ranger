class_name CommandMenuItemList
extends ItemList


## Whether the cursor position is remembered the next time this menu is opened after
## closing it.
@export var remember_cursor_position := false;


##
var cursor_memories: Array[SubmenuMemory] = [ SubmenuMemory.new() ];

## 
var cursor_memory := cursor_memories[0];


## 
@onready var menu_cursor_sprite := %MenuCursor;


func _ready() -> void:
  _disable_tooltips_for_all_items();
  draw.connect(_on_draw_call);


## 
func resize_cursor_memory(size: int) -> void:
  var old_size := cursor_memories.size();
  cursor_memories.resize(size);
  
  # Fill empty slots with new memory structs.
  for i in range(old_size, size):
    cursor_memories.append(SubmenuMemory.new());


## 
## Will throw an error if index is out of range.
func set_memory_index(index: int) -> void:
  cursor_memory = cursor_memories[index];


## 
func open() -> void:
  show();
  grab_focus();

  if remember_cursor_position:
    _self_select_item(cursor_memory.cursor_index);
  else:
    _self_select_item(0);


## 
func close() -> void:
  cursor_memory.cursor_index = get_current_selection_index();
  # TODO Save current page
  hide();


## 
func get_current_selection_index() -> int:
  var selected_items := get_selected_items();
  # TODO Account for pages
  return (
    0 if selected_items.size() == 0
    else selected_items[0]
  );


## 
func _disable_tooltips_for_all_items() -> void:
  for i in range(item_count):
    set_item_tooltip_enabled(i, false);


## 
func _self_select_item(index: int) -> void:
  select(index);
  item_selected.emit(index);


## 
func _on_draw_call() -> void:
  _move_cursor_to_item(get_current_selection_index());


## 
func _move_cursor_to_item(index: int) -> void:
  menu_cursor_sprite.position.y = get_item_rect(index).get_center().y;


## 
class SubmenuMemory:
  var cursor_index := 0;
  var page_index := 0;
