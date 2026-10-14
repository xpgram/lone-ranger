## @static [br]
## A utility script for math constants and equations not built into Godot.
class_name Math


const HALF_PI := PI / 2;


static func snap_to_interval(to_snap: float, interval: float, threshhold: float = 0.025) -> float:
  var nearest_interval := roundf(to_snap / interval) * interval;
  var should_snap: bool = (abs(to_snap - nearest_interval) < threshhold);

  return nearest_interval if should_snap else to_snap;
