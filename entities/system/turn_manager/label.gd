extends Label


@onready var inaction_timer: Timer = %InactionTimer;


func _process(_delta: float) -> void:
  text = 'Time Left: %04.1f' % inaction_timer.time_left;
