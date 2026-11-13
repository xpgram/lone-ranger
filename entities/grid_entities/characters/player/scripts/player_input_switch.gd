## @static [br]
## A utility class for building [FieldActionSchedule] objects from certain categories of
## player intent. [br]
##
## For example: A player may input an "Interact" intent, but this has many different
## contextual conclusions. It may mean "Read", or "Talk", or "Open Chest", or "Use Sword",
## or even "Nothing" when there are no objects to interact with. This class provides
## methods to help resolve these ambiguities.
class_name PlayerInputSwitch


## Returns the [FieldActionSchedule] for a Wait action respective to [param player].
static func get_wait_action(player: Player2D) -> FieldActionSchedule:
  return FieldActionSchedule.new(
    FieldActionList.wait,
    get_playbill_standing_location(player),
  );


## Returns the [FieldActionSchedule] for some action resulting from a [param direction]
## input respective to [param player]. This may be a "Move" or a "Push" or a "Spin", etc.
static func get_dpad_action(player: Player2D, direction: Vector2i) -> FieldActionSchedule:
  var playbill := get_playbill_relative_location(player, direction);
  var chosen_action := resolve_to_first_viable_action(
    [
      get_move_variant(player),
      get_push_variant(player),
      FieldActionList.spin,
    ],
    playbill,
    FieldActionList.wait,
  );
  return FieldActionSchedule.new(chosen_action, playbill);


## Returns the [FieldActionSchedule] for some action resulting from a [param direction]
## input made while "Bracing", respective to [param player].
static func get_brace_dpad_action(player: Player2D, direction: Vector2i) -> FieldActionSchedule:
  var playbill := get_playbill_relative_location(player, direction);
  var chosen_action := resolve_to_first_viable_action(
    [
      FieldActionList.spin,
    ],
    playbill,
    FieldActionList.wait,
  );
  return FieldActionSchedule.new(chosen_action, playbill);


## Returns the [FieldActionSchedule] for some action resulting from an interact input
## respective to [param player].
static func get_interact_action(player: Player2D) -> FieldActionSchedule:
  var playbill := get_playbill_faced_position(player);
  var chosen_action := resolve_to_first_viable_action(
    [
      FieldActionList.interact,
      get_sword_variant(player),
    ],
    playbill,
  );
  return FieldActionSchedule.new(chosen_action, playbill);


## Returns the [FieldActionSchedule] for some action resulting from an interact input
## while "Bracing", respective to [param player].
static func get_brace_interact_action(player: Player2D) -> FieldActionSchedule:
  var playbill := get_playbill_faced_position(player);
  var chosen_action := resolve_to_first_viable_action(
    [
      get_sword_variant(player),
      get_hookshot_variant(player),
    ],
    playbill,
  );
  return FieldActionSchedule.new(chosen_action, playbill);


## Returns a [FieldActionSchedule] for some action resulting from an inspect input,
## respective to [param player].
static func get_inspect_action(player: Player2D) -> FieldActionSchedule:
  var playbill := get_playbill_faced_position(player);
  var chosen_action := resolve_to_first_viable_action(
    [
      FieldActionList.inspect,
    ],
    playbill,
  );
  return FieldActionSchedule.new(chosen_action, playbill);


## Returns the context-appropriate [FieldAction] for a "Move" action.
static func get_move_variant(player: Player2D) -> FieldAction:
  return (
    FieldActionList.move_fast if player.inventory.has_equipment(PlayerEquipment.fast_move)
    else FieldActionList.move
  );


## Returns the context-appropriate [FieldAction] for a "Push" action.
static func get_push_variant(player: Player2D) -> FieldAction:
  return (
    FieldActionList.shove if player.inventory.has_equipment(PlayerEquipment.shove)
    else FieldActionList.push
  );


## Returns the context-appropriate [FieldAction] for a "Sword" action.
static func get_sword_variant(player: Player2D) -> FieldAction:
  return (
    FieldActionList.sword_strike if player.inventory.has_equipment(PlayerEquipment.sword)
    else FieldActionList.null_action
  );


## Returns the context-appropriate [FieldAction] for a "Hookshot" action.
static func get_hookshot_variant(player: Player2D) -> FieldAction:
  return (
    FieldActionList.hookshot if player.inventory.has_equipment(PlayerEquipment.hookshot)
    else FieldActionList.null_action
  );


## Returns a common [FieldActionPlaybill] that targets an adjacent Grid location
## in the direction already faced by the [param player].
static func get_playbill_faced_position(player: Player2D) -> FieldActionPlaybill:
  return FieldActionPlaybill.new(
    player,
    player.faced_position,
    player.faced_direction,
  );

## Returns a common [FieldActionPlaybill] that targets a nearby Grid location
## in [param direction] respective to the [param player]. [br]
##
## Usually, [param direction] is a unit-vector in one of the four orthogonal directions,
## but any distance is acceptable. [br]
##
## [b]Note:[/b] A diagonal [param direction] is acceptable, but not properly accounted for.
static func get_playbill_relative_location(player: Player2D, direction: Vector2i) -> FieldActionPlaybill:
  return FieldActionPlaybill.new(
    player,
    player.grid_position + direction,
    direction.clampi(-1, 1),
  );


## Returns a common [FieldActionPlaybill] that targets the [param player]'s grid position,
## in the direction they're already facing.
static func get_playbill_standing_location(player: Player2D) -> FieldActionPlaybill:
  return FieldActionPlaybill.new(
    player,
    player.grid_position,
    player.faced_direction,
  );


## Returns the first action in [param actions] that can be performed with the given
## [param playbill]. If none can be found, returns [param default] instead.
static func resolve_to_first_viable_action(
    actions: Array[FieldAction],
    playbill: FieldActionPlaybill,
    default: FieldAction = FieldActionList.null_action,
) -> FieldAction:
  for action in actions:
    if action.can_perform(playbill):
      return action;

  return default;
