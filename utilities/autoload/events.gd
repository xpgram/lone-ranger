extends Node

@warning_ignore_start('UNUSED_SIGNAL')

## Notifies listeners that a node now exists.
## This is useful, for instance, to allow nodes of some type to be listened for by
## NodeContainer layers, who will add such nodes to their own list of children.
signal node_created(entity: Node);
