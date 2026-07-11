## @tool [br]
## A [Component] to attach object-to-object attribute messages to [GridObject]s. [br]
##
## This is useful when another [GridObject]'s behavior depends on the nature or
## properties of the Grid cell they're located in.
@tool
class_name GridMessageComponent
extends BaseComponent


## The message to yield to any matched entities.
@export var _message: Message;

## The messages to yield to any matched entities.
@export var _messages: Array[Message];

## Whether to yield more than one message to any requesting object.
@export var _send_multiple_messages := false:
  set(value):
    _send_multiple_messages = value;
    notify_property_list_changed();


@export_group("Filter Objects")

## Whether to restrict the messages yielded only to a select few objects that
## request it.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var _filter_objects: bool;

## The entities to watch for. When any of these ask this trigger box for its
## [member message], they will receive it.
@export var _matched_grid_objects: Array[GridObject];

## Whether to match the player entity.
@export var _match_player_entity := false;


func _validate_property(property: Dictionary) -> void:
  if property.name == '_message' and _send_multiple_messages:
    property.usage = PROPERTY_USAGE_NONE;
  if property.name == '_messages' and not _send_multiple_messages:
    property.usage = PROPERTY_USAGE_NONE;


## Returns the messages this collider has for its watched-for [GridObject]s.
## Returns an empty list if [param object] is not a watched-for type.
func get_messages(object: GridObject) -> Array[Message]:
  if (
      not _filter_objects
      or _matched_grid_objects.has(object)
      or _match_player_entity and object is Player2D
  ):
    return _get_messages_list();

  return [];


## Returns the list of messages associated with this messenger.
func _get_messages_list() -> Array[Message]:
  return _messages if _send_multiple_messages else [_message];


## An enum of messages that [MessageCollider] can send.
enum Message {
  None,
  PermanentTileMapChange,
}
