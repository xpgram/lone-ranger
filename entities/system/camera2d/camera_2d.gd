class_name FollowCamera2D
extends Camera2D


const PAGE_SIZE_WIDTH := Constants.GRID_SIZE * 15;
const PAGE_SIZE_HEIGHT := Constants.GRID_SIZE * 9;

const PAGE_HOR_OFFSET := Constants.GRID_SIZE * -7;
const PAGE_VER_OFFSET := Constants.GRID_SIZE * -4;

const HALF_PAGE_SIZE_WIDTH := PAGE_SIZE_WIDTH * 0.5 - Constants.GRID_SIZE * 0.5;
const HALF_PAGE_SIZE_HEIGHT := PAGE_SIZE_HEIGHT * 0.5 - Constants.GRID_SIZE * 0.5;

enum FollowType {
  None,
  Instant,
  Close,
  Paged,
};

@export var subject: Node2D;
@export var follow_type := FollowType.Close;

@export var close_follow_lerp_speed := 16;
@export var paged_follow_speed := 768;


var _subpixel_position := Vector2();


var _position: Vector2 = position;
var _rotation: float = rotation;


func _ready() -> void:
  var new_position := subject.position;
  position = new_position;


func _process(delta: float) -> void:
  _follow_subject(delta);


func _unhandled_input(event: InputEvent) -> void:
  if not event.is_pressed() or not event is InputEventKey:
    return;

  # [FIXME] Debug controls.

  var key_event := event as InputEventKey;
  var move_speed := 0.1;
  var rot_speed := PI / 180;

  if key_event.keycode == KEY_BACKSLASH:
    follow_type = FollowType.None if follow_type != FollowType.None else FollowType.Close;

  if key_event.get_modifiers_mask() == KEY_MASK_SHIFT:
    if key_event.keycode == KEY_BRACKETLEFT:
      rotation += rot_speed;
    if key_event.keycode == KEY_BRACKETRIGHT:
      rotation -= rot_speed;
    rotation = Math.snap_to_interval(rotation, PI / 4.0, PI / 360.0);
  else:
    if key_event.keycode == KEY_BRACKETLEFT:
      position.x -= move_speed;
    if key_event.keycode == KEY_BRACKETRIGHT:
      position.x += move_speed;

  _notify_transform_changes();


func _follow_subject(delta: float) -> void:
  if not subject:
    return;

  var new_position: Vector2;

  match follow_type:
    FollowType.None:
      return;
    FollowType.Instant:
      new_position = subject.position;
      _subpixel_position = new_position;

    FollowType.Close:
      new_position = subject.position;
      _subpixel_position = _subpixel_position.lerp(new_position, delta * close_follow_lerp_speed);

    FollowType.Paged:
      var page_vector := Vector2(PAGE_SIZE_WIDTH, PAGE_SIZE_HEIGHT);
      var half_page_vector := Vector2(HALF_PAGE_SIZE_WIDTH, HALF_PAGE_SIZE_HEIGHT);

      var subject_position := subject.position - Vector2(PAGE_HOR_OFFSET, PAGE_VER_OFFSET);
      new_position = (subject_position / page_vector).floor() * page_vector + half_page_vector;
      new_position += Vector2(PAGE_HOR_OFFSET, PAGE_VER_OFFSET);

      _subpixel_position = _subpixel_position.move_toward(new_position, delta * paged_follow_speed);

  # Set the subpixel position to destination when very close.
  var close_distance_threshhold := 0.5;
  if abs(new_position.x - _subpixel_position.x) < close_distance_threshhold:
    _subpixel_position.x = new_position.x;
  if abs(new_position.y - _subpixel_position.y) < close_distance_threshhold:
    _subpixel_position.y = new_position.y;

  # Set the actual position.
  # The pixelation shader handles subpixel movement, so the camera's actual
  # subpixel position is discarded to avoid jittering.
  position = _subpixel_position.floor();

  _notify_transform_changes();


## Emit signals carrying the camera's position and rotation, if they have
## changed recently.
func _notify_transform_changes() -> void:
  if (_subpixel_position != _position):
    _position = _subpixel_position;
    Events.player_camera_position_changed.emit(_subpixel_position);

  if (rotation != _rotation):
    _rotation = rotation;
    Events.player_camera_rotation_changed.emit(rotation);
