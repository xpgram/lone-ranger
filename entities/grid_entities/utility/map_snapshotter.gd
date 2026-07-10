

# [IMPLEMENT]
# Implementation will be some work, so here's the outline:
#
# Grid.set_tile_type(place, terrain_type, permanent: bool)
#
# [x] set_tile_type() logs all map changes into an undo/redo schedule.
# [ ] The undo/redo schedule is played back on board-reset events.
# [x] set_tile_type(..., permanent: bool) logs map changes in a save-file schedule.
#
# [ ] The Tail statue gets a pair-type collidable that Tail uses to discern
#     undoable from permanent map changes.
#     [ ] This pair-type is generalizable: it is a box-area that puts itself, or
#         a known child maybe, into each Grid spot it covers; Tail, on collision,
#         asks it for a message its been given, like `"tail-permanent"` or
#         `ColliderMessageEnum.TailPermanent`, or something like that.
#         I suppose we could also filter accepted collisions by telling it what
#         objects it's looking for. Tail would call
#         `collider_message.get_message(self)`, and `get_message()` would only
#         return something useful if `self` matches its criteria.
#
# DemonWall boss, seperate feature branch:
# [ ] These map changes will be undoable by default.
# [ ] The DemonWall entity is resettable unless the player reached the hallway end.
#
# Changing map details:
# [ ] Implement sub-TileMapLayers that can be drawn and used to paint into the
#     main one, like a stamp.
# [ ] A node (MapStamp?) exists to work with BooleanSpawner that, when loaded,
#     immediately stamps its sub-tilemap. And that map may be cleared as well.
#       - For now, this is not automatic, it just has a method call.
#         I think I'd prefer having a seperate blank stamp in the BooleanSpawner
#         to reset previous changes, for now.
# [ ] MapStamp has a yellow border describing its affected area.
# [ ] (stretch) MapSnapshot takes a 'picture' of a map area as-is and produces a
#     MapStamp for use later.
# [ ] MapStamp and/or BooleanSpawner:
#     [ ] Has a Default container that is respawned whether the persistence key
#         is true or false. The True/False containers are then loaded _after_.
#         (This allows me to more easily create modifications to existing loads,
#         like for TileMaps, where I actually want a messy, painted-over look
#         for narrative reasons.)
# The MapStamp / BooleanSpawner problem:
#   - There are a few ways of configuring this.
#       1. BooleanSpawner has MapStamp's in its various paint containers, and
#          a Default-container blank stamp.
#       2. MapStamp also has a default/true/false persistence key split, and
#          is simply kept in the nodetree near or even inside the BooleanSpawner,
#          just not in the spawner's own default/true/false containers.
#   - Idea 1 ought to be easier to implement, and should be good enough.
#   - Idea 2 may provide more opportunities for developer tools, though, like
#     easier previewing of the true/false states? This benefit is vague enough
#     that I think it's worth choosing idea 1 such that we can learn what it is
#     we want.
