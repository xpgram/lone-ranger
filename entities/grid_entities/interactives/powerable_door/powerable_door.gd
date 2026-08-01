class_name PowerableDoorEntity
extends Interactive2D


const _audio_gate_rise := preload('uid://boaohmhl4ak16');
const _audio_gate_lower := preload('uid://c8s66in3f1leb');


## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;


@onready var _anim: AnimatedSprite2D = %AnimatedSprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));
  _anim.frame_changed.connect(_on_sprite_frame_changed);

  _set_powered(false, true);


func _set_powered(value: bool, skip_animation := false) -> void:
  if _invert_power:
    value = !value;

  if value:
    if skip_animation:
      _anim.pause();
      _anim.frame = _anim.sprite_frames.get_frame_count('raise') - 1;
    else:
      _anim.play("raise");
      AudioBus.play_audio_scene(_audio_gate_rise);
  else:
    if skip_animation:
      _anim.pause();
      _anim.frame = 0;
    else:
      _anim.play_backwards("raise");
      AudioBus.play_audio_scene(_audio_gate_lower);

  # [TODO] Tell Grid to notify grid_position that a wall has appeared.
  #   Actually, what should happen when this does? And can it be cool enough
  #   to inspire clever puzzle tech?


func _on_sprite_frame_changed() -> void:
  solid = (_anim.frame != 0);
