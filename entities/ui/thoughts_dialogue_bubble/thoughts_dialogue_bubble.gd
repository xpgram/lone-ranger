## A dialogue box for player thoughts while the command menu is open. [br]
##
## Adapted from the default Dialogue Manager 4 text balloon.
class_name ThoughtsDialogueBubble
extends Control


## The length in seconds that the fade in/out transition lasts.
const DIALOGUE_FADE_IN_TIME := 0.15;

## The easing-style of the open/close fade transition.
const DIALOGUE_FADE_IN_TRANSITION := Tween.TRANS_SINE;

## Emitted when the dialogue bubble becomes visible.
signal dialogue_opened();

## Emitted when the dialogue bubble becomes hidden.
signal dialogue_closed();


## The dialogue script to play.
@export var dialogue_resource: DialogueResource;

## Start from a particular cue in a [DialogueResource].
@export var start_from_cue := "";

## Whether to automatically advance to the next line after a line has ended.
@export var auto_advance_lines := false;

@export_group('Auto-Advance Settings', 'auto_advance')

## How long in seconds to wait after a line has ended before advancing to the
## next line. [br]
##
## A negative value will be treated as "auto".
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var auto_advance_default_delay := 2.5;

## The maximum time that a calculated auto-advance delay will wait for.
## How quickly a line of dialogue approaches this limit is determined by
## [member auto_advance_full_line_length].
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var auto_advance_maximum_auto_delay := 2.5;

## The minimum time that a calculated auto-advance delay will wait for.
## A line of dialogue that contains no text will wait exactly this long.
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var auto_advance_minimum_auto_delay := 1.0;

## How long a line of dialogue is allowed to be before it is considered
## "maximally full" for the purposes of calculating the auto-delay time.
@export_custom(PROPERTY_HINT_NONE, "suffix:ch")
var auto_advance_full_line_length := 80;

@export_group('Input Settings', 'input')

## The time in seconds since starting a dialogue line that text-advance input
## should be ignored. This helps mitigate the accidental skipping of short
## dialogue lines when trying to trigger the skip-typing functionality.
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var input_fast_tap_suppression_time := 0.3;

## The time in seconds since pressing the skip-line button that the skip-line
## feature should take to skip its first line.
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var input_skip_line_start_delay := 0.3;

## The time in seconds since starting a dialogue line that the skip-line
## input should be ignored.
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var input_skip_line_interval_time := 0.18;

## The current line being displayed. Text readout may still be in progress.
var dialogue_line: DialogueLine:
  set(value):
    if value:
      dialogue_line = value;
      _apply_dialogue_line_async();
    else:
      # The dialogue has finished, so close the bubble.
      if owner == null:
        queue_free();
      else:
        _try_close_dialogue_bubble_async()
  get():
    return dialogue_line;

## A dictionary to store any ephemeral variables used by the dialogue script.
## Accessed by dialogue scripts directly.
var locals: Dictionary = {};

## Whether the bubble is currently listening to any player inputs.
var _controls_locked := false;

## Whether the dialogue system is awaiting player input.
var _is_awaiting_input: bool = false:
  set(value):
    _is_awaiting_input = value;
    _text_advance_icon.visible = _is_awaiting_input;

## The language setting for the game session.
var _locale: String = TranslationServer.get_locale();

## Extra variable and callable method contexts to be useable from within the
## dialogue script.
var _temporary_game_states := [] as Array;

# [TODO] This thing is all over the script. Simplify its implementation.
## Whether this dialogue bubble will hide after the mutation timer has resolved.
var _will_hide_text_bubble: bool = false;

## A node for managing player input.
@onready var focus_node: FocusableControl = %FocusableControl;

## An audio player for voice-acted clips that play with the text readout.
@onready var _voice_audio_player: AudioStreamPlayer = %VoiceAudioPlayer;

## An audio player for typing sounds played as individual characters are read out.
@onready var _typewriter_audio_player: AudioStreamPlayer = %TypewriterAudioPlayer;

## An audio player for typing sounds played as individual characters are read out.
@onready var _open_audio_player: AudioStreamPlayer = %DialogueOpenPlayer;

