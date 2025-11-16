extends InteractiveGridEntity

##
@export var contents: String;

## Whether this Chest has been opened.
var is_open := false;

## The display image for this Grid entity.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D;


func can_interact(initiator: GridEntity) -> bool:
  var initiated_from_below := (grid_position + Vector2i.DOWN == initiator.grid_position);
  var entity_facing_self := (initiator.facing_direction == Vector2i.UP);

  return not is_open and initiated_from_below and entity_facing_self;


func perform_interaction_async(initiator: GridEntity) -> void:
  animated_sprite.play('open');

  print('%s obtained a %s...' % [initiator.name, contents]);
  # TODO contents is a struct type, including... I guess I'm not sure.
  # TODO initiator.has_node('Inventory')
  # TODO initiator.inventory.add(contents.item * contents.number)

  var dirs := [
    Vector2i.RIGHT,
    Vector2i.UP,
    Vector2i.LEFT,
    Vector2i.DOWN,
  ];

  initiator.facing_direction = Vector2i.DOWN;
  await get_tree().create_timer(0.25).timeout;

  for dir in dirs:
    initiator.facing_direction = dir;
    await get_tree().create_timer(0.05).timeout;

  await get_tree().create_timer(0.25).timeout;
