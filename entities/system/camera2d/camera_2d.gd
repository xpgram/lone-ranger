class_name FollowCamera2D
extends Camera2D


const PAGE_SIZE_WIDTH := Constants.GRID_SIZE * 15;
const PAGE_SIZE_HEIGHT := Constants.GRID_SIZE * 9;

const PAGE_HOR_OFFSET := Constants.GRID_SIZE * -7;
const PAGE_VER_OFFSET := Constants.GRID_SIZE * -4;

const HALF_PAGE_SIZE_WIDTH := PAGE_SIZE_WIDTH * 0.5 - Constants.GRID_SIZE * 0.5;
const HALF_PAGE_SIZE_HEIGHT := PAGE_SIZE_HEIGHT * 0.5 - Constants.GRID_SIZE * 0.5;

enum FollowType {
  Instant,
  Close,
  Paged,
};

@export var subject: Node2D;
@export var follow_type := FollowType.Close;

@export var close_follow_lerp_speed := 16;
@export var paged_follow_speed := 768;


var _subpixel_position := Vector2();


func _process(delta: float) -> void:
  _follow_subject(delta);


func _follow_subject(delta: float) -> void:
  if not subject:
    return;

  var new_position: Vector2;

  match follow_type:
    FollowType.Instant:
      new_position = subject.position;

      # # Fix offset caused by UI bar
      new_position.y += 8;

      _subpixel_position = new_position;

    FollowType.Close:
      new_position = subject.position;

      # # Fix offset caused by UI bar
      new_position.y += 8;

      _subpixel_position = _subpixel_position.lerp(new_position, delta * close_follow_lerp_speed);

    FollowType.Paged:
      var page_vector := Vector2(PAGE_SIZE_WIDTH, PAGE_SIZE_HEIGHT);
      var half_page_vector := Vector2(HALF_PAGE_SIZE_WIDTH, HALF_PAGE_SIZE_HEIGHT);

      var subject_position := subject.position - Vector2(PAGE_HOR_OFFSET, PAGE_VER_OFFSET);
      new_position = (subject_position / page_vector).floor() * page_vector + half_page_vector;
      new_position += Vector2(PAGE_HOR_OFFSET, PAGE_VER_OFFSET);

      # # Fix offset caused by UI bar
      new_position.y += 8;

      _subpixel_position = _subpixel_position.move_toward(new_position, delta * paged_follow_speed);

  # Set to subpixel position or snap to destination.
  var distance := position.distance_to(new_position)
  position = new_position if distance < 0.5 else _subpixel_position;
