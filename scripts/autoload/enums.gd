extends Node


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
