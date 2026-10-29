## A dialogue box for player thoughts while the command menu is open. [br]
##
## Adapted from the default Dialogue Manager 4 text balloon.
class_name ThoughtsDialogueBubble
extends Control

# [TODO] Advance dialogue (the interact event)
# [TODO] Skip dialogue (the cancel event)
# [TODO] Understand the mutation thing?
#     I think I get it, actually. But I still need to see how it's being applied.
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
      _apply_dialogue_line();
    else:
      # The dialogue has finished, so close the bubble.
      if owner == null:
        queue_free();
      else:
        hide();
  get():
    return dialogue_line;

## Whether the dialogue system is awaiting player input.
## [FIXME] To outsiders, this should be read only.
var is_waiting_for_input: bool = false;

## A dictionary to store any ephemeral variables used by the dialogue script.
var locals: Dictionary = {};

## The language setting for the game session.
var _locale: String = TranslationServer.get_locale();

# [FIXME] Array[GameState], whatever that is.
# [FIXME] Find out what a Game State is so that I can write this doc string.
# Worth noting, DialogueManager does require it. Or, it seems important enough.
##
var _temporary_game_states := [] as Array;

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


func _process(_delta: float) -> void:
  # [FIXME] Call this elsewhere.
  _autoset_advance_icon_visibility();


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  if event.is_action_pressed("interact"):
    prints('Interacting with the dialogue bubble...');
    focus_node.accept_event();

  # [TODO] DialogueManager handles input itself, right? Is there anything to do here?
  #     I don't mind setting advance and skip (and cancel) up manually. I may even prefer it.


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
  _temporary_game_states = [self] + extra_game_states
  is_waiting_for_input = false

  if is_instance_valid(with_dialogue_resource):
    dialogue_resource = with_dialogue_resource

  if not cue.is_empty():
    start_from_cue = cue

  dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, _temporary_game_states)
  show()


##
func _apply_dialogue_line() -> void:
  # [FIXME]
  pass


## Sets the visibility of the text-advance icon in accordance with certain
## dialogue bubble conditions.
func _autoset_advance_icon_visibility() -> void:
  if is_instance_valid(dialogue_line):
    _text_advance_icon.visible = (
      not _dialogue_label.is_typing
      and dialogue_line.responses.size() == 0
      and not dialogue_line.has_tag("voice")
    );


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
    is_waiting_for_input = false;
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
