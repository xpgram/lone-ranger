##
class_name HalfTimeCombatTimer
extends Node


##
signal timeout();


##
var _started := false;

##
var _real_time := 0.0;

##
var real_time_elapsed: float:
  get():
    return minf(_real_time, PartialTime.TURN_ELAPSE_LENGTH);

##
var real_time_left: float:
  get():
    return maxf(0, PartialTime.TURN_ELAPSE_LENGTH - _real_time);

##
var real_time_finished: bool:
  get():
    return _real_time >= PartialTime.TURN_ELAPSE_LENGTH;

## Increments independently of the real-timer, and only when explicitly incremented using
## [method add_time].
var _golem_time := 0.0;

##
var golem_time_elapsed: float:
  get():
    return minf(_golem_time, PartialTime.TURN_ELAPSE_LENGTH);

##
var golem_time_left: float:
  get():
    return maxf(0, PartialTime.TURN_ELAPSE_LENGTH - _golem_time);

##
var golem_time_finished: bool:
  get():
    return _golem_time >= PartialTime.TURN_ELAPSE_LENGTH;

##
var finished: bool:
  get():
    return real_time_finished or golem_time_finished;


func _process(delta: float) -> void:
  if not _started:
    return;
  _real_time += delta;
  _check_timer_limits();


##
func start() -> void:
  _started = true;


##
func start_and_reset() -> void:
  reset();
  start();


##
func pause() -> void:
  _started = false;


##
func stop() -> void:
  _started = false;
  reset();


##
func reset() -> void:
  _real_time = 0;
  _golem_time = 0;


##
func loop_timers() -> void:
  if _real_time >= PartialTime.TURN_ELAPSE_LENGTH:
    _real_time = 0;
  if _golem_time >= PartialTime.TURN_ELAPSE_LENGTH:
    _golem_time = 0;


##
func add_time(time: float) -> void:
  if not _started:
    return;
  _real_time += time;
  _golem_time += time;
  _check_timer_limits();


##
func _check_timer_limits() -> void:
  if real_time_finished or golem_time_finished:
    timeout.emit();
