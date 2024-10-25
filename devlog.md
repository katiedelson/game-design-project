# Fall 2024 - Intro to Game Design @ SUNY New Paltz
* Name: Katherine Edelson
* [Trello Board](https://trello.com/b/gwO14hWe)
* [Proposal](proposal.pdf)
* [Other docs](todo)

### 2024.10.25 - 4 hrs: Updated sprite & tileset
* gave the player clothes
* added color to map

### 2024.10.22 - 1hr: Updated level & added text instructions & clarification
* changed level & preventing falling off
* added text instructions to help guide playtesting
* player was "walking" in air when falling (not prompted by jump) so added new if statement in player script
* added physics bridge to test level, need player input (pretty glitchy)

### 2024.10.15 - 5hrs: More power line tests & updated wall jump
* tested sliding on powerlines, didn't find any tutorials so I tried using chat gpt. Achieved sliding, but
  movement was buggy. Removed and will restart in the future.
* tested a physics bridge with RigidBody2D's and PinJoint2D's. Was cool, but it was too glitchy (may revisit later)
* made it so you can jump with W, and now S to slide down
* added double jump
* found issue where double jump wouldn't reset on umbrella's (doesn't have a collider), so I called a function I made
  called "reset_double_jump" in the umbrella's script
* removed directional input from wall jump to make it smoother & faster.
* needed new method to prevent wall scaling, so I added a var to keep track of the last wall side jumped
  on (left vs right) and a "can_attach_to_wall()" function. Then I added new conditions to the jumps to only allow
  the player to latch onto the wall if they're coming from the opposite wall
* found issue where the player enters the wall state on an "invisible wall" parallel to the wall the player's
  back is up against, still need to fix
* found issue where last wall jumped wouldn't reset on umbrellas (no colliders) so called "reset_last_wall" in umbrella's
  script
* prevented character from grabbing onto invisibile wall on ledge by raising RayCast2D on character

### 2024.10.14 - 2hrs: Started on power lines & other updates
* created power line platform scene & added it to my level
* made it a one way collider, and added script to allow S key to drop down from it

### 2024.10.12 - 1hr: Fixed previous issues with wall jump & sliding
* added a slide state so that sliding after timer and sliding on command didn't interfere
* deleted the last_jump_direction var and added another Raycast2d and changed is_near_wall() function to
  have is_near_left_wall() and is_near_right_wall(). Used these to prevent wall scaling and issue with previous
  method where falling on same wall after wall jumping doesn't allow another jump in the same direction

### 2024.10.09 - 5hrs: Updated wall jumping & sliding and improved umbrellas
* found out a way to lock horizontal movement when in wall state
* made it so you hold onto the wall for a few seconds before you start sliding down the wall
* added wall grab sprite
* made it so you can press the "f" key to slide on command
* made the amount you bouce relative to the height you fall at, with the condition that the player has to be falling
  to activate the bounce, so you cannot jump on it from the bottom

### 2024.10.07 - 5hrs: Overhauled player physics code, finished wall jumping & sliding, started on bouncing mechanic
* redid the player phsyics code w/ a state machine (different states being Air, Floor, and Wall)
* ran into trouble with character "walking-off" wall before jump input, wouldn't let me stop horizontal movement while
  on a wall. I tweaked it to be a little smoother- it's still finicky, but it works.
* edited wall sliding mechanic so that the sliding speed gradually increases the longer you stay on the wall.
* started on bounce mechanic for the umbrellas. I imported a basic umbrella sprite I made prior and made the code 
  change the players y velocity when entering the Area2D collision shape attached to the umbrella
* would like to find a way to have bounce force depend on the height the player falls onto it, but for now it works as
  intended
* need to sort out tilemap & collision layers in order to start working on the powerline sliding mechanic.
* later added idle and wall jump sprites
* found issue where if you jump and land on same wall, it doesn't let you jump again since that was the last direction
  jumped

### 2024.10.05 - 4hrs: Set up test tilemap & started on wall jumping & sliding
* put together basic level with custom tileset I already had made prior
* found tutorial: and https://www.youtube.com/watch?v=2PiMrxGP2_o which will help me with the wall jump mechanic
* ran into some problems with the is_on_wall() func as I wanted it to be true if it was
  near wall rather than actively running into, found more indepth tutorial https://www.youtube.com/watch?v=CStyW2aTBSo
  which helped create separate function is_near_wall with a RayCast2D node
* having issues with smoothness & code organization, might overhaul the given script for player physics

### 2024.09.24 - 2hrs: Set up repo, itch.io, trello, and this!
* need to make new ssh key without passphrase :(
