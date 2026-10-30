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

## Whether the dialogue system is awaiting player input.
var _is_awaiting_input: bool = false:
  set(value):
    _is_awaiting_input = value;
    _text_advance_icon.visible = _is_awaiting_input;

## The language setting for the game session.
var _locale: String = TranslationServer.get_locale();

## A dictionary to store any ephemeral variables used by the dialogue script.
# [FIXME] Not used?
var _locals: Dictionary = {};

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
@onready var _audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer;

## The node that displays the dialogue text.
@onready var _dialogue_label: DialogueLabel = %DialogueLabel;

## A timer for delaying text-bubble behavior when encountering a Dialogue
## Manager mutation.
@onready var _mutation_timer: Timer = %MutationTimer;

## The "awaiting player input" icon indicating text readout has finished.
@onready var _text_advance_icon: Node2D = %AdvanceIcon;


func _ready() -> void:
  _connect_to_signals();

  # Hide the dialogue bubble until needed.
  hide();


func _connect_to_signals() -> void:
  Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated);
  _mutation_timer.timeout.connect(_on_mutation_timer_timeout);


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  var advance_button_pressed: bool = (
    event.is_action_pressed("interact")
    or event.is_action_pressed("cancel")
    or event.is_action_pressed("inspect")
  );

  # [TODO] Could I rewrite this as a match?
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
## [param cue]. I don't know what [param extra_game_states] are.
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

  _text_advance_icon.hide();
  _is_awaiting_input = false;
  focus_node.grab_focus();
  # [TODO] Pause game events?

  _dialogue_label.hide();
  _dialogue_label.dialogue_line = dialogue_line;

  # [FIXME] If there are responses, just raise an error. Unless...?

  show();
  _will_hide_text_bubble = false;
  _dialogue_label.show();

  if not _dialogue_label.text.is_empty():
    _dialogue_label.type_out();
    await _dialogue_label.finished_typing;

  # Wait for _load_line_id_async line
  # [TODO] Can this be broken off into a separate function?
  if dialogue_line.has_tag("voice"):
    _audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"));
    _audio_stream_player.play();
    await _audio_stream_player.finished;
    # [TODO] Wait, this just skips to _load_line_id_async if there's voice? What if I want to wait?
    _load_line_id_async(dialogue_line.next_id);
  elif dialogue_line.time != "":
    # [TODO] This 'time' should be a function call.
    var time: float = (
      dialogue_line.text.length() + 0.02 if dialogue_line.time == "auto"
      else dialogue_line.time.to_float()
    );
    await get_tree().create_timer(time).timeout;
    _load_line_id_async(dialogue_line.next_id);
  else:
    _is_awaiting_input = true;
    focus_node.grab_focus();


## Requests the line with [param line_id] from the [member dialogue_resource]
## and sets it as the new [member dialogue_line] to display.
func _load_line_id_async(line_id: String) -> void:
  dialogue_line = await dialogue_resource.get_next_dialogue_line(line_id, _temporary_game_states);


#region Signals

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
