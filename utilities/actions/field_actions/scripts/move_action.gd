class_name Move_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return ActionUtils.place_is_traversable(playbill.target_position, playbill.performer);


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  actor.faced_direction = playbill.orientation;

  if actor is Player2D:
    var player := actor as Player2D;

    var place_is_pit := ActionUtils.place_is_pit(playbill.target_position);
    var no_standables := not ActionUtils.place_has_standable(playbill.target_position);
    var cannot_float := player.get_air_steps_remaining() <= 0;

    if place_is_pit and no_standables and cannot_float:
      player.start_coyote_fall();
      var fall_recovered: bool = await player.coyote_fall_recovered_result;

      if fall_recovered:
        return false;

  actor.grid_position = playbill.target_position;

  return true;