## An audio player for typing sounds played as individual characters are read out.
@onready var _close_audio_player: AudioStreamPlayer = %DialogueClosePlayer;

## The node that displays the dialogue text.
@onready var _dialogue_label: DialogueLabel = %DialogueLabel;

## A timer for delaying text-bubble behavior when encountering a Dialogue
## Manager mutation.
@onready var _mutation_timer: Timer = %MutationTimer;

## A timer for delaying the auto-advance trigger at the end of a line readout.
## This allows readers time to catch up to the end of the line before the text
## they're reading is taken away from them.
@onready var _auto_advance_timer: Timer = %AutoAdvanceTimer;

## Used to inhibit quick-taps of the advance button that might skip dialogue by
## mistake.
@onready var _fast_tap_timer: Timer = %FastTapTimer;

## Used to measure the interval between skipped lines when holding the skip button.
@onready var _skip_line_timer: Timer = %SkipLineTimer;

## The "awaiting player input" icon indicating text readout has finished.
@onready var _text_advance_icon: Node2D = %AdvanceIcon;


func _ready() -> void:
  hide();
  _connect_to_signals();


func _connect_to_signals() -> void:
  Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated);
  Events.player_ui_interrupt.connect(_on_dialogue_interrupted);
  focus_node.focus_exited.connect(_on_focus_lost);
  _dialogue_label.spoke.connect(_on_dialogue_typewriter_sfx_triggered);
  _dialogue_label.finished_typing.connect(_on_dialogue_finished_typing);
  _dialogue_label.skipped_typing.connect(_on_dialogue_skipped_typing);
  _mutation_timer.timeout.connect(_on_mutation_timer_timeout);
  _skip_line_timer.timeout.connect(_on_skip_line_timer_timeout);


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus() or _controls_locked:
    return;

  if event.is_action_pressed("cancel"):
    _on_skip_line_button_pressed();
  elif event.is_action_released("cancel"):
    _on_skip_line_button_released();

  if (
      event.is_action_pressed("interact")
      or event.is_action_pressed("inspect")
  ):
    _on_advance_text_button_pressed();


## Responds to advance-line inputs.
func _on_advance_text_button_pressed() -> void:
  if _dialogue_is_playing():
    _dialogue_label.skip_typing();
    focus_node.accept_event();

  elif _is_awaiting_input and _fast_tap_timer.is_stopped():
    _load_line_id_async(dialogue_line.next_id);
    focus_node.accept_event();


## Responds to skip-line inputs.
func _on_skip_line_button_pressed() -> void:
  if not _dialogue_is_playing():
    await _load_line_id_async(dialogue_line.next_id);

  _dialogue_label.skip_typing();
  _skip_line_timer.start(input_skip_line_start_delay);


## Responds to skip-line-stop inputs.
func _on_skip_line_button_released() -> void:
  _skip_line_timer.stop();


func _notification(what: int) -> void:
  if what == NOTIFICATION_TRANSLATION_CHANGED:
    _on_translation_changed();


## Start playing the currently held [DialogueResource]. [br]
##
## If given, [param with_dialogue_resource] will be used, starting from
## [param cue]. [param extra_game_states] are additional script contexts
## that variables and methods may be accessed from (note that these states
## must be instantiated objects, even if they are static classes).
func start(
    with_dialogue_resource: DialogueResource = null,
    cue: String = "",
    extra_game_states: Array = []
) -> void:
  if not is_instance_valid(with_dialogue_resource):
    return;

  _temporary_game_states = [self] + extra_game_states;
  _is_awaiting_input = false;

  dialogue_resource = with_dialogue_resource;
  start_from_cue = cue;

  dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, _temporary_game_states);

  # [TODO] Structural issue: apply_dialogue_line already calls show(), so this is redundant.
  #     However, depending on apply_dialogue_line to show() feels like depending on a side effect.
  #     apply_dialogue_line probably shouldn't be responsible for the showing/hiding of the entire bubble.
  #     Caveat: sometimes mutations close the dialogue box, so apply_dialogue_line() needs to reopen it.
  # show();


## Forcibly closes the dialogue bubble.
func close() -> void:
  _try_close_dialogue_bubble_async();


