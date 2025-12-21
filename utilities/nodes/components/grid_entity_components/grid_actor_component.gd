## @tool [br]
##
## Component class for modeling GridEntity actor behavior, such as for enemies, NPCs, or
## passive-effect objects in the scene that should do something when their 'turn' is
## called. [br]
##
## This component does not define any behavior on its own and must be extended. Override
## [method act_async] to define this behavior. [br]
## 
## [method can_act] is used by the turn system and should not be overridden without a call
## to [code]super.can_act()[/code].
@tool
class_name GridActorComponent
extends BaseComponent


## Whether this GridEntity has acted this turn.
var _exhausted := false;


func _init() -> void:
  component_owner_changed.connect(update_configuration_warnings);


func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray;

  if get_component_owner() is not GridEntity:
    warnings.append("This component's owner should be a GridEntity node.");

  return warnings;


## Returns the [GridEntity] this object is a component to.
func get_entity() -> GridEntity:
  return get_component_owner();


## Readies this entity to act this turn.
func prepare_to_act() -> void:
  _exhausted = false;


## Returns true if this entity has acted this turn.
func has_acted() -> bool:
  return _exhausted;


## Returns true if this entity is eligible to act this turn. [br]
##
## Note that this is different from asking if this entity's desire to act in some way is
## performable. For such considerations, it is recommended to simply skip action and not
## call [method exhaust] in [method act_async].
##
## This method involves some deliberation over applied status effects and other contextual
## information. It is not recommended to override this method, but if you do, include a
## call to [code]super.can_act()[/code].
func can_act() -> bool:
  var grid_entity := get_entity();

  return (
    not has_acted()
    and not grid_entity.has_attribute('stun')
  );


## Acts out this enemy's turn. [br]
##
## When the entity is done acting, it should call [method exhaust] to mark itself as
## removable from any list of enemies still eligible to act. [br]
##
## If this entity was unable to act, do not call [method exhaust]; the turn system will
## give this entity another chance to act after others have moved, or will skip this
## entity by its own determination.
func act_async() -> void:
  exhaust();


## Marks this entity as 'spent', having consumed its action this turn. [br]
##
## This function must be called at some point during this entity's turn, if it has acted,
## or the turn system may allow it to take multiple turns at once.
func exhaust() -> void:
  _exhausted = true;
