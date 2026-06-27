## A class for managing simple but flexible state machines. [br]
##
## Usage: [br]
##
## [codeblock]
##  var state_machine := CallableStateMachine.new('DemoMachine');
##
##  # Add states to your state machine using a loose list of simple functions.
##  # CallableState will determine which functions are for what automatically.
##  # (See CallableState's documentation for more info.)
##  state_machine.add_states(
##      [state_idle],
##      [state_walking, state_walking__process, state_walking__exit],
##  );
##
##  # Switch to your initial state using the same enter function it was added with.
##  state_machine.switch_to(state_idle);
##
##  # Or switch states with a key you've set yourself.
##  state_machine.add_state(CallableState.new([state_idle], 'idle'));
##  state_machine.switch_to('idle');
##
##  # Remember to process your state machine:
##  func _process(delta: float) -> void:
##      state_machine.get_state().process(delta);
##
##  # Don't worry if the current state has no defined behavior for a particular machine
##  # call; missing behavior is stepped-over automatically.
##  func _unhandled_input(event: InputEvent) -> void:
##      state_machine.get_state().input(event);
## [/codeblock]
## @version 0.1.0
class_name CallableStateMachine
extends RefCounted


# [TODO] Check doc strings for accuracy.
# [TODO] Make CallableState private.
# [TODO] Wait. I have to be able to extend CallableState...
#   This branch is pointless unless I can give a constructed StateMachine a type it can
#   instantiate. Can I do something like:
#     state_machine.set_state_type(PlayerState.new);
#   And this would set the constructor used for new CallableState types?

# [TODO] I added a usage example to player2d.gd. Note that I don't really like it.
#   It's too bare. I don't feel like it tells me enough.
#   I should try to like it before dismissing it completely, but... yeah, I dunno.
#   PlayerState.new([...])
#   PlayerState.new([...])
#   PlayerState.new([...])
#   ^ This does actually feel better to me.


## The name of this state machine, for debugging purposes.
var _machine_name: String;

## The collection of known state objects.
var _states_map := {} as Dictionary[Variant, CallableState];

## The current [CallableState] object fulfilling the [CallableStateMachine]'s operations.
var _current_state: CallableState = null;


## [param machine_name] The debug name for this state machine.
func _init(machine_name: String = 'Unknown State Machine') -> void:
  _machine_name = machine_name;


## Adds a collection of state [Callable]s to the machine's dictionary of known states.
func add_state(callables: Array[Callable]) -> void:
  var state := CallableState.new(callables);
  _add_callable_state_to_machine(state);


## Adds a collection of state [param callables] to the machine's dictionary of known states
## under the reference key [param key].
func add_state_with_key(key: Variant, callables: Array[Callable]) -> void:
  var state := CallableState.new(callables, key);
  _add_callable_state_to_machine(state);


## Adds a set of state [Callable] collections to the machine's dictionary of known states. [br]
##
## [param collection] is of type `Array[ Array[Callable] ]`.
func add_states(collection: Array[Array]) -> void:
  for state_callables in collection:
    for callable in state_callables:
      assert(callable is Callable,
        "State method was not of type Callable.");
    add_state(state_callables);


## Adds a collection of state [param callables] to the machine's dictionary of known states
## under the reference key [param key].
##
## [param collection] is of type `Array[ Tuple[Variant, Array[Callable]] ]`. [br]
##
## GDScript, at time of writing, does not handle nested types, so here is a usage example:
##
## [codeblock]
##  state_machine.add_states_with_keys([
##    [
##      &'move',
##      [
##        _state_move,
##        _state_move__process,
##      ],
##    ],
##    [
##      StatesEnum.Jump,
##      [
##        _state_jump,
##        _state_jump__process,
##      ],
##    ],
##  ]);
## [/codeblock]
func add_states_with_keys(collection: Array[Array]) -> void:
  for state_args in collection:
    var state_key: Variant = state_args[0];
    var state_callables: Array = state_args[1];
    for callable in state_callables:
      assert(callable is Callable,
        "State method was not of type Callable.");
    add_state(state_callables, state_key);


## Adds a [CallableState] object to the machine's dictionary of states.
func _add_callable_state_to_machine(state: CallableState) -> void:
  var machine_key: Variant = state.get_machine_key();

  assert(not _states_map.has(machine_key),
    "The machine already has an entry for key '%s'." % machine_key);

  _states_map.set(machine_key, state);


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
