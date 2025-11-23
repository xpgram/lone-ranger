class_name PlayerInventory
extends Node


## Emitted when the list of possessed abilities is changed.
signal abilities_updated(items: Array[FieldAction]);

## Emitted when the list of possessed magics is changed.
signal magic_updated(items: Array[FieldAction]);

## Emitted when the list of possessed items is changed.
signal items_updated(items: Array[FieldAction]);


@export_group('Equipment')

## A list of special key-items that are not castable (there is no action script) and
## simply represent something the player owns. Think of these like getting the Morph Ball
## in Metroid.
@export var _equipment: Array[StringName];


@export_group('Content')

## The inventory Dictionary for ability actions.
@export var _abilities: Dictionary[StringName, FieldAction];

## The inventory Dictionary for magic actions.
@export var _magic: Dictionary[StringName, FieldAction];

## The inventory Dictionary for item actions.
@export var _items: Dictionary[StringName, FieldAction];


func _ready() -> void:
  # TODO Emit equipment?
  abilities_updated.emit(_get_sorted_array(_abilities));
  magic_updated.emit(_get_sorted_array(_magic));
  items_updated.emit(_get_sorted_array(_items));


## Adds a FieldAction to the inventory.
## If the action already exists, the action's quantity will be incremented instead.
func add(action: FieldAction) -> void:
  var dict := _get_inventory_dict(action.action_type);
  var update_signal := _get_update_signal(action.action_type);

  if dict.has(action.action_uid):
    dict[action.action_uid].uses_remaining += action.uses_remaining;
  else:
    dict[action.action_uid] = action;
  
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
func get_by_uid(action_uid: StringName) -> FieldAction:
  var found_action: FieldAction;

  if _abilities.has(action_uid):
    found_action = _abilities[action_uid];
  elif _magic.has(action_uid):
    found_action = _magic[action_uid];
  elif _items.has(action_uid):
    found_action = _items[action_uid];

  return found_action;


## Returns the number of **FieldAction** under `param action_uid` already held.
func get_quantity(action_uid: StringName) -> int:
  var action := get_by_uid(action_uid);
  return 0 if action == null else action.uses_remaining;


## Removes the **FieldAction** held under `param action_uid` from the inventory.
## If the action is not contained, does nothing.
func remove(action_uid: StringName) -> void:
  var action := get_by_uid(action_uid);

  if action == null:
    return;

  var dict := _get_inventory_dict(action.action_type);
  var update_signal := _get_update_signal(action.action_type);

  dict.erase(action_uid);
  _emit_update_signal(update_signal, dict);


## Removes a quantity from the **FieldAction** held under `param action_uid`, if it exists.
## If the quantity held falls to 0, then the action is removed from the inventory as well.
func expend(action_uid: StringName, quantity: int = 1) -> void:
  var action := get_by_uid(action_uid);

  if action == null:
    return;

  action.uses_remaining -= quantity;

  var dict := _get_inventory_dict(action.action_type);
  var update_signal := _get_update_signal(action.action_type);

  if action.uses_remaining <= 0:
    dict.erase(action_uid);

  _emit_update_signal(update_signal, dict);


## Returns the inventory dictionary associated with `param action_type`.
func _get_inventory_dict(action_type: Enums.FieldActionType) -> Dictionary[StringName, FieldAction]:
  var dict: Dictionary[StringName, FieldAction];

  match action_type:
    Enums.FieldActionType.Ability:
      dict = _abilities;
    Enums.FieldActionType.Magic:
      dict = _magic;
    Enums.FieldActionType.Item or Enums.FieldActionType.KeyItem:
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
    Enums.FieldActionType.Item or Enums.FieldActionType.KeyItem:
      update_signal = items_updated;
  
  return update_signal;


## Emits `param update_signal` with a sorted inventory array derived from `param dict`.
func _emit_update_signal(update_signal: Signal, dict: Dictionary[StringName, FieldAction]) -> void:
  update_signal.emit(_get_sorted_array(dict));


## Builds and returns a sorted inventory array from `param dict`.
func _get_sorted_array(dict: Dictionary[StringName, FieldAction]) -> Array[FieldAction]:
  var actions := dict.values();

  actions.sort_custom(func (a: FieldAction, b: FieldAction):
    if a.command_menu_sort_priority != b.command_menu_sort_priority:
      return a.command_menu_sort_priority < b.command_menu_sort_priority;

    elif a.command_menu_sort_sub_priority != b.command_menu_sort_sub_priority:
      return a.command_menu_sort_sub_priority < b.command_menu_sort_sub_priority;

    else:
      return a.action_name < b.action_name;
  );

  return actions;
