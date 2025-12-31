extends HBoxContainer

## The [HeartContainerUI] scene to instantiate when adding new heart containers.
const heart_container_scene := preload('uid://m04hk0pb15rg');


## The [Player2D] object to listen to for health changes.
@export var player2d: Player2D;

## The component measuring the player's current HP.
var _health_component: HealthComponent;


func _ready() -> void:
  if not player2d:
    return;

  _health_component = Component.get_component(player2d, HealthComponent) as HealthComponent;
  print('hp comp: ', _health_component);

  _set_maximum_hearts(_health_component.meter.maximum);
  _health_component.meter.value_changed.connect(_on_health_changed);
  _health_component.meter.maximum_changed.connect(_set_maximum_hearts);

  prints('HP:', _health_component.meter.value, '/', _health_component.meter.maximum);


## Returns the number of [HeartContainerUI] children the health bar has.
func _get_num_hearts() -> int:
  return get_child_count();


## Adds or removes [HeartContainerUI] children until their number matches the new
## [param max_health] value.
func _set_maximum_hearts(max_health: int, _old_max: int = 1) -> void:
  var desired_containers := int(ceilf(max_health / 2.0));
  desired_containers = maxi(0, desired_containers);

  while _get_num_hearts() != desired_containers:
    if _get_num_hearts() < desired_containers:
      var new_container := heart_container_scene.instantiate() as HeartContainerUI;
      new_container.fill_value = 0;
      add_child(new_container);
    elif _get_num_hearts() > desired_containers:
      var last_container := get_child(-1);
      remove_child(last_container);
      last_container.queue_free();


## Iterates through all [HeartContainerUI] children, setting their individual fill values
## in accordance with their chunk of the new HP [param value].
func _on_health_changed(value: int, _old_value: int = 1) -> void:
  for i in range(get_child_count()):
    var heart_value := value - (i * 2);
    var heart_container: HeartContainerUI = get_child(i);
    heart_container.fill_value = heart_value;
