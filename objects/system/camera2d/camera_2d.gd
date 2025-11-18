extends Camera2D


const PAGE_SIZE_WIDTH := Constants.GRID_SIZE * 3;
const PAGE_SIZE_HEIGHT := Constants.GRID_SIZE * 3;

const HALF_PAGE_SIZE_WIDTH := PAGE_SIZE_WIDTH * 0.5 - Constants.GRID_SIZE * 0.5;
const HALF_PAGE_SIZE_HEIGHT := PAGE_SIZE_HEIGHT * 0.5 - Constants.GRID_SIZE * 0.5;

@export var subject: Node2D;
@export var close_follow := false;


func _process(delta: float) -> void:
  if not subject:
    return;

  if close_follow:
    position = position.move_toward(subject.position, delta * 256);

  else:
    var page_vector := Vector2(PAGE_SIZE_WIDTH, PAGE_SIZE_HEIGHT);
    var half_page_vector := Vector2(HALF_PAGE_SIZE_WIDTH, HALF_PAGE_SIZE_HEIGHT);

    var new_position := (subject.position / page_vector).floor() * page_vector + half_page_vector;

    position = position.move_toward(new_position, delta * 1024);
