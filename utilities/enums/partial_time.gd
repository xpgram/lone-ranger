## An enum for common Partial Time values.
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
