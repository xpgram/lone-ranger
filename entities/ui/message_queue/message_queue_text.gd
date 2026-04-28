## A [Label] class to display temporary text that self-destructs after a period of time. [br]
##
## Connect to [signal tree_exited] to respond to the self-destruct event when it happens.
class_name MessageQueueText
extends Label


## Emitted when this [MessageQueueText] is finished displaying and is queued for deletion.
signal finished(label: MessageQueueText);


## How long a message persists before its exit animation is triggered.
@export var linger_time := 4.0;

## How long a message's exit animation takes to finish.
@export var fadeout_time := 1.0;


func _ready() -> void:
  _trigger_animation_async();


## Builds and starts the display and fadeout animation for this UI message. [br]
##
## [b]Note:[/b] Calls [code]queue_free()[/code] at the end of the animation.
func _trigger_animation_async() -> void:
  await get_tree().create_timer(linger_time).timeout;

  var _alpha_tween := get_tree().create_tween();
  _alpha_tween.tween_property(self, 'modulate:a', 0.0, fadeout_time);
  await _alpha_tween.finished;

  queue_free();
  finished.emit(self);
