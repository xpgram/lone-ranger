class_name GridEntity
extends Node2D
# TODO Can enemies, which are moved by script, be CharacterBody2D's? I think so, right?

# TODO I see this script being inherited by movable players, enemies, interactible chests,
#   pushable blocks, etc. This is the GameObject class, essentially.
#   I'm not sure what I want from it yet, though.
#
#   Oh, I need some standard layer that allows enemies to be attacked, npcs to be talked
#   to, and most importantly, that they register themselves on the grid and care about
#   grid collisions and whatnot.
