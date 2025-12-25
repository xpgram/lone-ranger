## A class for managing simple but flexible state machines. [br]
##
## Usage: [br]
##
## [codeblock]
## var state_machine := CallableStateMachine.new('DemoMachine');
##
## # Add states to your state machine using simple functions.
## # Use Callable() where implementation is unnecessary.
## state_machine.add_state(state_idle, Callable(), Callable());
## state_machine.add_state(state_walking, state_walking_enter, state_walking_exit);
##
## # Switch to your initial state using the same process function it was added with.
## state_machine.switch_to(state_idle);
##
## # Remember to update your state machine:
## func _process(_delta: float) -> void:
##     state_machine.update();
##
## # Implementing Node-types can still get frame delta like this:
## var delta := get_process_delta_time();
## [/codeblock]
##
## @version 0.0.1
class_name CallableStateMachine
extends RefCounted


## A default state object.
var NULL_STATE := CallableState.new(Callable(), Callable(), Callable());

## The name of this state machine, for debugging purposes.
var _machine_name: String;

## The collection of known state objects. Each state is keyed under its own process
## Callable, and held as a [CallableState] record.
var _states_map := {} as Dictionary[Callable, CallableState];

## The [member _states_map] key for this machine's current state.
var _current_state := NULL_STATE.process;


## [param machine_name] The debug name for this state machine.
func _init(machine_name: String = 'Unknown State Machine') -> void:
  _machine_name = machine_name;


## Adds a set of state functions to the machine's dictionary of known states. [br]
##
## [param process] is both the key for this state in the states dictionary and this
## state's frame-update method, called whenever this machine's [method update] is called. [br]
##
## [param enter] is called whenever this state is transitioned to, before [param process]
## is called. [br]
##
## [param exit] is called whenever this state is transitioned from, before the next
## state's [param enter] is called.
func add_state(process: Callable, enter: Callable, exit: Callable) -> void:
  if _states_map.has(process):
    push_warning(_get_debug_metadata(), 'add_state is overwriting a known state key (%s).' % process.get_method());

  _states_map.set(process, CallableState.new(process, enter, exit));


## Changes the current state to the state associated with the [param process] Callable.
## If the change succeeds, this will call the exit method of the current state and the
## enter method of the next state, without calling the process method of the next state. [br]
##
## This will fail if [param process] is not associated with any states known to this state
## machine.
func switch_to(process: Callable) -> void:
  if not _states_map.has(process):
    push_warning(_get_debug_metadata(), 'Cannot switch_to to an unknown state key (%s).' % process.get_method());
    return;

  var last_state: CallableState = _states_map.get(_current_state, NULL_STATE);
  var next_state: CallableState = _states_map.get(process);

  last_state.exit.call();
  next_state.enter.call();
  _current_state = process;


## Calls the current state's process function. [br]
## Note that state transitions as a result of this call do not then run the process call
## for the next state.
func update() -> void:
  _current_state.call();


## Returns a string containing the class and machine name for this state machine.
func _get_debug_metadata() -> String:
  return "%s '%s': " % [get_class(), _machine_name];


## A struct to package related state callables.
class CallableState extends RefCounted:
  var enter := Callable();
  var process := Callable();
  var exit := Callable();

  @warning_ignore('shadowed_variable')
  func _init(update: Callable, enter: Callable, exit: Callable) -> void:
    self.enter = enter;
    self.process = update;
    self.exit = exit;
