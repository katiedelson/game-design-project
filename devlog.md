# Fall 2024 - Intro to Game Design @ SUNY New Paltz
* Name: Katherine Edelson
* [Trello Board](https://trello.com/b/gwO14hWe)
* [Proposal](proposal.pdf)
* [Other docs](todo)

### 2024.10.09 - 5hrs: Updated wall jumping & sliding and improved umbrellas
* found out a way to lock horizontal movement when in wall state
* made it so you can only hold onto the wall for a few seconds before you start sliding down the wall
* added wall grab sprite
* made it so you can press the "f" key to slide on command
* made the amount you bouce relative to the height you fall at, with the condition that the player has to be falling
  to activate the bounce, so you cannot jump on it from the bottom

### 2024.10.07 - 5hrs: Overhauled player physics code, finished wall jumping & sliding, started on bouncing mechanic
* redid the player phsyics code w/ a state machine (different states being Air, Floor, and Wall)
* ran into trouble with character "walking-off" wall before jump input, wouldn't let me stop horizontal movement while
  on a wall. I tweaked it to be a little smoother- it's still finicky, but it works.
* edited wall sliding mechanic so that the sliding speed gradually increases the longer you stay on the wall.
* started on bounce mechanic for the umbrellas. I imported a basic umbrella sprite I made prior and made the code change the
  players y velocity when entering the Area2D collision shape attached to the umbrella
* would like to find a way to have bounce force depend on the height the player falls onto it, but for now it works as
  intended
* need to sort out tilemap & collision layers in order to start working on the powerline sliding mechanic.
* later added idle and wall jump sprites

### 2024.10.05 - 4hrs: Set up test tilemap & started on wall jumping & sliding
* put together basic level with custom tileset I already had made prior
* found tutorial: and https://www.youtube.com/watch?v=2PiMrxGP2_o which will help me with the wall jump mechanic
* ran into some problems with the is_on_wall() func as I wanted it to be true if it was
  near wall rather than actively running into, found more indepth tutorial https://www.youtube.com/watch?v=CStyW2aTBSo
  which helped create separate function is_near_wall with a RayCast2D node
* having issues with smoothness & code organization, might overhaul the given script for player physics

### 2024.09.24 - 2hrs: Set up repo, itch.io, trello, and this!
* need to make new ssh key without passphrase :(
