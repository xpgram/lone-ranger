## Manages a pop-up UI CommandMenu.
##
## This menu maintains a simple construction. It is only 2-layers deep, and only contains
## a few second layer options for different kinds of player actions.
##
## It must listen to a **PlayerInventory** node for updates to content.
class_name CommandMenu
extends Control


## Emitted when the player selects a **FieldAction** option.
signal action_selected(action: FieldAction);

## Emitted when the Command Menu system is closed.
signal closed();


enum Submenu {
  Main,
  Abilities,
  Magic,
  Items,
}


const MAIN_LIST_OPTIONS = [
  {
    'name': 'Skills',
    'icon': preload('res://textures/system/icon-skill.png'),
    'link_to': Submenu.Abilities,
  },
  {
    'name': 'Magic',
    'icon': preload('res://textures/system/icon-magic.png'),
    'link_to': Submenu.Magic,
  },
  {
    'name': 'Items',
    'icon': preload('res://textures/system/icon-items.png'),
    'link_to': Submenu.Items,
  },
];


## The _inventory to poll for contents when updating the menu content.
@export var _inventory: PlayerInventory;

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
  _configure_item_lists();

  close();


func _unhandled_input(event: InputEvent) -> void:
  if not InputFocus.has_branch_focus(self):
    return;

  # If the action menu is open (it is), then allow players to close it.
  if event.is_action_pressed('open_action_menu'):
    close();
    accept_event();


## Opens the menu in whatever state it was in when it was closed.
func open() -> void:
  visible = true;

  if active_menu == Submenu.Main:
    _switch_to_main_list();
  else:
    _switch_to_options_list(active_menu);


## Opens the menu after resetting the active menu to main.
func open_from_start() -> void:
  active_menu = Submenu.Main;
  open();


## Closes the menu and releases input focus.
func close() -> void:
  # Setting visibility here implicitly releases focus on children.
  visible = false;
  closed.emit();


## Bind listeners to inventory signals.
func _connect_to_inventory() -> void:
  _inventory.abilities_updated.connect(func (items): _update_submenu_content(_abilities_submenu_content, items));
  _inventory.magic_updated.connect(func (items): _update_submenu_content(_magic_submenu_content, items));
  _inventory.items_updated.connect(func (items): _update_submenu_content(_items_submenu_content, items));

  _inventory.emit_full_inventory();


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

  _main_list.item_chosen.connect(func (item): _switch_to_options_list(item['link_to']));
  _main_list.go_back.connect(func (): close());

  _options_list.item_chosen.connect(func (item: FieldAction): action_selected.emit(item));
  _options_list.go_back.connect(func (): _switch_to_main_list());


## Configure child ItemList nodes.
func _configure_item_lists() -> void:
  # TODO Set main_list content should include only options that have submenu content.
  _main_list.set_content(MAIN_LIST_OPTIONS, 0);
  _options_list.resize_cursor_memory(Submenu.size());


##
func _update_main_list_options() -> void:
  # Tell MainList which options are hidden (by their submenu content > 0)
  #   I'm not sure how to hide them, yet. It may have to be with some complicated adding/removing.
  #   Also... once a menu is shown once, do I really want to hide it again, even if it's empty? I should think on that.
  pass


## Switch the command menu context to its home menu.
func _switch_to_main_list() -> void:
  _update_main_list_options();
  active_menu = Submenu.Main;

  _options_list.close();
  _main_list.open();


## Switch the command menu context to a submenu of [FieldAction]s.
func _switch_to_options_list(submenu: Submenu) -> void:
  var options_content_switch := {
    Submenu.Abilities: _abilities_submenu_content,
    Submenu.Magic: _magic_submenu_content,
    Submenu.Items: _items_submenu_content,
  };

  # Quit early if submenu is not found in the dictionary of menu contents.
  if not options_content_switch.has(submenu):
    return;

  _options_list.set_content(options_content_switch[submenu], submenu);
  active_menu = submenu;

  _main_list.close();
  _options_list.open();
