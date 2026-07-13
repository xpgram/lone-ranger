## The main [DebugCLI] processor for this project.
class_name LoneRangerCLIProcessor
extends DebugCLIScript


var _subprograms: Dictionary[String, Callable] = {
  'give': _cmd_give,
};


func exec(args: Array[String]) -> DebugCLI.Error:
  if not _subprograms.has(args[0]):
    return DebugCLI.Error.COULD_NOT_PROCESS_LINE;

  var program: Callable = _subprograms.get(args[0]);
  args.pop_front();
  return program.call(args);


## A program to give the player things, such as equipment, magic, items,
## key-items etc.
func _cmd_give(args: Array[String]) -> DebugCLI.Error:
  if args.size() == 0:
    return DebugCLI.Error.COULD_NOT_PROCESS_LINE;

  if args[0] == 'all':
    return _cmd_give_all();

  var equipment := [
    PlayerEquipment.shove,
    PlayerEquipment.wings,
    PlayerEquipment.sword,
    PlayerEquipment.hookshot,
  ];
  var consumables := {} as Dictionary[String, FieldAction];
  consumables.merge(FieldActionList.all_magic);
  consumables.merge(FieldActionList.all_items);

  var item_name := args[0];
  var quantity: int = 1 if args.size() == 1 else type_convert(args[1], TYPE_INT);

  if item_name in equipment:
    DebugEvents.give_player_equipment.emit(item_name);

  elif item_name == 'heart_piece':
    for i in range(quantity):
      DebugEvents.give_player_equipment.emit(item_name);

  elif consumables.has(item_name):
    var item := PlayerInventoryItem.new();
    item.action = consumables.get(item_name);
    item.quantity = quantity;
    DebugEvents.give_player_inventory_item.emit(item);

  else:
    return DebugCLI.Error.COULD_NOT_PROCESS_LINE;

  return DebugCLI.Error.OK;


## A program to give the player a set of all abilities and consumables.
## Useful for testing a diverse range of inter-ability behavior.
func _cmd_give_all() -> DebugCLI.Error:
  var quantity_for_each := 8;

  var equipment := [
    PlayerEquipment.shove,
    PlayerEquipment.wings,
    PlayerEquipment.sword,
    PlayerEquipment.hookshot,
  ];
  var consumables := (
    FieldActionList.all_magic.values()
    + FieldActionList.all_items.values()
  );

  for artefact in equipment:
    DebugEvents.give_player_equipment.emit(artefact);

  for action in consumables:
    var item := PlayerInventoryItem.new();
    item.action = action;
    item.quantity = quantity_for_each;
    DebugEvents.give_player_inventory_item.emit(item);

  return DebugCLI.Error.OK;