## If not open, runs the dialogue bubble's open animation.
func _try_open_dialogue_bubble_async() -> void:
  if visible:
    return;

  _controls_locked = true;

  modulate.a = 0.0;
  dialogue_opened.emit();
  show();

  # [FIXME] Opening and closing in rapid succession should cause some wacky behavior
  #     since the previous tween is never stopped or dealt with.
  var alpha_tween := create_tween();
  alpha_tween.set_ease(Tween.EASE_IN);
  alpha_tween.set_trans(DIALOGUE_FADE_IN_TRANSITION);
  alpha_tween.tween_property(self, "modulate:a", 1.0, DIALOGUE_FADE_IN_TIME);

  alpha_tween.play();
  _open_audio_player.play();

  await alpha_tween.finished;
  await get_tree().create_timer(0.3).timeout;

  _controls_locked = false;


## If open, runs the dialogue bubble's close animation.
func _try_close_dialogue_bubble_async() -> void:
  if not visible:
    return;

  _controls_locked = true;

  modulate.a = 1.0;
  focus_node.release_focus();
  dialogue_closed.emit();

  var alpha_tween := create_tween();
  alpha_tween.set_ease(Tween.EASE_OUT);
  alpha_tween.set_trans(DIALOGUE_FADE_IN_TRANSITION);
  alpha_tween.tween_property(self, "modulate:a", 0.0, DIALOGUE_FADE_IN_TIME);

  alpha_tween.play();
  _close_audio_player.play();

  await alpha_tween.finished;

  hide();

  _controls_locked = false;


## Applies changes described by the current [member dialogue_line] to the
## text bubble.
func _apply_dialogue_line_async() -> void:
  _mutation_timer.stop();
  _fast_tap_timer.start(input_fast_tap_suppression_time);

  _is_awaiting_input = false;
  focus_node.grab_focus();
  # [TODO] Pause game events?

  _dialogue_label.hide();
  _dialogue_label.dialogue_line = dialogue_line;

  # [TODO] Add responses back in so this bubble may be generally useable.
  await _try_open_dialogue_bubble_async();

  _will_hide_text_bubble = false;
  _dialogue_label.show();

  var dialogue_has_text: bool = (not _dialogue_label.text.is_empty());

  if dialogue_has_text:
    _play_voice_line();
    _dialogue_label.type_out();
  else:
    # If there is no text to readout, "finish" immediately.
    _dialogue_label.finished_typing.emit();


## Starts and waits for auto-advance async triggers, then advances to the next
## line. [br]
##
## Will [b]not[/b] advance if the system requires player input or if the
## auto-advance flag has been switched off during the length of the delay timer.
func _start_auto_advance_timer() -> void:
  # Do not auto-advance when awaiting player input.
  if dialogue_line.responses.size() > 0:
    return;

  # Wait for audio playback to end.
  if dialogue_line.has_tag("voice"):
    if _voice_audio_player.playing:
      await _voice_audio_player.finished;

  # Wait for the line-timer to finish.
  else:
    var to_wait := _get_auto_advance_delay();
    _auto_advance_timer.start(to_wait);
    await _auto_advance_timer.timeout;

  # Verify after await that auto-advance is still enabled.
  if not auto_advance_lines:
    return;

  _load_line_id_async(dialogue_line.next_id);


## Requests the line with [param line_id] from the [member dialogue_resource]
## and sets it as the new [member dialogue_line] to display.
func _load_line_id_async(line_id: String) -> void:
  dialogue_line = await dialogue_resource.get_next_dialogue_line(line_id, _temporary_game_states);


## Returns the delay time in seconds for this line of dialogue.
func _get_auto_advance_delay() -> float:
  var auto_time := _get_auto_advance_auto_delay();

  var delay := (
    auto_time if dialogue_line.time == "auto"
    else dialogue_line.time.to_float() if dialogue_line.time != ""
    else auto_time if auto_advance_default_delay < 0.0
    else auto_advance_default_delay
  );
  delay = delay if delay >= 0.0 else 0.0;

  return delay;


