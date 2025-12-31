extends Control

## The [HeartContainerUI] scene to instantiate when adding new heart containers.
const heart_container_scene := preload('uid://m04hk0pb15rg');


## The [Player2D] object to listen to for health changes.
@export var player2d: Player2D;

## The component measuring the player's current HP.
var _health_component: HealthComponent;

## The background element that sits behind the heart containers.
@onready var _hearts_back: NinePatchRect = %Background;

## The container that [HeartContainerUI]'s live in.
@onready var _hearts_hbox: HBoxContainer = %HBoxContainer;


func _ready() -> void:
  if not player2d:
    return;

  _health_component = Component.get_component(player2d, HealthComponent) as HealthComponent;

  _set_maximum_hearts(_health_component.meter.maximum);
  _on_health_changed(_health_component.meter.value);
  _health_component.meter.value_changed.connect(_on_health_changed);
  _health_component.meter.maximum_changed.connect(_set_maximum_hearts);


## Returns the number of [HeartContainerUI] children the health bar has.
func _get_num_hearts() -> int:
  return _hearts_hbox.get_child_count();


## Adds or removes [HeartContainerUI] children until their number matches the new
## [param max_health] value.
func _set_maximum_hearts(max_health: int, _old_max: int = 1) -> void:
  var desired_containers := int(ceilf(max_health / 2.0));
  desired_containers = maxi(0, desired_containers);

  _hearts_back.size.x = desired_containers * 16 + 16;

  while _get_num_hearts() != desired_containers:
    if _get_num_hearts() < desired_containers:
      var new_container := heart_container_scene.instantiate() as HeartContainerUI;
      new_container.fill_value = 0;
      _hearts_hbox.add_child(new_container);
    elif _get_num_hearts() > desired_containers:
      var last_container := _hearts_hbox.get_child(-1);
      _hearts_hbox.remove_child(last_container);
      last_container.queue_free();


## Iterates through all [HeartContainerUI] children, setting their individual fill values
## in accordance with their chunk of the new HP [param value].
func _on_health_changed(value: int, _old_value: int = 1) -> void:
  for i in range(_get_num_hearts()):
    var heart_value := value - (i * 2);
    var heart_container: HeartContainerUI = _hearts_hbox.get_child(i);
    heart_container.fill_value = heart_value;
