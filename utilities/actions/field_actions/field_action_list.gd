class_name FieldActionList


const null_action: FieldAction = preload('uid://dkf6dygsavtxn');
const wait: FieldAction = preload('uid://cwwujnw5jfnb3');
const spin: FieldAction = preload('uid://c646h7fsdnvin');
const move: FieldAction = preload('uid://bek8qiwosvicd');
const move_fast: FieldAction = preload('uid://xqdq20a70cev');
const push: FieldAction = preload('uid://cremxf5c4fv6w');
const shove: FieldAction = preload('uid://dp3a2pno7lxyr');
const interact: FieldAction = preload('uid://qj4qft4xcnx6');
const sword_strike: FieldAction = preload('uid://cpg5b65k3mqjt');
const hookshot: FieldAction = preload('uid://dsu74k4p2n1x');


# [FIXME] This is annoying; can I pull a file list from a directory and find the .tres files?
#   I think I can just ask the .tres about its properties.
#   So, grab all of them, filter for the type==Magic, then assemble their names and uids here.
# [TODO] If an enum is a dictionary, I could write `enum Magic { Burn = preload('uid://...') }`, could I?
const Magic: Dictionary[StringName, FieldAction] = {
  'burn': preload('uid://m4rko02thteq'),
  'compact': preload('uid://bnxi3iwan6g35'),
  'grow': preload('uid://dx6yyw024ctch'),
  'move': preload('uid://72omta0cvh7l'),
  'raise': preload('uid://cswtlyl54v4ck'),
}
