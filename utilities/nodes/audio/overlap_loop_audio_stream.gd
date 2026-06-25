## A utility node for specially looping audio that must overlap with itself.
@tool
class_name OverlapLoopAudioStream
extends AudioStreamPlayer


## If enabled, the audio will loop before the end of the stream at a time determined by
## [member tail_length].
@export var early_loop_enabled := false;

## How long in seconds the stream's overlapping "tail" is. Where this tail starts is where
## the audio will actually loop if [member early_loop_enabled] is true.
@export_range(0.0, 4.0, 0.1, "or_greater")
var tail_length := 0.0:
  set(value):
    tail_length = clampf(value, 0.0, stream.get_length());


func _ready() -> void:
  max_polyphony = 2;


func _process(_delta: float) -> void:
  _try_to_early_loop();


## If enabled, plays a second occurrence of the audio (an overlapping loop) if the current
## audio playback time is past the timestamp for the audio's tail.
func _try_to_early_loop() -> void:
  if not playing or not early_loop_enabled:
    return;

  var elapsed_time := get_playback_position();
  elapsed_time += AudioServer.get_time_since_last_mix();

  var loop_point := stream.get_length() - tail_length;

  if elapsed_time > loop_point:
    var start_time := elapsed_time - loop_point;
    play(start_time);
