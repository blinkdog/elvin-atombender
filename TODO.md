## Release TO DO
* Remove errant debugging calls hanging around
** Search all files for "alert"
** Search all files for "DEBUG"
** Search all files for "console"
** Search all files for "TODO"

# Development TO DO
* [X] Modify Player use routine to allow searching of furniture
* [ ] Add search rewards; puzzle pieces, lift/snooze passwords, etc.
* Modify GUI to display the puzzle pieces
* Modify AccessPanel routine to require the possession of 36 puzzle pieces in order to win the game
* Modify Player use routine to allow SecurityTerminal objects to temporarily lock the pit traps in a room
* Modify SecurityTerminal to lock and eventually unlock the pit traps
* Create Robot object
* Modify GameState to add Robot objects to game
* Modify Robot to move around, fire lightning, and be disabled
* Modify Player use routine to allow SecurityTerminal objects to temporarily disable the robots in a room
* Modify SecurityTerminal to disable and eventually reenable the robots
* Modify handleEvent in Player to allow pocket computer to hack pit trap locking passwords in exchange for time
* Modify handleEvent in Player to allow pocket computer to hack robot disable passwords in exchange for time
* Create DeathBall object
* Modify GameState to add DeathBall objects to game
* Modify DeathBall to seek out player
* Modify SecurityTerminal to disable and eventually reenable DeathBalls
* Modify pocket computer handling of puzzle pieces; allow swapping and rotation
* Modify pocket computer to dial for proper orientation and position in exchange for time
* Add storyline modal dialogs at the outset of the game

# Extra Time TO DO
* Modify Roomba to move so the player must chase it down to search it
