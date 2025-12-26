## @static [br]
## A utility script containing commonly referenced enums.
class_name Enums


enum FieldActionType {
  ## A learned skill or technique.
  Ability,
  ## A castable spell drawn from mana in the world.
  Magic,
  ## A useful object with varied purpose.
  Item,
  ## A special item, often with scripted uses.
  KeyItem,
};


enum LimitedUseType {
  ## Abilities have unlimited uses.
  NoLimit,
  ## Item usage is limited to quantity held.
  Quantity,
  ## Magic usage is limited via the magic draw system.
  ## Works like `Quantity`, but may be affected by certain artifacts.
  MagicDraw,
  ## Key items have special, usually scripted usage limits.
  KeyItem,
};
