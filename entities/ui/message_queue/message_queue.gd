extends Control


@export_group('Node Connections')

## A reference to the [MessageQueueText] scene to be instantiated for all new messages.
@export var _message_text_scene := preload('uid://37gcrrhanyw0');


## The list of messages currently displayed.
var _queue: Array[MessageQueueText];


func _ready() -> void:
  Events.game_event_message_announced.connect(_on_game_event_message_announced);


## Event handler for new UI message announcements.
func _on_game_event_message_announced(message: String) -> void:
  _create_new_message(message);


## Event handler for messages that have finished displaying. [br]
##
## Removes them from the message queue and triggers a reconstruction of the active
## messages' line-by-line presentation.
func _on_message_animation_finished(message_node: MessageQueueText) -> void:
  var message_index := _queue.find(message_node);

  if message_index != -1:
    _queue.remove_at(message_index);
    _reconfigure_message_positions();


## Creates a new [MessageQueueText] representing the given [param message] and adds it to
## the MessageQueue system.
func _create_new_message(message: String) -> void:
  var new_message: MessageQueueText = _message_text_scene.instantiate();

  new_message.text = message;
  new_message.modulate.a = 1.0;
  new_message.position.y = _get_message_y_displacement(_queue.size());

  new_message.finished.connect(_on_message_animation_finished);

  add_child(new_message);
  _queue.append(new_message);


## Returns the y-axis displacement from the MessageQueue's origin that a
## [MessageQueueText] at [param index] should display itself at.
func _get_message_y_displacement(index: int) -> int:
  return index * -8;


## Reconfigures the y-axis displacement of all active [MessageQueueText]s in the message
## queue.
func _reconfigure_message_positions() -> void:
  for index in range(_queue.size()):
    var message := _queue[index];
    message.position.y = size.y + _get_message_y_displacement(index);
    # TODO Tween instead.
