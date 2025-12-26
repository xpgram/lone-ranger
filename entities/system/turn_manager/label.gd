extends Label


@export var _inaction_timer: HalfTimeCombatTimer;


func _process(_delta: float) -> void:
  text = 'Time Left: %04.1f' % _inaction_timer.real_time_left;
