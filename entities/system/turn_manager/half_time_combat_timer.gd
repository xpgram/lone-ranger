## A timer class to track and manage two different but inter-mixed kinds of accumulated
## game time. Real-time is accumulated via frame delta in the way you would expect a
## proper time-counting timer to behave. Golem-time, or puzzle-time, is accumulated
## exclusively via the method [method add_time]. [br]
##
## This mixed-time structure is important for coordinating the actions of certain
## [GridEntity] objects, which either observe one kind of game time or the other. [br]
##
## Unlike a typical timer, the limit for this timer is not set manually, but is specific
## to the game's turn system and obtained via [PartialTime] constants.
class_name HalfTimeCombatTimer
extends Node


## Emitted when either kind of game timer, real-time or golem-time, elapses.
signal timeout();


## Whether the timer is accumulating game time.
var _started := false;

## How many real-time seconds have passed since the timer was started.
var _real_time := 0.0;

## @readonly [br]
## How many real-time seconds have passed since the timer was started.
var real_time_elapsed: float:
  get():
    return minf(_real_time, PartialTime.TURN_ELAPSE_LENGTH);

## @readonly [br]
## The timer's remaining real-time seconds.
var real_time_left: float:
  get():
    return maxf(0, PartialTime.TURN_ELAPSE_LENGTH - _real_time);

## @readonly [br]
## Whether the timer's real-time seconds have elapsed their time limit.
var real_time_finished: bool:
  get():
    return _real_time >= PartialTime.TURN_ELAPSE_LENGTH;

## How many golem-time seconds have passed since the timer was started. [br]
var _golem_time := 0.0;

## @readonly [br]
## How many golem-time seconds have passed since the timer was started. [br]
var golem_time_elapsed: float:
  get():
    return minf(_golem_time, PartialTime.TURN_ELAPSE_LENGTH);

## @readonly [br]
## the timer's remaining golem-time seconds.
var golem_time_left: float:
  get():
    return maxf(0, PartialTime.TURN_ELAPSE_LENGTH - _golem_time);

## @readonly [br]
## Whether the timer's golem-time seconds have elapsed their time limit.
var golem_time_finished: bool:
  get():
    return _golem_time >= PartialTime.TURN_ELAPSE_LENGTH;

## @readonly [br]
## Wether the timer has elapsed its time limit, either via real-time or golem-time.
var finished: bool:
  get():
    return real_time_finished or golem_time_finished;


func _process(delta: float) -> void:
  if not _started:
    return;
  _real_time += delta;
  _check_timer_limits();


## Starts the timer.
func start() -> void:
  _started = true;


## Resets the timer's clocks and starts the timer.
func start_and_reset() -> void:
  reset();
  start();


## Stops the timer, but preserves its clock time.
func pause() -> void:
  _started = false;


## Stops and resets the timer's clocks.
func stop() -> void:
  _started = false;
  reset();


## Resets the timer's clocks.
func reset() -> void:
  _real_time = 0;
  _golem_time = 0;


## Resets only the timer's clocks which have elapsed their time limits. [br]
## For example, if the real-time clock has finished, but the golem-time clock has not,
## only the real-time clock will reset.
func loop_timers() -> void:
  if _real_time >= PartialTime.TURN_ELAPSE_LENGTH:
    _real_time = 0;
  if _golem_time >= PartialTime.TURN_ELAPSE_LENGTH:
    _golem_time = 0;


## Adds [param time] in seconds to both the timer's clocks, real-time and golem-time.
func add_time(time: float) -> void:
  if not _started:
    return;
  _real_time += time;
  _golem_time += time;
  _check_timer_limits();


## If either clock has elapsed the timer's limit, emits the [signal timeout] signal.
func _check_timer_limits() -> void:
  if real_time_finished or golem_time_finished:
    timeout.emit();
