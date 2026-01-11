## TODO Write a doc string explaining how to use this class in a CallableStateMachine,
##   including instantiation and state method calls.
##
## [codeblock]
## state_machine.add_states([
##     CallableState.new([state_idle]),
##     CallableState.new([state_walking, state_walking_enter, state_walking_exit]),
##     CallableState.new([state_running, state_running_enter]),
## ]);
## [/codeblock]
##
## TODO Write a doc string explaining how to extend this class appropriately.
##
## Example:
##
## [codeblock]
## class PlayerCallableState extends CallableState:
##     func _get_role_keywords() -> Array[StringName]:
##         return super._get_role_keywords().append(
##           &'physics',
##         );
##
##     func physics_process(delta: float) -> void:
##         _call_role_func(&'physics', [delta]);
## [/codeblock]
class_name CallableState
extends RefCounted


## A map of function keywords to function callbacks.
var _methods: Dictionary[StringName, Callable];

## The dictionary key used by [CallableStateMachine] as the name for this state in its
## state map.
var _machine_key: Variant;


## Assembles a loose list of [param functions] related to the state into a new state
## object. [br]
##
## The given [param state_key] may explicitly set the name of this state as to its state
## machine, but by default, one of this state's behavior methods is chosen as its
## representative. See [method get_machine_key_role]. [br]
##
## Usage:
## [codeblock]
## state_machine.add_states([
##     CallableState.new([state_idle]),
##     CallableState.new([state_walking, state_walking_enter, state_walking_exit]),
##     CallableState.new([state_falling_enter, state_falling_exit], 'falling'),
## ]);
## [/codeblock]
##
## The behaviors the given functions are meant to fulfill (enter, exit, etc.) do not need
## to be explicitly stated, except by keywords contained at the end of each function's
## string name. [br]
##
## The default role keywords are 'enter', 'exit', 'process', and 'input', but more may be
## added by extending this class and overriding [method _get_role_keywords]. [br]
##
## The "default role" is special and does not actually require a keyword. By default, this
## is 'process', and is intended to reduce the noise of state switch requests. [br]
##
## This allows you to write:
## [codeblock]state_machine.switch_to(state_running);[/codeblock]
## Instead of:
## [codeblock]state_machine.switch_to(state_running_process);[/codeblock]
##
## [b]Note:[/b] 'process' and 'input' reflect standard Godot virtual methods and must have
## matching function signatures or they will break. [br]
##
## [codeblock]
## func process(delta: float) -> void;
## func input(event: InputEvent) -> void;
## [/codeblock]
func _init(functions: Array[Callable], state_key: Variant = null) -> void:
  _sort_functions_by_roles_into_methods_dict(functions);
  _set_state_machine_key(state_key, _methods);


## Returns a list of keywords that are used by the method solver to sort loose functions
## into their state callback roles.
func _get_role_keywords() -> Array[StringName]:
  return [
    &'process',
    &'input',
    &'enter',
    &'exit',
  ];


## Returns the default role keyword for any functions whose names do not match any defined
## role keywords.
func _get_default_role() -> StringName:
  return &'process';

## Returns the role keyword to use when fetching the state's default Callable-type machine
## key. That is, which of this state's behavior functions should be the "name" of this
## state in its state machine. By default, this is whichever role keyword is also the
## [method _get_default_role].
func _get_machine_key_role() -> StringName:
  return _get_default_role();


## Assigns functions to the methods dict under a key determined to represent their role
## in the state object.
func _sort_functions_by_roles_into_methods_dict(functions: Array[Callable]) -> void:
  for function in functions:
    var role := _get_function_role(function);
    assert(not _methods.has(role),
      "CallableState has already defined a callback method for '%s'." % role);
    _methods.set(role, function);


## Returns a role key for the [param function] that is the map-link between the function
## and the [CallableState] interface.
func _get_function_role(function: Callable) -> StringName:
  var func_name := function.get_method();
  var chosen_keyword := _get_default_role();

  for keyword in _get_role_keywords():
    if func_name.ends_with(keyword):
      chosen_keyword = keyword;
      break;
  
  return chosen_keyword;


## A helper method to assign this [CallableState]'s machine key, used by
## [CallableStateMachine] as this state's name.
func _set_state_machine_key(state_key: Variant, methods: Dictionary[StringName, Callable]) -> void:
  _machine_key = state_key if state_key else methods.get(_get_machine_key_role());
  assert(_machine_key != null,
    "A suitable machine key could not be determined. Either the state_key is null, or " \
    + "the machine-key behavior function is not defined.");


## Calls the behavior function associated with [param func_key], if it exists.
func _call_role_func(func_key: StringName, arguments: Array = []) -> void:
  if not _methods.has(func_key):
    return;
  _methods.get(func_key).callv(arguments);


## Calls and awaits the behavior function associated with [param func_key], if it exists.
func _call_role_func_async(func_key: StringName, arguments: Array = []) -> void:
  if not _methods.has(func_key):
    return;
  await _methods.get(func_key).callv(arguments);


## Returns the key used by [CallableStateMachine] to refer to this state in its records.
func get_machine_key() -> Variant:
  return _machine_key;


## Called when this state is transitioned [i]to.[/i] Useful for setting up systems that
## the state depends on.
func enter() -> void:
  _call_role_func(&'enter');


## Called when this state is transitioned [i]from,[/i] and before the next state's
## [method enter] call. Useful for tearing down systems that are no longer needed.
func exit() -> void:
  _call_role_func(&'exit');


## Must be called manually. Intended to be called inside a [Node._process] method.
func process(delta: float) -> void:
  _call_role_func(&'process', [delta]);


## Must be called manually. Intended to be called inside a [Node._input] or
## [Node._unhandled_input] method.
func input(event: InputEvent) -> void:
  _call_role_func(&'input', [event]);
