class_name Hookshot_FieldAction
extends FieldAction


@export var max_chain_tile_length := 4;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var first_spot := playbill.performer.grid_position + playbill.orientation;
  var first_spot_is_open := ActionUtils.place_is_traversable(first_spot, playbill.performer);

  var is_player_2d := playbill.performer is Player2D;
  if not is_player_2d:
    push_error("Hookshot_FieldAction does not currently support performer's that are not Player2D's.");

  return first_spot_is_open and is_player_2d;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;

  var candidate_coords := ActionUtils.get_coordinate_line(playbill.performer.grid_position, playbill.orientation, max_chain_tile_length);
  var viable_coords: Array[Vector2i];

  for coord in candidate_coords:
    viable_coords.append(coord);
    if not ActionUtils.place_is_traversable(coord, playbill.performer):
      break;

  # Hookshot needs a hitch coord and a landing coord. A viable coords list size of 1
  # suggests the player and the hookshot target are already adjacent on the board.
  if viable_coords.size() < 2:
    return false;

  var target_hitch_coord := viable_coords[-1];
  var target_landing_coord := viable_coords[-2]; # TODO Should be list[0] if retracting instead.

  var is_hitched := not ActionUtils.place_is_traversable(target_hitch_coord, playbill.performer);

  # TODO Identify target spot is hitchable vs clinkable (e.g. wood vs. metal)
  var extendable_length := (
    viable_coords.size() - 1 if is_hitched
    else viable_coords.size()
  );

  # TODO Identify target spot is retractable (e.g. a pickup the hookshot brings back to you)

  if actor is Player2D:
    actor.set_handheld_item(PlayerHandheldItem.HandheldItemType.Hookshot);
    actor.set_animation_state('item_use');

    var hookshot: Hookshot_PlayerTool = actor.get_handheld_tool(PlayerHandheldItem.HandheldItemType.Hookshot);
    hookshot.chain_length = 0;

    for i in range(extendable_length):
      await Engine.get_main_loop().create_timer(0.03).timeout;
      hookshot.chain_length += 1;

    await Engine.get_main_loop().create_timer(0.5).timeout;

  # TODO If hitchable, animate player toward hitch spot
  #   I need to animate the avatar, not the GridEntity: I don't want to trigger fall stimulations, etc.
  # TODO If retractable, animate target toward player
  if is_hitched:
    actor.grid_position = target_landing_coord;

  return true;
