## Manages a pop-up UI CommandMenu.
##
## This menu maintains a simple construction. It is only 2-layers deep, and only contains
## a few second layer options for different kinds of player actions.
##
## It must listen to a **PlayerInventory** node for updates to content.
class_name CommandMenu
extends Control

# TODO Rename script to command_menu.gd after the other script is deleted.


## Emitted when the player selects a **FieldAction** option.
signal action_selected(action: FieldAction);


enum Submenu {
  Main,
  Abilities,
  Magic,
  Items,
}


## The _inventory to poll for contents when updating the menu content.
@export var _inventory: PlayerInventory;

## The backdrop panel to the items list. This is resized according to the size needs of
## the submenu being shown.
@export var _back_panel: Control;

## The list of selectable second-layer menus. This list is used to choose which other
## menus to navigate to.
@export var _main_list: CommandMenuItemList;

## The list of selectable options in a second-layer menu. This list is populated with
## content from the player _inventory.
@export var _options_list: CommandMenuItemList;


## Which submenu of the CommandMenu is being shown.
var active_menu := Submenu.Main;

## Which page of the submenu is being shown.
var active_page := 0;

## The list options for the Abilities submenu.
var _abilities_submenu_content: Array[FieldAction];

## The list options for the Magic submenu.
var _magic_submenu_content: Array[FieldAction];

## The list options for the Items submenu.
var _items_submenu_content: Array[FieldAction];


func _ready() -> void:
  _connect_to_inventory();
  _connect_to_item_lists();
  _configure_options_list();


func _unhandled_input(event: InputEvent) -> void:
  # This can capture any input not handled by the ItemList children, right?
  # If so, listen for 'open_action_menu' and call close().
  pass


## Opens the menu in whatever state it was in when it was closed.
func open() -> void:
  visible = true;
  # update options_list content, just in case?
  # update main_list content, just in case?
  # submenu.grab_focus(), but they'll need a custom method for that to utelize their memory.


## Opens the menu after resetting the active menu to main.
func open_from_start() -> void:
  active_menu = Submenu.Main;
  open();


## Closes the menu and releases input focus.
func close() -> void:
  visible = false;
  release_focus(); # TODO Does this work recursively?


## 
func _connect_to_inventory() -> void:
  _inventory.abilities_updated.connect(func (items): _update_submenu_content(_abilities_submenu_content, items));
  _inventory.magic_updated.connect(func (items): _update_submenu_content(_magic_submenu_content, items));
  _inventory.items_updated.connect(func (items): _update_submenu_content(_items_submenu_content, items));


##
func _update_submenu_content(submenu_list: Array[FieldAction], items: Array[FieldAction]) -> void:
  submenu_list.assign(items);
  _update_main_list_options();


##
func _connect_to_item_lists() -> void:
  # Listen to ItemList signals.
  #   Main -> switch to Options
  #   Main (cancel) -> close()
  #   Options -> emit action_selected  # TODO I think I can give ItemList a custom signal, here
  #   Options (cancel) -> switch to Main
  pass


## 
func _configure_options_list() -> void:
  _options_list.resize_cursor_memory(Submenu.size());
  _options_list.set_memory_index(Submenu.Main);


##
func _update_main_list_options() -> void:
  # Tell MainList which options are hidden (by their submenu content > 0)
  #   I'm not sure how to hide them, yet. It may have to be with some complicated adding/removing.
  #   Also... once a menu is shown once, do I really want to hide it again, even if it's empty? I should think on that.
  pass


##
func _switch_to_main_list() -> void:
  _update_main_list_options();
  active_menu = Submenu.Main;
  _options_list.hide(); # TODO Are these the right method calls?
  _main_list.show();


##
func _switch_to_options_list(submenu: Submenu) -> void:
  # repopulate options_list by active_menu
  _main_list.hide();  # TODO Are these the right method calls?
  _options_list.show();


## 
func _populate_options_list(actions: Array[FieldAction], menu: Submenu) -> void:
  _options_list.clear();

  # TODO actions is assumed to be the entire list; ItemList will handle paging.
  for action in actions:
    _options_list.add_item(action.action_name, action.small_icon);

  _options_list.switch_memory(menu); # TODO Write this method
