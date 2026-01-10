## A class for managing simple but flexible state machines. [br]
##
## Usage: [br]
##
## [codeblock]
## var state_machine := CallableStateMachine.new('DemoMachine');
##
## # Add states to your state machine using a dictionary of simple functions.
## # The add_state() solver will identify which functions are for what automatically by
## # how their method name ends. Does that give your mouth a sour taste? I'm aware.
## state_machine.add_state(state_idle);
## state_machine.add_state(state_walking, state_walking_enter, state_walking_exit);
##
## # Switch to your initial state using the same process function it was added with.
## state_machine.switch_to(state_idle);
##
## # Or switch states with a key you've set yourself.
## state_machine.add_keyed_state('idle', state_idle_enter);
## state_machine.switch_to('idle');
##
## # Remember to process your state machine:
## func _process(delta: float) -> void:
##     state_machine.process(delta);
##
## # Don't worry if the current state has no defined behavior for a particular machine
## # call; missing behavior is stepped-over automatically.
## func _unhandled_input(event: InputEvent) -> void:
##     state_machine.input(event);
## [/codeblock]
## @version 0.1.0
class_name CallableStateMachine
extends RefCounted


## A [Callable] used for culling non-provided callables.
const NULL_CALLABLE := Callable();

## The default state object.
var NULL_STATE := CallableState.new({});

## An enum to represent individual state functions.
enum StateMethod {
  Enter,
  Exit,
  Process,
  Physics,
  Input,
};


## The name of this state machine, for debugging purposes.
var _machine_name: String;

## The collection of known state objects.
var _states_map := {} as Dictionary[Variant, CallableState];

## The current [CallableState] object fulfilling the [CallableStateMachine]'s operations.
var _current_state := NULL_STATE;


## [param machine_name] The debug name for this state machine.
func _init(machine_name: String = 'Unknown State Machine') -> void:
  _machine_name = machine_name;


## Adds a family of state functions to the machine's dictionary of known states. [br]
##
## Usage example:
## [codeblock]add_state(state_idle, state_idle_enter, state_idle_input);[/codeblock]
##
## The provided functions are sorted automatically into their roles by keywords given at
## the end of their function names. I am perfectly aware that this makes you
## uncomfortable. [br]
##
## How that works: [br]
## (Note that having function names begin with 'state' is merely a convention.) [br]
##
## A function ending in 'enter' will be called when a state is transitioned [i]to.[/i]
## Useful for setting up systems the state depends on.
## [codeblock]state_idle_enter() -> void; [/codeblock]
##
## A function ending in 'exit' will be called when a state is transitioned [i]from,[/i]
## and just before the next state's enter method is called. Useful for tearing down
## systems that are no longer needed.
## [codeblock]state_idle_exit() -> void; [/codeblock]
##
## A function ending in no keyword, or the keyword 'process', will be called when the
## state machine's [method process] is called. This function will also be the
## [method switch_to] key for this state in the state dictionary.
## [codeblock]
## state_idle(delta: float) -> void;
## state_idle_process(delta: float) -> void;
## [/codeblock]
##
## A function ending in 'physics' or 'physics_process' will be called when the state
## machine's [method physics_process] is called.
## [codeblock]
## state_idle_physics(delta: float) -> void;
## state_idle_physics_process(delta: float) -> void;
## [/codeblock]
##
## A function ending in 'input' will be called when the state machine's [method input] is
## called.
## [codeblock]state_idle_input(event: InputEvent) -> void; [/codeblock]
func add_state(
    f1: Callable,
    f2: Callable = NULL_CALLABLE,
    f3: Callable = NULL_CALLABLE,
    f4: Callable = NULL_CALLABLE,
    f5: Callable = NULL_CALLABLE,
) -> void:
  var function_args: Array[Callable] = [f1, f2, f3, f4, f5];
  var methods_dict := _build_state_methods_dict(function_args);
  var state_key: Variant = _get_state_key(methods_dict);
  _create_and_add_state_to_map(state_key, methods_dict);


## Adds a family of state functions to the machine's dictionary of known states under the
## key [param state_key]. [br]
##
## Usage example:
## [codeblock]add_state('idle', state_idle, state_idle_enter, state_idle_input);[/codeblock]
##
## The provided functions are sorted automatically into their roles by keywords given at
## the end of their function names. I am perfectly aware that this makes you
## uncomfortable. [br]
##
## How that works: [br]
## (Note that having function names begin with 'state' is merely a convention.) [br]
##
## A function ending in 'enter' will be called when a state is transitioned [i]to.[/i]
## Useful for setting up systems the state depends on.
## [codeblock]state_idle_enter() -> void; [/codeblock]
##
## A function ending in 'exit' will be called when a state is transitioned [i]from,[/i]
## and just before the next state's enter method is called. Useful for tearing down
## systems that are no longer needed.
## [codeblock]state_idle_exit() -> void; [/codeblock]
##
## A function ending in no keyword, or the keyword 'process', will be called when the
## state machine's [method process] is called. This function will also be the
## [method switch_to] key for this state in the state dictionary.
## [codeblock]
## state_idle(delta: float) -> void;
## state_idle_process(delta: float) -> void;
## [/codeblock]
##
## A function ending in 'physics' or 'physics_process' will be called when the state
## machine's [method physics_process] is called.
## [codeblock]
## state_idle_physics(delta: float) -> void;
## state_idle_physics_process(delta: float) -> void;
## [/codeblock]
##
## A function ending in 'input' will be called when the state machine's [method input] is
## called.
## [codeblock]state_idle_input(event: InputEvent) -> void; [/codeblock]
func add_keyed_state(
    state_key: Variant,
    f1: Callable,
    f2: Callable = NULL_CALLABLE,
    f3: Callable = NULL_CALLABLE,
    f4: Callable = NULL_CALLABLE,
    f5: Callable = NULL_CALLABLE,
) -> void:
  var function_args: Array[Callable] = [f1, f2, f3, f4, f5];
  var methods_dict := _build_state_methods_dict(function_args);
  _create_and_add_state_to_map(state_key, methods_dict);


