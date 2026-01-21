class_name Hookshot_FieldAction
extends FieldAction


@export var chain_tile_length := 3;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var first_spot := playbill.performer.grid_position + playbill.orientation;
  var first_spot_is_open := ActionUtils.place_is_traversable(first_spot, playbill.performer);

  var is_player_2d := playbill.performer is Player2D;
  if not is_player_2d:
    push_error("Hookshot_FieldAction does not currently support performer's that are not Player2D's.");

  return first_spot_is_open and is_player_2d;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;

  # TODO Identify a target spot
  # TODO Identify target spot is hitchable
  # TODO Identify target spot is retractable

  if actor is Player2D:
    actor.set_handheld_item(PlayerHandheldItem.HandheldItemType.Hookshot);
    actor.set_animation_state('item_use');

    var hookshot: Hookshot_PlayerTool = actor.get_handheld_tool(PlayerHandheldItem.HandheldItemType.Hookshot);
    hookshot.chain_length = 0;

    for i in range(chain_tile_length):
      await Engine.get_main_loop().create_timer(0.05).timeout;
      hookshot.chain_length += 1;

    await Engine.get_main_loop().create_timer(0.5).timeout;

    # TODO If hitchable, animate player toward hitch spot
    # TODO If retractable, animate target toward player

  return true;
