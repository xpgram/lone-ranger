## A class for managing simple but flexible state machines. [br]
##
## Usage: [br]
##
## [codeblock]
## var state_machine := CallableStateMachine.new('DemoMachine');
##
## # Add states to your state machine using a loose list of simple functions.
## # CallableState will determine which functions are for what automatically.
## # (See CallableState's documentation for more info.)
## state_machine.add_states(
##     CallableState.new([state_idle]),
##     CallableState.new([state_walking, state_walking_process, state_walking_exit]),
## );
##
## # Switch to your initial state using the same enter function it was added with.
## state_machine.switch_to(state_idle);
##
## # Or switch states with a key you've set yourself.
## state_machine.add_state(CallableState.new([state_idle], 'idle'));
## state_machine.switch_to('idle');
##
## # Remember to process your state machine:
## func _process(delta: float) -> void:
##     state_machine.get_state().process(delta);
##
## # Don't worry if the current state has no defined behavior for a particular machine
## # call; missing behavior is stepped-over automatically.
## func _unhandled_input(event: InputEvent) -> void:
##     state_machine.get_state().input(event);
## [/codeblock]
## @version 0.1.0
class_name CallableStateMachine
extends RefCounted


## The name of this state machine, for debugging purposes.
var _machine_name: String;

## The collection of known state objects.
var _states_map := {} as Dictionary[Variant, CallableState];

## The current [CallableState] object fulfilling the [CallableStateMachine]'s operations.
var _current_state: CallableState = null;


## [param machine_name] The debug name for this state machine.
func _init(machine_name: String = 'Unknown State Machine') -> void:
  _machine_name = machine_name;


## Adds a [CallableState] to the machine's dictionary of known states.
func add_state(state: CallableState) -> void:
  var machine_key: Variant = state.get_machine_key();

  assert(not _states_map.has(machine_key),
    "");

  _states_map.set(machine_key, state);


## Adds a list of [CallableState] objects to the machine's dictionary of known states.
func add_states(states: Array[CallableState]) -> void:
  for state in states:
    add_state(state);
  

## Returns the currently active [CallableState].
func get_state() -> CallableState:
  assert(_current_state != null,
    "The machine has no state set. Did you forget to set the first state with switch_to()?");
  return _current_state;


## Returns true if [param state_key] is the machine key for the currently active state.
func is_state(state_key: Variant) -> bool:
  return _states_map.get(state_key) == _current_state;


## Changes the current state to the state associated with [param state_key].
## If the change succeeds, this will call the exit method of the current state and the
## enter method of the next state, without calling the process method of the next state. [br]
##
## This will fail if [param state_key] is not associated with any states known to this
## state machine. [br]
##
## Unless extended, a [CallableState] will default to its 'enter' [Callable] as its
## [param state_key], which you might call like this:
## [codeblock]state_machine.switch_to(state_walking); [/codeblock]
func switch_to(state_key: Variant) -> void:
  if not _states_map.has(state_key):
    push_warning(
      _get_debug_metadata(),
      'Cannot switch_to() an unknown state key (%s).' % _get_string_from_state_key(state_key)
    );
    return;

  var next_state: CallableState = _states_map.get(state_key);

  if _current_state:
    _current_state.exit();
  next_state.enter();

  _current_state = next_state;


## Returns a string representation of the key for a state collection.
func _get_string_from_state_key(key: Variant) -> String:
  return (
    key.get_method() if key is Callable
    else String(key)
  );


## Returns a string containing the class and machine name for this state machine.
func _get_debug_metadata() -> String:
  return "%s '%s': " % [get_class(), _machine_name];
