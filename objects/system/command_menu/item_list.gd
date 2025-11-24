class_name CommandMenuItemList
extends ItemList


## Emitted when an item has been activated. Contains the activated item.
signal item_chosen(item: Variant);

## Emitted when the menu wishes to close or yield focus back to some other context.
signal go_back();


## Whether the cursor position is remembered the next time this menu is opened after
## closing it.
@export var remember_cursor_position := false;


## The number of items that can be displayed per page.
var page_size := 6;

## The raw list of item data for this menu. These are not the same as the ItemList's own
## array of list-item nodes, but the data that CommandMenuItemList uses to create those
## nodes. [br]
##
## The data accepted here must have a `member name` and optionally an `member icon`, and
## may otherwise contain whatever you like. The one exception to this are [FieldAction]s,
## which are understood as-is.
var _menu_content: Array;

# TODO Is this more clear as an explicit function? This feels weird.
## The number of pages this menu's content has been sliced into.
var num_pages: int:
  get():
    return ceil(_menu_content.size() / float(page_size));

## The array of memory contexts managed by this item list.
var _memory_contexts: Array[SubmenuMemory] = [ SubmenuMemory.new() ];

## The in-use memory context for this item list.
var _memory := _memory_contexts[0];


## A reference to the cursor sprite used by this menu.
@onready var _menu_cursor_sprite := %MenuCursor;


func _ready() -> void:
  _disable_tooltips_for_all_items();
  draw.connect(_on_draw_call);


func _unhandled_input(event: InputEvent) -> void:
  if event.is_action('move_up'):
    _move_cursor(-1);

  elif event.is_action('move_down'):
    _move_cursor(1);

  elif event.is_action('move_left'):
    _move_page_cursor(-1);

  elif event.is_action('move_right'):
    _move_page_cursor(1);

  elif event.is_action('interact'):
    _emit_item_chosen();
  
  elif event.is_action('cancel'):
    _emit_go_back();


## Sets the number of different submenu memory contexts this item list should have.
func resize_cursor_memory(size: int) -> void:
  var old_size := _memory_contexts.size();
  _memory_contexts.resize(size);
  
  # Fill empty slots with new memory structs.
  for i in range(old_size, size):
    _memory_contexts.append(SubmenuMemory.new());


## Changes the menu content to [param content: Array<ListItem | FieldAction>] and updates
## the submenu memory context to [param memory_index]. [br]
##
## The "`ListItem`" described here is any object with a `member name` and optionally a
## `member icon`, and may otherwise contain whatever you like.
func set_content(content: Array, memory_index: int) -> void:
  _menu_content = content;
  _set_memory_index(memory_index);
  _change_to_page(_memory.page_index);


## Reveals this item list while grabbing input focus.
func open() -> void:
  show();
  grab_focus();

  # TODO Should this still go here? I might be treating _memory as more authoritative elsewhere.
  if remember_cursor_position:
    _self_select_item(_memory.cursor_index);
  else:
    _self_select_item(0);


## Saves this item list's current state and hides it.
func close() -> void:
  _memory.cursor_index = get_current_selection_index();
  _memory.page_index = get_current_page();
  hide();


## Returns the current page number.
func get_current_page() -> int:
  return clampi(_memory.page_index, 0, num_pages);


## Gets the index for the currently selected menu option.
func get_current_selection_index() -> int:
  # TODO Would it make sense to treat _memory.cursor_index as more authoritative?
  var selected_items := get_selected_items();
  var selected_index := 0 if selected_items.size() == 0 else selected_items[0];
  selected_index += page_size * get_current_page();
  selected_index = clampi(selected_index, 0, _menu_content.size());
  return selected_index;


## Sets all list item tooltips to disabled.
func _disable_tooltips_for_all_items() -> void:
  for i in range(item_count):
    set_item_tooltip_enabled(i, false);


## Sets the in-use Submenu memory.
## Will throw an error if [param index] is out of range.
func _set_memory_index(index: int) -> void:
  _memory = _memory_contexts[index];


## Clears and repopulates the menu with items from [param page_number].
## Tries to preserve selection cursor position.
func _change_to_page(page_number: int) -> void:
  _memory.page_index = clampi(page_number, 0, num_pages);
  var page_content := _menu_content.slice(page_number, page_number + page_size);

  clear();

  for item in page_content:
    if item is FieldAction:
      _add_field_action_item(item);
    else:
      _add_normal_item(item);

  _disable_tooltips_for_all_items();
  _self_select_item(_memory.cursor_index);


## Adds [param item] to the items list.
func _add_normal_item(item: Variant) -> void:
  # TODO Does this `item.[non-existent member]` return null or throw an error?
  var item_name: String = item.name if item.name else '';
  var item_icon: Resource = item.icon if item.icon else null;
  add_item(item_name, item_icon);


## Adds [param action] to the items list.
func _add_field_action_item(action: FieldAction) -> void:
  add_item(action.action_name, action.small_icon);


## Set the selection cursor position and emit associated triggers.
func _self_select_item(index: int) -> void:
  select(index);
  item_selected.emit(index);


## Handler for draw call events.
func _on_draw_call() -> void:
  _move_cursor_to_item(get_current_selection_index());


## Moves the menu cursor graphic to the list-item at [param index].
func _move_cursor_to_item(index: int) -> void:
  _menu_cursor_sprite.position.y = get_item_rect(index).get_center().y;


## Moves the menu_cursor up or down, relative to its current position.
## The cursor, if moved beyond a range limit, will wrap around to the other side.
func _move_cursor(direction: int) -> void:
  _memory.cursor_index += direction;
  _memory.cursor_index = _wrap_clampi(page_size, _memory.cursor_index);

  _move_cursor_to_item(_memory.cursor_index);


## Moves the page_cursor left or right, relative to its current position, then updates the
## display. The cursor, if moved beyond a range limit, will wrap around to the other side.
func _move_page_cursor(direction: int) -> void:
  _memory.page_index += direction;
  _memory.page_index = _wrap_clampi(num_pages, _memory.page_index);

  _change_to_page(_memory.page_index);


## Emits the item_chosen signal with the data of the list-item that was activated.
func _emit_item_chosen() -> void:
  var action_index := get_current_selection_index();
  item_chosen.emit(_menu_content[action_index]);


## Emits the 'go back' signal.
func _emit_go_back() -> void:
  go_back.emit();


# TODO Move to Utils autoload or something.
## Given a number [param value] assumed to be within the range `[-range, 2*range]`,
## returns a number within `[0, range]` where exceeding either limit yields a number
## relative to the other limit: like Pacman.
func _wrap_clampi(value_range: int, value: int) -> int:
  return (2 * value_range + value) % value_range;


## A struct to save state information about some variant of this options list.
class SubmenuMemory:
  var cursor_index := 0;
  var page_index := 0;
