## @tool [br]
##
## A [BaseComponent] to manage an entity's HP value. This component emits signals when its
## values change, which is the preferred method of checking the HP state.
@tool
class_name HealthComponent
extends IntMeterComponent

# There's nothing here.
# HealthComponent needs to be a unique class so that the [Component] system knows what
# key-name to register this component under.
