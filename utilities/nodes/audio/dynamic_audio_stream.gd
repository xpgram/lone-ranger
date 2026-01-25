class_name AudioStreamSwitch
extends Node


const _fade_out_interpolation_curve := preload('uid://dwn3atwa1dik0');
const _fade_in_interpolation_curve := preload('uid://bjgke0fspso64');


@export var exploration_track_scene: PackedScene;

@export var battle_track_scene: PackedScene;


var _exploration_track: AudioStreamPlayer;

var _battle_track: AudioStreamPlayer;

var _interpolation: float:
  set(value):
    _interpolation = clampf(value, 0.0, 1.0);
    _update_track_volumes();

var _enemy_presence_value := 0;

var _interpolation_tween: Tween;


func _ready() -> void:
  _exploration_track = exploration_track_scene.instantiate();
  _battle_track = battle_track_scene.instantiate();

  add_child(_exploration_track);
  add_child(_battle_track);

  _update_track_volumes();
  _start_music_async();

  Events.enemy_appeared.connect(_on_enemy_appeared);
  Events.enemy_disappeared.connect(_on_enemy_disappeared);


func _start_music_async() -> void:
  _battle_track.play();

  # TODO I need to make sure step-on triggers work and that's how this should trigger, not via time.
  await get_tree().create_timer(20.0).timeout;

  _exploration_track.play();


func _update_track_volumes() -> void:
  _exploration_track.volume_linear = _fade_out_interpolation_curve.sample(_interpolation);
  _battle_track.volume_linear = _fade_in_interpolation_curve.sample(_interpolation);


func _reset_tween() -> void:
  if _interpolation_tween:
    _interpolation_tween.kill();
  _interpolation_tween = get_tree().create_tween();


func _on_enemy_appeared() -> void:
  _enemy_presence_value += 1;

  if _enemy_presence_value == 1:
    _reset_tween();
    _interpolation_tween.tween_property(self, "_interpolation", 1.0, 0.5);
    _interpolation_tween.play();


func _on_enemy_disappeared() -> void:
  _enemy_presence_value -= 1;

  if _enemy_presence_value < 1:
    _reset_tween();
    _interpolation_tween.tween_property(self, "_interpolation", 0.0, 1.0);
