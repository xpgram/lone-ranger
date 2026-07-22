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

  if args[0] == 'spawn':
    args.pop_front();
    return _cmd_give_spawn_object(args);

  var consumables := {} as Dictionary[String, FieldAction];
  consumables.merge(FieldActionList.all_magic);
  consumables.merge(FieldActionList.all_items);

  var item_name := args[0];
  var quantity: int = 1 if args.size() == 1 else type_convert(args[1], TYPE_INT);

  if PlayerEquipment.all_artefacts.has(item_name):
    var artefact: StringName = PlayerEquipment.all_artefacts.get(item_name);
    DebugEvents.give_player_equipment.emit(artefact);

  elif PlayerEquipment.all_collectibles.has(item_name):
    var collectible: StringName = PlayerEquipment.all_collectibles.get(item_name);
    for i in range(quantity):
      DebugEvents.give_player_equipment.emit(collectible);

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

  var consumables := (
    FieldActionList.all_magic.values()
    + FieldActionList.all_items.values()
  );

  for artefact in PlayerEquipment.all_artefacts.values():
    DebugEvents.give_player_equipment.emit(artefact);

  for action in consumables:
    var item := PlayerInventoryItem.new();
    item.action = action;
    item.quantity = quantity_for_each;
    DebugEvents.give_player_inventory_item.emit(item);

  return DebugCLI.Error.OK;


## A program to give the player developer spells to spawn objects and monsters
## in the play area. Useful for live-testing object configurations and interplay.
func _cmd_give_spawn_object(args: Array[String]) -> DebugCLI.Error:
  if args.size() == 0:
    return DebugCLI.Error.COULD_NOT_PROCESS_LINE;

  var _spawn_object_resource := load('uid://brrderc3o5ct0');
  var quantity: int = type_convert(args[1], TYPE_INT) if args.size() >= 2 else 1;
  var target_name := args[0];

  for object_name in GridObjectsDict.all_object_uids.keys():
    if object_name != target_name:
      continue;

    var object_uid := GridObjectsDict.all_object_uids[object_name];

    var spell := _spawn_object_resource.duplicate();
    spell.action_name = "S.%s" % object_name.capitalize();
    spell.action_uid = spell.action_name;
    spell.action_type = Enums.FieldActionType.Magic;
    spell.action_time_cost = 0;
    spell.object_scene = load(object_uid);

    var item := PlayerInventoryItem.new();
    item.action = spell;
    item.quantity = quantity;
    DebugEvents.give_player_inventory_item.emit(item);

  return DebugCLI.Error.OK;
