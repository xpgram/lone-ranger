## Represents an individual state for a [CallableStateMachine]. [br]
##
## This is a structural class to abstract the boilerplate of state subtypes and in most
## cases only needs to be loaded with references to its behavior functions. This allows
## behavior for different states to all be contained in a single script, improving
## developer context and ease of object-state management (i.e., blackboarding of common
## values). [br]
##
## Example:
## [codeblock]
## class_name Player2D extends Node2D
##
## var health := 100;
## var move_speed := 20;
##
## var state_machine := CallableStateMachine.new();
##
## func _ready() -> void:
##     # State behaviors are added to CallableStates as a loose list of functions.
##     # CallableState will sort these functions into their designated roles via function
##     # name keywords (details of this described further down).
##     state_machine.add_states([
##         CallableState.new([state_idle]),
##         CallableState.new([state_walking, state_walking__enter]),
##         CallableState.new([state_running, state_running__enter], 'running'),
##     ]);
##
##     # Sets the first state object.
##     state_machine.switch_to(state_idle);
##
##     # Alternatively, you can set a state's machine-reference key explicitly, as with
##     # state_running above:
##     state_machine.switch_to('running');
##
## func _process(delta: float) -> void:
##     # The state's methods, except for enter and exit, must be called manually.
##     state_machine.get_state().process(delta);
##
## # We will skip the implementation of state_idle, state_walking, and state_running.
## # Assume that they handle player input and movement.
##
## func state_walking__enter() -> void:
##     move_speed = 20;
##
## func state_running__enter() -> void:
##     move_speed = 30;
## [/codeblock]
##
##
## [b]Function Keyword Sorting[/b] [br]
##
## [CallableState] accepts a loose list of behavior functions when constructed and will
## automatically determine what purpose each function serves through keywords found at the
## end of its string name. [br]
##
## Unless extended, [CallableState] accepts four keywords by default, which when included
## in a function's name, must be preceded by two underscores '__'. Here is an example
## of each with their expected function signatures:
## [codeblock]
## func state_idle__enter() -> void;
## func state_idle__exit() -> void;
## func state_idle__process(delta: float) -> void;
## func state_idle__input(event: InputEvent) -> void;
## [/codeblock]
##
## These double-underscores help the interpreter understand where a keyword begins, but
## also provide clarity to the reader about which part is the state's name and which is
## the subprocess being defined. [br]
##
## Unless extended, [CallableState]'s process function is special in that it does not
## require a keyword: it is the default role for any behavior function without a keyword,
## and also serves as the state's machine key in its [CallableStateMachine].
## [codeblock]
## func state_idle(delta: float) -> void;
## state_machine.switch_to(state_idle);
## [/codeblock]
##
##
## [b]Extending CallableState[/b] [br]
##
## The behavior and number of role functions [CallableState] has can be modified,
## naturally, by extending the class. If we wanted to add a physics_process step in
## addition to the normal process step, we might do so like this:
## [codeblock]
## class KinematicState extends CallableState:
##     func _get_role_keywords() -> Array[StringName]:
##         return super._get_role_keywords() + [
##           &'physics',
##         ];
##
##     func physics_process(delta: float) -> void:
##         _call_role_func(&'physics', [delta]);
##
## # In the "Kinematic" object's physics step:
## func _physics_process(delta: float) -> void:
##     var state := state_machine.get_state() as KinematicState;
##     state.physics_process(delta);
## [/codeblock]
##
## The [CallableState]'s default role and machine-key role can also be modified by
## overriding private _get functions in the base class.
## [codeblock]
## func _get_default_role() -> StringName;
## func _get_machine_key_role() -> StringName;
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
##     CallableState.new([state_walking, state_walking__enter, state_walking__exit]),
##     CallableState.new([state_falling__enter, state_falling__exit], 'falling'),
## ]);
## [/codeblock]
##
## The behaviors the given functions are meant to fulfill (enter, exit, etc.) do not need
## to be explicitly stated, except by keywords contained at the end of each function's
## string name. Note that these keywords must be preceded by two underscores '__' to
## separate them from the state's name. [br]
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
## [codeblock]state_machine.switch_to(state_running__process);[/codeblock]
##
## [b]Note:[/b] 'process' and 'input' reflect standard Godot virtual methods and must have
## matching function signatures or they will break. [br]
##
## [codeblock]
## func state_example__process(delta: float) -> void;
## func state_example__input(event: InputEvent) -> void;
## [/codeblock]
func _init(functions: Array[Callable], state_key: Variant = null) -> void:
  _sort_functions_by_roles_into_methods_dict(functions);
  _set_state_machine_key(state_key, _methods);


## Returns a list of keywords that are used by the method solver to sort loose functions
## into their state callback roles. [br]
##
## If you are overriding the available keywords, you will need to provide new accessor
## functions for them. Here's an example which adds a physics_process step to the standard
## set:
## [codeblock]
## class KinematicState extends CallableState:
##     func _get_role_keywords() -> Array[StringName]:
##         return super._get_role_keywords() + [
##           &'physics',
##         ];
##
##     func physics_process(delta: float) -> void:
##         _call_role_func(&'physics', [delta]);
##
## # In the "Kinematic" object's physics step:
## func _physics_process(delta: float) -> void:
##     var state := state_machine.get_state() as KinematicState;
##     state.physics_process(delta);
## [/codeblock]
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

    if _methods.has(role):
      var present_func_string: String = _methods.get(role).get_method();
      var incoming_func_string: String = function.get_method();
      var error_message := (
        "CallableState has already defined a callback method for '%s': ('%s' -> '%s')."
        % [role, present_func_string, incoming_func_string]
      );
      assert(false, error_message);

    _methods.set(role, function);


## Returns a role key for the [param function] that is the map-link between the function
## and the [CallableState] interface.
func _get_function_role(function: Callable) -> StringName:
  var func_name := function.get_method();
  var chosen_keyword := _get_default_role();

  for keyword in _get_role_keywords():
    var token := _convert_to_role_token(keyword);
    if func_name.ends_with(token):
      chosen_keyword = keyword;
      break;

  return chosen_keyword;


## Used by [CallableState] internally to get the syntax-correct function name token that
## identifies which role a function is to be sorted into.
func _convert_to_role_token(role: String) -> StringName:
  return (
    role if role.begins_with('__')
    else '__' + role
  );


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
