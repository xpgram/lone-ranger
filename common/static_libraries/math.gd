## @static [br]
## A utility script for math constants and equations not built into Godot.
class_name Math


const HALF_PI := PI / 2;


## Returns either [param num], or the closest multiple of [param interval]
## if [param num] is within +/- [param threshhold] of that interval. [br]
##
## If [param threshhold] is <= 0, a multiple of [param interval] will always
## be returned.
static func snap_to_interval(num: float, interval: float, threshhold: float = 0.025) -> float:
  var nearest_interval := roundf(num / interval) * interval;

  threshhold = threshhold if (threshhold > 0) else interval;
  var should_snap: bool = (abs(num - nearest_interval) < threshhold);

  return nearest_interval if should_snap else num;
