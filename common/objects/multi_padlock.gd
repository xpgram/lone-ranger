## A readability class that abstracts the logic for a symbolic lock with many components. [br]
##
## You might, for instance, use this to block calls to an async function while any one in
## a list of blocking processes are still in progress.
class_name MultiPadlock
extends RefCounted


## Emitted when a lock, named [param which], has been added to known locks.
signal locked(which: StringName);

## Emitted when a lock, named [param which], has been unlocked.
signal unlocked(which: StringName);

## Emitted when the first lock is added to a fully unlocked [MultiPadlock].
signal first_locked();

## Emitted when the last lock held by this [MultiPadlock] has been unlocked.
signal unlocked_all();


## The list of locks currently set on this [MultiPadlock].
var _locks := [] as Array[StringName];


## Returns true if this [MultiPadlock] is locked by at least 1 lock.
func is_locked(which := &"") -> bool:
  if which == &"":
    return _locks.size() > 0;
  else:
    return _locks.has(which);


## Returns true if a lock named [param which] is already set, otherwise  **sets this lock** and
## returns false. This eases somewhat the burden of locking a process thread at the top of its
## function call. [br]
##
## Example:
## [codeblock]
## func some_method_async() -> void:
##     if padlock.thread_locked():
##         return;
##     # var data := await network.fetch('...');
##     # do_something_with_data(data);
##
##     padlock.unlock();
## [/codeblock]
##
## [b]Note:[/b] The null StringName `&""` is never locked and should not be used.
func thread_locked(which: StringName) -> bool:
  if is_locked(which):
    return true;

  lock(which);
  return false;


## Returns when a lock named [param which] is added, or if it already is, returns
## immediately. [br]
##
## If [param which] is `&""`, instead considers the overall lock state and will return
## when any lock is added to this unlocked [MultiPadlock], or immediately if already locked.
func until_locked_async(which := &"") -> void:
  if not is_locked(which):
    if which == &"":
      await first_locked;
    else:
      var lock_name := &"";
      while lock_name != which:
        lock_name = await locked;

  return;


## Returns when a lock named [param which] is removed, or if it already was, returns
## immediately. [br]
##
## If [param which] is `&""`, instead considers the overall lock state and will return
## when the last lock in memory is removed, or if it already was, returns immediately.
func until_unlocked_async(which := &"") -> void:
  if is_locked(which):
    if which == &"":
      await unlocked_all;
    else:
      var lock_name := &"";
      while lock_name != which:
        lock_name = await unlocked;

  return;


## An alias for [code]until_locked_async(&"")[/code]. [br]
##
## Returns when the first lock is added to this MultiPadlock's memory, or if one already is,
## returns immediately.
func until_first_locked_async() -> void:
  await until_locked_async(&"");


## An alias for [code]until_unlocked_async(&"")[/code]. [br]
##
## Returns when the last lock is removed from this MultiPadlock's memory, or if it is already
## empty, returns immediately.
func until_all_unlocked_async() -> void:
  await until_unlocked_async(&"");


## Locks a lock named [param which], unless it was already locked.
##
## [b]Note:[/b] The null StringName `&""` is never locked and should not be used.
func lock(which: StringName) -> void:
  # Disallow the null StringName.
  if which == &"":
    return;

  if not _locks.has(which):
    _locks.append(which);

    if _locks.size() == 1:
      first_locked.emit();

    locked.emit(which);


## Unlocks a lock named [param which], if it was previously locked.
func unlock(which: StringName) -> void:
  if _locks.has(which):
    _locks.erase(which);
    unlocked.emit(which);

    if _locks.size() == 0:
      unlocked_all.emit();
