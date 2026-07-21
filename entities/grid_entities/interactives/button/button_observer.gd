## @tool [br]
## The observer entity listens for button signals and coordinates multi-button trigger
## behavior.
@tool
class_name ButtonObserver
extends Node2D


enum ActivationStyle {
  ## All connected buttons must be pressed to activate this observer.
  ALL,
  ## One or more connected buttons must be pressed to activate this observer.
  ONE,
  ## All connected buttons must be released to activate this observer.
  NONE,
}


## Emitted when the observer's buttons are pressed, according to its [ActivationStyle].
signal activated();

## Emitted when the observer's buttons stop being pressed, according to its
## [ActivationStyle].
signal deactivated();


## A list of [ButtonEntity] objects to observe.
@export var _button_list: Array[ButtonEntity]:
  set(value):
    _button_list = value;
    queue_redraw();

## Describes how the observer listens to its connected buttons for activation cues.
@export var _activation_style := ActivationStyle.ALL;

## A list of [Node]s to toggle in accordance with this observer's
## [member _is_activated] state. All referenced [Node]s must own a
## [PowerableComponent] to be notified of changes.
@export var _powerable_targets := [] as Array[Node];

## @nullable [br]
## The [PersistenceKeyBool] object to set along with this button observer's
## activated state. If this object is null, no persistence key is set.
@export var _persistence_key: PersistenceKeyBool;


## A reference to the Engine's EditorInterface singleton. [br]
## Note: This can't be statically typed because it breaks exported builds.
var _editor_selection_interface;

## Whether to show debug lines to this [ButtonObserver]'s connected [ButtonEntity]s.
var _show_connected_button_lines := false:
  set(value):
    _show_connected_button_lines = value;
    queue_redraw();

## Whether this [ButtonObserver] is triggered or not-triggered by its list of observed
## [ButtonEntity]s.
var _is_activated := false:
  set(value):
    var old_value = _is_activated;
    _is_activated = value;

    if (
        Engine.is_editor_hint()
        or old_value == _is_activated
    ):
      return;

    var signal_to_emit := activated if _is_activated else deactivated;

    signal_to_emit.emit();
    _notify_powerable_targets();
    _update_persistence_key();


func _ready() -> void:
  if not Engine.is_editor_hint():
    _connect_to_button_entities();
    _connect_to_own_signals();

  if Engine.is_editor_hint():
    _connect_to_editor();


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  _draw_button_entity_lines();
  _draw_self();


## Gets editor interface references and connects to editor signals.
func _connect_to_editor() -> void:
  _editor_selection_interface = Engine.get_singleton('EditorInterface').get_selection();
  _editor_selection_interface.selection_changed.connect(_on_editor_selection_changed);


## Connects to observed [ButtonEntity] signals.
func _connect_to_button_entities() -> void:
  for button in _button_list:
    button.pressed.connect(_on_button_state_updated);
    button.released.connect(_on_button_state_updated);


## Connects callbacks to this object's own signals.
func _connect_to_own_signals() -> void:
  activated.connect(_on_activated);
  deactivated.connect(_on_deactivated);


## Draws lines in Godot's editor view to all connected [ButtonEntity] objects.
func _draw_button_entity_lines() -> void:
  if not _show_connected_button_lines:
    return;

  for button in _button_list:
    if not button:
      continue;

    var to_position := to_local(button.global_position);
    var rect_radius := Vector2(8, 8);
    draw_line(
      Vector2.ZERO,
      to_position,
      Color.ORANGE,
      1.0,
    );
    draw_rect(
      Rect2(to_position - rect_radius, 2*rect_radius),
      Color.ORANGE,
      false,
      1.0,
    );


## Draws a representation of the self in Godot's editor view.
func _draw_self() -> void:
  if not Engine.is_editor_hint():
    return;

  draw_circle(
    Vector2.ZERO,
    4.0,
    Color.ORANGE,
  );


## Updates debug-draw settings when the editor's selected nodes are changed.
func _on_editor_selection_changed() -> void:
  if not _editor_selection_interface:
    return;

  var selected_nodes: Array[Node] = _editor_selection_interface.get_selected_nodes();
  _show_connected_button_lines = (self in selected_nodes);


## Handler for [ButtonEntity] signals pressed and released.
func _on_button_state_updated() -> void:
  _reevaluate_trigger_state();


## Checks observed [ButtonEntity] states and activates or deactivates the observer
## according to its [ActivationStyle].
func _reevaluate_trigger_state() -> void:
  var conditions_met := false;

  match _activation_style:
    ActivationStyle.ALL:
      conditions_met = _button_list.all(_button_is_pressed);
    ActivationStyle.ONE:
      conditions_met = _button_list.any(_button_is_pressed);
    ActivationStyle.NONE:
      conditions_met = not _button_list.any(_button_is_pressed);

  _is_activated = conditions_met;


## Returns true if the given [param button] is currently pressed.
func _button_is_pressed(button: ButtonEntity) -> bool:
  return button.is_pressed;


## @virtual [br]
## Override to add on-activation behavior to this [ButtonObserver].
func _on_activated() -> void:
  pass


## @virtual [br]
## Override to add on-deactivation behavior to this [ButtonObserver].
func _on_deactivated() -> void:
  pass


## Updates the powered state of all [PowerableComponent]s found in this observer's
## list of [member _powerable_targets] to match this observer's
## [member _is_activated] state.
func _notify_powerable_targets() -> void:
  if not _powerable_targets:
    return;

  for target in _powerable_targets:
    var powerable := Component.getc(target, PowerableComponent) as PowerableComponent;
    if powerable:
      powerable.powered = _is_activated;


## Updates the state of the [member _persistence_key] associated with this
## button to match its [member _is_activated] state.
func _update_persistence_key() -> void:
  if not _persistence_key:
    return;

  _persistence_key.write(_is_activated);
