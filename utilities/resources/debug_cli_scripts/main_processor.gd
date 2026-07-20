## The main [DebugCLI] processor for this project.
class_name LoneRangerCLIProcessor
extends DebugCLIScript

# [TODO] Add more debug commands.
# [ ] give spawn_mouth -> "S.Mouth" spawn_enemy<Mouth>
#     give spawn mouth -> "S.Mouth" spawn_object<Mouth>
#   spawn_object is a special spell-action only available to devs via the
#   command-line.
#   The spell itself is contained within the special dictionary, and the object
#   to spawn in its own dictionary; the command duplicates the spell and adds
#   the object to its `creation_target: GridObject` field, which makes the CLI
#   command dynamic and somewhat auto-generated.
#   Spawning just does a simple check that the object can be spawned in
#   unobstructed space.


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
