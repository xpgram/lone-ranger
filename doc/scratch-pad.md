#### Problem: Input is hard to manage across different systems

Move input from TurnManager into Player2D. Let's try something like this:

**Player2D**

- [x] get_inventory()
  - [x] asserts that _inventory exists
  - [x] returns _inventory
- [x] open_command_menu()
  - [x] calls _command_menu.open()
  - [x] inhibits own _unhandled_input until _command_menu is closed again
    - [x] Use a Control node, has_focus(), and accept_input() to manage this.
- [ ] injured()
  - [ ] calls _command_menu.close()
  - [ ] inhibits actions for a bit
- [ ] _send_action(action: FieldAction)
  - [x] Called by Player2D: move_up -> get_move_action() -> _send_action()
  - [x] Called by CommandMenu: selection -> send_selection() -> player2d._send_action() (via signal connection)
  - [x] TurnManager knows when to buffer an action cast
  - [ ] Player2D is responsible for player input, TurnManager only listens
  - [ ] TurnManager knows how to handle multiple buffer requests (it doesn't)
  - [ ] Player2D can be told (by TurnManager, by ContextActions, ...) to shutdown input handling.
    - [ ] Test: you can't cast Flame while opening a chest and victory posing.

**Inventory**

- [x] add()
- [x] remove()
- [x] get_magic_list(page: int)
- [x] get_item_list(page: int)

**CommandMenu**

- [x] open()
- [x] close()
- [x] _unhandled_input() that is active while self.is_open
- [x] polls Inventory as necessary for what items to display
- [x] emits signal containing FieldAction when something is selected