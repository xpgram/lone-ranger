extends Control


## How long a message persists before its exit animation is triggered.
@export var message_linger_time := 4.0;

## How long a message's exit animation takes to finish.
@export var message_fadeout_time := 1.0;

@export_group('Node Connections')

@export var _event_message_label: Label;


## A reference to the transparency tweener for player event messages.
var _alpha_tween: Tween;


func _ready() -> void:
  _event_message_label.modulate.a = 0.0;

  Events.game_event_message_announced.connect(_on_game_event_message_announced);


func _on_game_event_message_announced(message: String) -> void:
  _event_message_label.text = message;
  _event_message_label.modulate.a = 1.0;

  if _alpha_tween:
    _alpha_tween.stop();

  _alpha_tween = get_tree().create_tween();
  _alpha_tween.tween_property(_event_message_label, 'modulate:a', 1.0, message_linger_time);
  _alpha_tween.tween_property(_event_message_label, 'modulate:a', 0.0, message_fadeout_time);
  await _alpha_tween.finished;