## Returns the calculated auto-delay time in seconds for this line of dialogue. [br]
##
## Short dialogue lines will wait for less time than longer ones, but the time
## waited is eased toward the full wait time somewhat to avoid near-zero wait
## times for really short lines. [br]
##
## Note that this is a helper function to [method _get_auto_advance_delay] and
## is not necessarily meant to be used on its own.
func _get_auto_advance_auto_delay() -> float:
  var length := dialogue_line.text.length();

  var proportion := length / float(auto_advance_full_line_length);
  proportion = ease(proportion, 0.4);

  var time_delay := proportion * auto_advance_maximum_auto_delay;
  time_delay = clampf(time_delay, auto_advance_minimum_auto_delay, auto_advance_maximum_auto_delay);

  return time_delay;


## If the dialogue line has a voice clip, plays it.
func _play_voice_line() -> void:
  if not dialogue_line.has_tag("voice"):
    return;
  _voice_audio_player.stream = load(dialogue_line.get_tag_value("voice"));
  _voice_audio_player.play();


## Returns true if the text bubble is currently reading out text.
func _dialogue_is_playing() -> bool:
  return _dialogue_label.visible_ratio < 1.0;


#region Signals

## Responds to the dialogue label finishing its text readout.
func _on_dialogue_finished_typing() -> void:
  if auto_advance_lines:
    _start_auto_advance_timer();

  # [TODO] If responses, let the response buttons grab focus.

  _is_awaiting_input = true;
  focus_node.grab_focus();


## Responds to the dialogue label skipping the rest of its text readout.
func _on_dialogue_skipped_typing() -> void:
  _typewriter_audio_player.play();


## Responds to dialogue scene interrupt signals. Shuts the dialog system down
## and returns input focus to the previous holder.
func _on_dialogue_interrupted() -> void:
  _dialogue_label.skip_typing();
  _dialogue_label.dialogue_line = null;
  _try_close_dialogue_bubble_async();


## Responds to individual letters being typed into the [DialogueLabel].
## Used for playing typewriter or faux-voice sounds as text is read out.
func _on_dialogue_typewriter_sfx_triggered(_letter: String, _index: int, speed: float) -> void:
  if (
      not _typewriter_audio_player.stream
      or _typewriter_audio_player.playing
  ):
    return;

  # [FIXME] This doesn't work for other languages.
  #    Just do randf(), 1 in 3 sounds are high?
  var vowels := "aeiouyAEIOUY";
  var is_high_pitch: bool = _letter in vowels;

  var base_pitch := (1.0 + speed) / 2.0;
  var up_pitch := base_pitch + 0.05;

  _typewriter_audio_player.pitch_scale = up_pitch if is_high_pitch else base_pitch;
  _typewriter_audio_player.play();


## Responds to the [member focus_node] losing input focus.
func _on_focus_lost() -> void:
  _skip_line_timer.stop();


## Responds to the mutation timer's timeout signal.
func _on_mutation_timer_timeout() -> void:
  if _will_hide_text_bubble:
    _will_hide_text_bubble = false;
    await _try_close_dialogue_bubble_async();


## Responds to a Dialogue Manager mutation signal.
## If the mutation is one that closes the dialogue bubble, sets a short delay
## timer to settle affairs, then closes the bubble.
func _on_mutated(mutation: Dictionary) -> void:
  if not mutation.is_inline:
    _is_awaiting_input = false;
    _will_hide_text_bubble = true;
    _mutation_timer.start(0.1);


## Responds to the skip-line interval timing out.
func _on_skip_line_timer_timeout() -> void:
  if (
      not Input.is_action_pressed("cancel")
      or not focus_node.has_focus()
  ):
    return;

  await _load_line_id_async(dialogue_line.next_id);
  _dialogue_label.skip_typing();
  _skip_line_timer.start(input_skip_line_interval_time);


## Responds to an updated language preference signal.
## Updates the current line to show the new language.
func _on_translation_changed() -> void:
  if (
      _locale != TranslationServer.get_locale()
      and is_instance_valid(_dialogue_label)
  ):
    _locale = TranslationServer.get_locale();
    await dialogue_line.refresh();

    if _dialogue_label.visible_ratio < 1:
      _dialogue_label.skip_typing();

#endregion Signals
