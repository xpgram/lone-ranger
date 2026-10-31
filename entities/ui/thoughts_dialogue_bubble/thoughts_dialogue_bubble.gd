## A dialogue box for player thoughts while the command menu is open. [br]
##
## Adapted from the default Dialogue Manager 4 text balloon.
class_name ThoughtsDialogueBubble
extends Control

# [TODO] Skip dialogue (the cancel event)
# [TODO] Understand the mutation thing?
#     I think I get it, actually. But I still need to see how it's being applied.
# [TODO] I _think_ a mutation may be text effects like [wait=0.5].
#     A problem: .skip_typing() is never called during a mutation, then.
#     If the mutation timer is going, it should skip and then the text should skip.
# [FIXME] Re-evaluate some of these public vars, make sure they actually should be.

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
        hide();
  get():
    return dialogue_line;

## A dictionary to store any ephemeral variables used by the dialogue script.
## Accessed by dialogue scripts directly.
var locals: Dictionary = {};

## Whether the dialogue system is awaiting player input.
var _is_awaiting_input: bool = false:
  set(value):
    _is_awaiting_input = value;
    _text_advance_icon.visible = _is_awaiting_input;

## The language setting for the game session.
var _locale: String = TranslationServer.get_locale();

# [FIXME] Array[GameState], whatever that is.
# [FIXME] Find out what a Game State is so that I can write this doc string.
# Worth noting, DialogueManager does require it. Or, it seems important enough.
# [INFO] These provide additional object space for calling methods and storing values.
#     Uh, temporary... I'm not sure what's meant by temporary, but this _is_ what the
#     game states thing is about.
##
var _temporary_game_states := [] as Array;

# [TODO] This thing is all over the script. Simplify its implementation.
## Whether this dialogue bubble will hide after the mutation timer has resolved.
var _will_hide_text_bubble: bool = false;

# [TODO] Make the entire scene a FocusableNode?
## A node for managing player input.
@onready var focus_node: FocusableControl = %FocusableControl;

## An audio player for typing sounds and other dialogue sfx.
@onready var _voice_audio_player: AudioStreamPlayer = %VoiceAudioPlayer;

## The node that displays the dialogue text.
@onready var _dialogue_label: DialogueLabel = %DialogueLabel;

## A timer for delaying text-bubble behavior when encountering a Dialogue
## Manager mutation.
@onready var _mutation_timer: Timer = %MutationTimer;

## A timer for delaying the auto-advance trigger at the end of a line readout.
## This allows readers time to catch up to the end of the line before the text
## they're reading is taken away from them.
@onready var _auto_advance_timer: Timer = %AutoAdvanceTimer;

## The "awaiting player input" icon indicating text readout has finished.
@onready var _text_advance_icon: Node2D = %AdvanceIcon;


func _ready() -> void:
  _connect_to_signals();

  # Hide the dialogue bubble until needed.
  hide();


func _connect_to_signals() -> void:
  Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated);
  _dialogue_label.finished_typing.connect(_on_dialogue_finished_typing);
  _mutation_timer.timeout.connect(_on_mutation_timer_timeout);


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  var advance_button_pressed: bool = (
    event.is_action_pressed("interact")
    or event.is_action_pressed("cancel")
    or event.is_action_pressed("inspect")
  );

  if _dialogue_label.is_typing and advance_button_pressed:
    # [TODO] Does not skip effects like [wait]
    _dialogue_label.skip_typing();
    focus_node.accept_event();

  elif _is_awaiting_input and advance_button_pressed:
    _load_line_id_async(dialogue_line.next_id);
    focus_node.accept_event();


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
  _temporary_game_states = [self] + extra_game_states;
  _is_awaiting_input = false;

  if is_instance_valid(with_dialogue_resource):
    dialogue_resource = with_dialogue_resource;

  if cue != "":
    start_from_cue = cue;

  dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, _temporary_game_states);
  show();


## Applies changes described by the current [member dialogue_line] to the
## text bubble.
func _apply_dialogue_line_async() -> void:
  _mutation_timer.stop();

  _is_awaiting_input = false;
  focus_node.grab_focus();
  # [TODO] Pause game events?

  _dialogue_label.hide();
  _dialogue_label.dialogue_line = dialogue_line;

  # [TODO] Add responses back in so this bubble may be generally useable.

  _will_hide_text_bubble = false;
  _dialogue_label.show();
  show();

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


#region Signals

## Responds to the dialogue label finishing its text readout.
func _on_dialogue_finished_typing() -> void:
  if auto_advance_lines:
    _start_auto_advance_timer();

  # [TODO] If responses, let the response buttons grab focus.

  _is_awaiting_input = true;
  focus_node.grab_focus();


## Responds to the mutation timer's timeout signal.
func _on_mutation_timer_timeout() -> void:
  if _will_hide_text_bubble:
    _will_hide_text_bubble = false;
    hide();


## Responds to a Dialogue Manager mutation signal.
## [FIXME] What does this actually do?
func _on_mutated(mutation: Dictionary) -> void:
  if not mutation.is_inline:
    _is_awaiting_input = false;
    _will_hide_text_bubble = true;
    _mutation_timer.start(0.1);


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
