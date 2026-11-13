## A composite class to hold most private, operational player values, such as
## step counts. [br]
##
## Common public values, like current HP, may be better represented as a
## [Component] than kept here.
class_name PlayerStats
extends Resource


## How many air-steps, such as over pits, the player can make before falling. [br]
##
## It is generally understood that making a step while this value is 1 is safe,
## whereas making a step while it is 0 would trigger a fall.
@export var air_steps_remaining := IntMeter.new(0, 0);
