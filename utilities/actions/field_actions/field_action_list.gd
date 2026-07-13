## A collection of constants for each implemented [FieldAction]. Also contains
## accessors for lists of these constants by category.
class_name FieldActionList


## The [member null_action] represents the absence of a [FieldAction].
const null_action: FieldAction = preload('uid://dkf6dygsavtxn');


## All actions related to player input that don't involve opening the command
## menu.
static var all_movements: Dictionary[String, FieldAction]:
  get():
    return {
      'wait': wait,
      'spin': spin,
      'move': move,
      'move_fast': move_fast,
      'push': push,
      'shove': shove,
      'interact': interact,
      'sword_strike': sword_strike,
      'hookshot': hookshot,
    };
  set(value):
    pass


const wait: FieldAction = preload('uid://cwwujnw5jfnb3');
const spin: FieldAction = preload('uid://c646h7fsdnvin');
const move: FieldAction = preload('uid://bek8qiwosvicd');
const move_fast: FieldAction = preload('uid://xqdq20a70cev');
const push: FieldAction = preload('uid://cremxf5c4fv6w');
const shove: FieldAction = preload('uid://dp3a2pno7lxyr');
const interact: FieldAction = preload('uid://qj4qft4xcnx6');
const sword_strike: FieldAction = preload('uid://cpg5b65k3mqjt');
const hookshot: FieldAction = preload('uid://dsu74k4p2n1x');


## All castable skill actions resulting from artefacts or special abilities.
static var all_skills: Dictionary[String, FieldAction]:
  get():
    return {
      'sleep': skill_sleep,
    };
  set(value):
    pass


const skill_sleep := preload('uid://d3abxrfst60nr');


## All castable magic actions resulting from collected mana.
static var all_magic: Dictionary[String, FieldAction]:
  get():
    return {
      'burn': magic_burn,
      'compact': magic_compact,
      'grow': magic_grow,
      'move': magic_move,
      'raise': magic_raise,
    };
  set(value):
    pass


const magic_burn := preload('uid://m4rko02thteq');
const magic_compact := preload('uid://bnxi3iwan6g35');
const magic_grow := preload('uid://dx6yyw024ctch');
const magic_move := preload('uid://72omta0cvh7l');
const magic_raise := preload('uid://cswtlyl54v4ck');


## All castable item actions resulting from collected objects.
static var all_items: Dictionary[String, FieldAction]:
  get():
    return {
      'heart_vial': item_heart_vial,
    };
  set(value):
    pass


const item_heart_vial := preload('uid://c7tnmstfkbpqw');


## All [FieldActions].
static var all_field_actions: Dictionary[String, FieldAction]:
  get():
    var dict = { 'null_action': null_action };
    dict.merge(all_movements);
    dict.merge(all_skills);
    dict.merge(all_magic);
    dict.merge(all_items);
    return dict;
  set(value):
    pass
