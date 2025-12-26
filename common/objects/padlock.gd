## A readability class that abstracts the logic for a symbolic lock of any kind.
## For instance, you might use this to block calls to an async function while a previous
## call to it is still in progress.
class_name Padlock
extends RefCounted


## Whether this symbolic lock is currently locked.
var _locked := false;


## Returns true if this symbolic lock is currently engaged. [br]
## To lock a function call, it is preferable to use [method thread_locked].
func locked() -> bool:
  return _locked;


## Returns true if the lock is already locked, otherwise **locks this padlock** and
## returns false. This eases somewhat the burden of locking a process at the top of its
## function call. [br]
##
## Example:
## [codeblock]
## func some_method_async() -> void:
##     if padlock.thread_locked():
##         return;
##
##     # var data := await network.fetch('...');
##     # do_something_with_data(data);
##
##     padlock.unlock();
## [/codeblock]
func thread_locked() -> bool:
  if locked():
    return true;
  lock();
  return false;


## Engages this symbolic lock. [br]
## To be useful, the lock state must be observed with [method locked].
func lock() -> void:
  _locked = true;


## Disengages this symbolic lock. [br]
## To be useful, the lock state must be observed with [method locked].
func unlock() -> void:
  _locked = false;
