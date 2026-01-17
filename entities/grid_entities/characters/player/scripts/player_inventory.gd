class_name PlayerInventory
extends Node


## Emitted when the list of possessed abilities is changed.
signal abilities_updated(items: Array[PlayerInventoryItem]);

## Emitted when the list of possessed magics is changed.
signal magic_updated(items: Array[PlayerInventoryItem]);

## Emitted when the list of possessed items is changed.
signal items_updated(items: Array[PlayerInventoryItem]);


@export_group('Equipment')

# IMPLEMENT Key items in the form of found equipment are not used by anything.
## A list of special key-items that are not castable (there is no action script) and
## simply represent something the player owns. Think of these like getting the Morph Ball
## in Metroid.
@warning_ignore('unused_private_class_variable')
@export var _equipment: Array[StringName];


@export_group('Content')

## The inventory Dictionary for ability actions.
@export var _abilities: Dictionary[StringName, PlayerInventoryItem];

## The inventory Dictionary for magic actions.
@export var _magic: Dictionary[StringName, PlayerInventoryItem];

## The inventory Dictionary for item actions.
@export var _items: Dictionary[StringName, PlayerInventoryItem];


func _ready() -> void:
  emit_full_inventory();


## Broadcasts the entire inventory contents to any nodes who might be listening.
## Useful for resyncing after a node has made connections to the Inventory's signals.
func emit_full_inventory() -> void:
  # TODO Emit equipment?
  abilities_updated.emit(_get_sorted_array(_abilities));
  magic_updated.emit(_get_sorted_array(_magic));
  items_updated.emit(_get_sorted_array(_items));


## Adds a FieldAction to the inventory.
## If the action already exists, the action's quantity will be incremented instead.
func add(action: FieldAction, count: int = 1) -> void:
  add_item(PlayerInventoryItem.new().fill(action, count));


## Adds a [PlayerInventoryItem] to the inventory.
## If the item already exists, the item's quantity will be incremented instead.
func add_item(item: PlayerInventoryItem) -> void:
  var dict := _get_inventory_dict(item.action.action_type);
  var update_signal := _get_update_signal(item.action.action_type);

  if dict.has(item.action.action_uid):
    dict[item.action.action_uid].quantity += item.quantity;
  else:
    dict[item.action.action_uid] = item;

  _emit_update_signal(update_signal, dict);


## Returns true if `param action_uid` is held somewhere in this inventory.
func has(action_uid: StringName) -> bool:
  return (
    _abilities.has(action_uid)
    or _magic.has(action_uid)
    or _items.has(action_uid)
  );


## Returns the **FieldAction** held under the key `param action_uid`.
## Returns null if the action is not contained.
func get_by_uid(action_uid: StringName) -> PlayerInventoryItem:
  var found_item: PlayerInventoryItem;

  var dicts := [
    _abilities,
    _magic,
    _items,
  ];

  for dict in dicts:
    if dict.has(action_uid):
      found_item = dict[action_uid];
      break;

  return found_item;


## Returns the number of **FieldAction** under `param action_uid` already held.
func get_quantity(action_uid: StringName) -> int:
  var item := get_by_uid(action_uid);
  return 0 if item == null else item.quantity;


## Removes the **FieldAction** held under `param action_uid` from the inventory.
## If the action is not contained, does nothing.
func remove(action_uid: StringName) -> void:
  var item := get_by_uid(action_uid);

  if item == null:
    return;

  var dict := _get_inventory_dict(item.action.action_type);
  var update_signal := _get_update_signal(item.action.action_type);

  dict.erase(action_uid);
  _emit_update_signal(update_signal, dict);


## Removes a quantity from the **FieldAction** held under `param action_uid`, if it exists.
## If the quantity held falls to 0, then the action is removed from the inventory as well.
func expend(action_uid: StringName, count: int = 1) -> void:
  var item := get_by_uid(action_uid);

  if item == null:
    return;

  item.quantity -= count;

  var dict := _get_inventory_dict(item.action.action_type);
  var update_signal := _get_update_signal(item.action.action_type);

  if item.quantity <= 0:
    dict.erase(action_uid);

  _emit_update_signal(update_signal, dict);


## Returns the inventory dictionary associated with `param action_type`.
func _get_inventory_dict(action_type: Enums.FieldActionType) -> Dictionary[StringName, PlayerInventoryItem]:
  var dict: Dictionary[StringName, PlayerInventoryItem];

  match action_type:
    Enums.FieldActionType.Ability:
      dict = _abilities;
    Enums.FieldActionType.Magic:
      dict = _magic;
    Enums.FieldActionType.Item, \
    Enums.FieldActionType.KeyItem:
      dict = _items;

  return dict;


## Returns the update Signal associated with `param action_type`.
func _get_update_signal(action_type: Enums.FieldActionType) -> Signal:
  var update_signal: Signal;

  match action_type:
    Enums.FieldActionType.Ability:
      update_signal = abilities_updated;
    Enums.FieldActionType.Magic:
      update_signal = magic_updated;
    Enums.FieldActionType.Item, \
    Enums.FieldActionType.KeyItem:
      update_signal = items_updated;

  return update_signal;


## Emits `param update_signal` with a sorted inventory array derived from `param dict`.
func _emit_update_signal(update_signal: Signal, dict: Dictionary[StringName, PlayerInventoryItem]) -> void:
  update_signal.emit(_get_sorted_array(dict));


## Builds and returns a sorted inventory array from `param dict`.
func _get_sorted_array(dict: Dictionary[StringName, PlayerInventoryItem]) -> Array[PlayerInventoryItem]:
  var actions := dict.values();

  actions.sort_custom(func (a: PlayerInventoryItem, b: PlayerInventoryItem):
    var action_a := a.action;
    var action_b := b.action;

    if action_a.command_menu_sort_priority != action_b.command_menu_sort_priority:
      return action_a.command_menu_sort_priority < action_b.command_menu_sort_priority;

    elif action_a.command_menu_sort_sub_priority != action_b.command_menu_sort_sub_priority:
      return action_a.command_menu_sort_sub_priority < action_b.command_menu_sort_sub_priority;

    else:
      return action_a.action_name < action_b.action_name;
  );

  return actions;
