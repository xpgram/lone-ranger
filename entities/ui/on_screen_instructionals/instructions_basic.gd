extends Label

@export var _trigger_box: TriggerBox;


var _alpha_tween: Tween;


func _ready() -> void:
  _trigger_box.entered.connect(_on_entered);
  _trigger_box.exited.connect(_on_exited);


func _on_entered(entity: GridEntity) -> void:
  if not entity is Player2D:
    return;

  if _alpha_tween:
    _alpha_tween.kill();

  _alpha_tween = get_tree().create_tween();
  _alpha_tween.set_trans(Tween.TRANS_QUAD);
  _alpha_tween.tween_property(self, 'modulate:a', 1.0, 1.5);


func _on_exited(entity: GridEntity) -> void:
  if not entity is Player2D:
    return;

  if _alpha_tween:
    _alpha_tween.kill();

  _alpha_tween = get_tree().create_tween();
  _alpha_tween.set_trans(Tween.TRANS_QUAD);
  _alpha_tween.tween_property(self, 'modulate:a', 0.0, 1.5);
