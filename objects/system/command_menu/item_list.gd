class_name CommandMenuItemList
extends ItemList


##
signal item_chosen(item: Variant);


## Whether the cursor position is remembered the next time this menu is opened after
## closing it.
@export var remember_cursor_position := false;


##
var page_size := 6;

##
## A list of unknown type, though only FieldActions and ItemListItems are assemblable into list items.
var _menu_content: Array;

##
var _num_pages: int:
  get():
    return ceil(_menu_content.size() / float(page_size));

##
var _cursor_memories: Array[SubmenuMemory] = [ SubmenuMemory.new() ];

## 
var _cursor_memory := _cursor_memories[0];


## 
@onready var _menu_cursor_sprite := %MenuCursor;


func _ready() -> void:
  _disable_tooltips_for_all_items();
  draw.connect(_on_draw_call);


## 
func resize_cursor_memory(size: int) -> void:
  var old_size := _cursor_memories.size();
  _cursor_memories.resize(size);
  
  # Fill empty slots with new memory structs.
  for i in range(old_size, size):
    _cursor_memories.append(SubmenuMemory.new());


## 
## Will throw an error if index is out of range.
func set_memory_index(index: int) -> void:
  _cursor_memory = _cursor_memories[index];


##
func set_content(content: Array) -> void:
  _menu_content = content;
  # TODO Set active page using get_current_page() which clamps the value


## 
func open() -> void:
  show();
  grab_focus();

  if remember_cursor_position:
    _self_select_item(_cursor_memory.cursor_index);
  else:
    _self_select_item(0);


## 
func close() -> void:
  _cursor_memory.cursor_index = get_current_selection_index();
  # TODO Save current page
  hide();


##
func get_current_page() -> int:
  return clampi(_cursor_memory.page_index, 0, _num_pages);


## Gets the index for the currently selected menu option.
func get_current_selection_index() -> int:
  var selected_items := get_selected_items();
  var selected_index := 0 if selected_items.size() == 0 else selected_items[0];
  selected_index += page_size * get_current_page();
  selected_index = clampi(selected_index, 0, _menu_content.size());
  return selected_index;


## Sets all list item tooltips to disabled.
func _disable_tooltips_for_all_items() -> void:
  for i in range(item_count):
    set_item_tooltip_enabled(i, false);


## Set the selection cursor position and emit associated triggers.
func _self_select_item(index: int) -> void:
  select(index);
  item_selected.emit(index);


## Handler for draw call events.
func _on_draw_call() -> void:
  _move_cursor_to_item(get_current_selection_index());


## Moves the menu cursor graphic to the list-item at `param index`.
func _move_cursor_to_item(index: int) -> void:
  _menu_cursor_sprite.position.y = get_item_rect(index).get_center().y;


## A struct to save state information about some variant of this options list.
class SubmenuMemory:
  var cursor_index := 0;
  var page_index := 0;