## Changes the current state to the state associated with [param state_key].
## If the change succeeds, this will call the exit method of the current state and the
## enter method of the next state, without calling the process method of the next state. [br]
##
## This will fail if [param state_key] is not associated with any states known to this state
## machine.
##
## If states were added with [method add_state], then the [param state_key] for that state
## would be its 'process' callable.
func switch_to(state_key: Variant) -> void:
  if not _states_map.has(state_key):
    push_warning(
      _get_debug_metadata(),
      'Cannot switch_to() an unknown state key (%s).' % _get_string_from_state_key(state_key)
    );
    return;

  var next_state: CallableState = _states_map.get(state_key);

  _current_state.callv_func(StateMethod.Exit);
  next_state.callv_func(StateMethod.Enter);
  _current_state = next_state;


## Calls the current state's process function. [br]
## Note that state transitions as a result of this call do not then run the process call
## for the next state in the same frame.
func process(delta: float) -> void:
  _current_state.callv_func(StateMethod.Process, [delta]);


## Calls the current state's physics_process function. [br]
## Note that state transitions as a result of this call do not then run the
## physics_process call for the next state in the same frame.
func physics_process(delta: float) -> void:
  _current_state.callv_func(StateMethod.Physics, [delta]);


## Calls the current state's input handler function. [br]
## Note that state transitions as a result of this call do not then run the input call for
## the next state in the same frame.
func input(event: InputEvent) -> void:
  _current_state.callv_func(StateMethod.Input, [event]);


## Creates a dictionary of [CallableState] functions from a loose array of functions.
## A solver is used to automatically determine what role each function occupies, and the
## function is stored in the resulting dictionary under the key for that role.
func _build_state_methods_dict(functions: Array[Callable]) -> Dictionary[StateMethod, Callable]:
  var methods_dict: Dictionary[StateMethod, Callable];

  for function in functions:
    var func_key := _get_func_key_from_function(function);

    if methods_dict.has(func_key):
      push_error(
        _get_debug_metadata(),
        'The assembled state has double-defined a behavior callback (%s).' % func_key,
      );
    methods_dict.set(func_key, function);

  return methods_dict;


## Creates a [CallableState] from [param methods] and assigns it to the
## [member _states_map] under the key [param state_key].
func _create_and_add_state_to_map(state_key: Variant, methods: Dictionary[StateMethod, Callable]) -> void:
  if _states_map.has(state_key):
    push_error(
      _get_debug_metadata(),
      'The state key already exists (%s).' % _get_string_from_state_key(state_key),
    );

  var state := CallableState.new(methods);
  _states_map.set(state_key, state);


## Returns a key for a [CallableState] dictionary of state functions.
func _get_func_key_from_function(function: Callable) -> StateMethod:
  var string_name := function.get_method();

  if string_name.ends_with('enter'):
    return StateMethod.Enter;
  elif string_name.ends_with('exit'):
    return StateMethod.Exit;
  elif string_name.ends_with('physics') or string_name.ends_with('physics_process'):
    return StateMethod.Physics;
  elif string_name.ends_with('input'):
    return StateMethod.Input;
  else:
    return StateMethod.Process;


## Returns the key value used to refer to a state in the state dictionary. Raises an error
## if no key could be determined.
func _get_state_key(methods_dict: Dictionary[StateMethod, Callable]) -> Variant:
  var key = methods_dict.get('process');

  assert(key != null,
    'The given state dictionary has no process callable to use as a reference key. The dictionary given: %s' % methods_dict);

  return key;


## Returns a string representation of the key for a state collection.
func _get_string_from_state_key(key: Variant) -> String:
  return (
    key.get_method() if key is Callable
    else String(key)
  );


## Returns a string containing the class and machine name for this state machine.
func _get_debug_metadata() -> String:
  return "%s '%s': " % [get_class(), _machine_name];


## A class to package related state callables.
class CallableState extends RefCounted:
  var _methods: Dictionary[StateMethod, Callable];


  ## [param methods] A dictionary of related state functions.
  func _init(methods: Dictionary[StateMethod, Callable]) -> void:
    _methods = methods;


  ## Calls the state method associated with [param func_key] and passes in all arguments
  ## contained in the [param arguments] array.
  func callv_func(func_key: StateMethod, arguments: Array = []) -> void:
    var state_func: Callable = _methods.get(func_key);
    if state_func:
      state_func.callv(arguments);
