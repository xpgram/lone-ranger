extends Interactive2D


func _on_free_fall() -> void:
  await get_tree().create_timer(0.5).timeout;

  var permanent_change := _location_is_marked_permanent();
  Grid.set_tile_type(grid_position, 2, permanent_change);

  queue_free();


## Returns true if the current [member grid_position] has an object with a
## message for `self` that this map-tile change should be permanent.
func _location_is_marked_permanent() -> bool:
  var location_is_marked_permanent := false;
  var objects := Grid.get_objects(grid_position);

  var permanent_message := GridMessageComponent.Message.PermanentTileMapChange;

  for object in objects:
    var messenger := Component.getc(object, GridMessageComponent) as GridMessageComponent;
    if (
        messenger
        and permanent_message in messenger.get_messages(self)
    ):
      location_is_marked_permanent = true;
      break;

  return location_is_marked_permanent;
