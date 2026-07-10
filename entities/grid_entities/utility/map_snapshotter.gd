

# [IMPLEMENT]
# Implementation will be some work, so here's the outline:
#
# Grid.set_tile_type(place, terrain_type, permanent: bool)
#
# This function gets a new parameter: permanent. If permanent is false, then
# Grid also sets this change into a map undo/redo schedule that can be played
# backwards on board resets. If permanent is true, the same change is put into
# a permanent schedule that is bundled with the player's save data.
#
# When you push a Tail statue into a pit, the TriggerBox will have to... signal
# something, I dunno, such that the Tail statue sets a permanent change instead
# of a temporary one.
#
# Maybe Tail can have a special collision-box entity that tells it to be
# permanent. Like, the Tail statue gets pushed, the TriggerBox reads the
# collision and sets a persistence key, then the Tail statue reads a collision
# from this Tail-permanence-box and sets permanence mode on, other stuff
# happens, and finally Tail is allowed to do its fall animation thing that
# includes changing the map state, now permanently.
#
# I wonder if this is generalizable, but I don't hate this idea. Tail can have
# its own pair box, I suppose.
#
# I'm trying to think if this covers all my bases, and... I think it does.
#
# Extending the MapLayer type to allow me to draw submaps that are paintable
# onto the main map according to persistence keys or otherwise would be really
# useful; it's something I'll need to do eventually anyway. And, having a similar
# tool that snapshots an area of the map as it is now to be painted later would
# also be nice. But, I don't think... either are necessary for this board-
# resetting Tail feature.
#
# It will be necessary for the Wall boss. That whole road needs to reset to
# baseline every single time the boss is reset to 'undefeated'.
#
# Unless I use submaps to redesign him such that he doesn't actually modify the
# map at all.
