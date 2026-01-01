@tool
extends Node2D

const ARC_START_ANGLE := -PI / 2.0;
const LINE_WIDTH := 1.0;
const HALF_LINE_WIDTH := LINE_WIDTH / 2.0;
const CIRCLE_RADIUS := 7.0 - HALF_LINE_WIDTH;


var _real_time_remaining: float = 1.0;
var _golem_time_remaining: float = 7.5;


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  Events.real_time_updated.connect(_on_real_time_updated);
  Events.golem_time_updated.connect(_on_golem_time_updated);


func _draw() -> void:
  _draw_clock(_real_time_remaining, Vector2.ZERO);
  _draw_clock(_golem_time_remaining, Vector2(Constants.GRID_SIZE, 0));


## Handler for when the turn system's real-time is updated.
func _on_real_time_updated(remaining: float) -> void:
  _real_time_remaining = remaining;
  queue_redraw();


## Handler for when the turn system's golem-time is updated.
func _on_golem_time_updated(remaining: float) -> void:
  _golem_time_remaining = remaining;
  queue_redraw();


## Draws a debug clock at [param draw_position] with [param time_remaining] describing the
## gap.
func _draw_clock(time_remaining: float, draw_position: Vector2) -> void:
  var end_angle := _get_end_angle(time_remaining);

  draw_arc(
    draw_position,
    CIRCLE_RADIUS,
    ARC_START_ANGLE,
    end_angle,
    128,
    Color.WHITE,
    LINE_WIDTH,
    false,
  );


## Returns the end angle of a circle arc derived from [param time_remaining] in radians.
## The starting angle is given by [const ARC_START_ANGLE].
func _get_end_angle(time_remaining: float) -> float:
  var arc_proportion := time_remaining / PartialTime.TURN_ELAPSE_LENGTH;
  return (arc_proportion * TAU) + ARC_START_ANGLE;
