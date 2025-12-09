
The /common folder is for inter-game utilities and packages similar to what can be found
in /addons, but which are custom and may include tscn entities or other components not
typically found in an addons folder.

A semi-strict requirement for members of this folder space is that they should be self-
contained. This naturally makes sharing them between projects easier.

Suitable examples include:
 - A camera rigging system and its game-agnostic behavior scripts.
 - An object-component management and query system utilizing node metadata.

Maybe suitable examples:
 - A component utility for grid-based games that references a commonly used Grid API.

Arguably, for a grid component utility to be truly shareable, the Grid API must also be
shareable, even if its separate. So, /common objects can depend on other /common objects,
but nothing else.

I don't have any needs for this folder yet, so just think about it.
