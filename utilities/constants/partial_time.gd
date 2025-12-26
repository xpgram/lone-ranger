## @static [br]
## A collection of common Partial Time constants.
##
## Partial Time describes fractions of turn-"seconds" measured in real-time seconds.
## All PartialTime values are measured in real-time, but are named according to their
## in-game, turn-based equivalents.
##
## For example, `PartialTime.FULL` is one in-game "second" made up of more than one
## real-time seconds.
class_name PartialTime

## The default number of real-time seconds for a player turn to elapse.
## Note that other values, FULL, HALF, etc., are real-time fractions of this number.
const TURN_ELAPSE_LENGTH := 15.0;

const FULL      := TURN_ELAPSE_LENGTH * 1.0;
const MOST      := TURN_ELAPSE_LENGTH * 0.75;
const HALF      := TURN_ELAPSE_LENGTH * 0.5;
const QUARTER   := TURN_ELAPSE_LENGTH * 0.25;
const NONE      := TURN_ELAPSE_LENGTH * 0.0;


## An enum for common [PartialTime] lengths. [br]
##
## This type exists for developer-UI purposes, such as the inspector, and should otherwise
## be unnecessary. [br]
##
## To get the equivalent real-time seconds for each enum value, either reference them
## directly (e.g. [member PartialTime.HALF]), or use [method PartialTime.enum_to_seconds].
enum TimeSegment {
  NONE,
  QUARTER,
  HALF,
  MOST,
  FULL,
};


## A dictionary that maps [TimeSegment] values to their real-time second equivalents.
static var _conversion_dict: Dictionary[TimeSegment, float] = {
  TimeSegment.NONE: NONE,
  TimeSegment.QUARTER: QUARTER,
  TimeSegment.HALF: HALF,
  TimeSegment.MOST: MOST,
  TimeSegment.FULL: FULL,
};


## Returns the number of real-time seconds that are equivalent to [param time_segment].
static func enum_to_seconds(time_segment: TimeSegment) -> float:
  return _conversion_dict[time_segment];
