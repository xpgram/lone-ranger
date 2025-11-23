#### Problem: Input is hard to manage across different systems

Move input from TurnManager into Player2D. Let's try something like this:

**Player2D**

- get_inventory()
  - asserts that _inventory exists
  - returns _inventory
- open_command_menu()
  - calls _command_menu.open()
  - inhibits own _unhandled_input until _command_menu is closed again
- injured()
  - calls _command_menu.close()
  - inhibits actions for a bit
- _send_action(action: FieldAction)
  - Called by Player2D: move_up -> get_move_action() -> _send_action()
  - Called by CommandMenu: selection -> send_selection() -> player2d._send_action() (via signal connection)

**Inventory**

- add()
- remove()
- get_magic_list(page: int)
- get_item_list(page: int)

**CommandMenu**

- open()
- close()
- _unhandled_input() that is active while self.is_open
- polls Inventory as necessary for what items to display
- emits signal containing FieldAction when something is selected