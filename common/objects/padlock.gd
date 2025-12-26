## A readability class that abstracts the logic for a symbolic lock of any kind.
## For instance, you might use this to block calls to an async function while a previous
## call to it is still in progress.
class_name Padlock
extends RefCounted


## Whether this symbolic lock is currently locked.
var _locked := false;


## Returns true if this symbolic lock is currently engaged.
func locked() -> bool:
  return _locked;


## Engages this symbolic lock. [br]
## To be useful, the lock state must be observed with [method locked].
func lock() -> void:
  _locked = true;


## Disengages this symbolic lock. [br]
## To be useful, the lock state must be observed with [method locked].
func unlock() -> void:
  _locked = false;
