# Release TO DO
* Remove errant debugging calls hanging around
** Search all files for "alert"
** Search all files for "DEBUG"
** Search all files for "console"
** Search all files for "TODO"

# Development TO DO
* [X] Modify Player use routine to allow SecurityTerminal objects to temporarily lock the pit traps in a room
* [X] Modify SecurityTerminal to lock and eventually unlock the pit traps
* Modify Player use routine to allow SecurityTerminal objects to temporarily disable the robots in a room
* Modify SecurityTerminal to disable and eventually reenable the robots
* Modify Player use routine to allow SecurityTerminal objects to temporarily disable death balls in a room
* Modify SecurityTerminal to disable and eventually reenable DeathBalls
* Add storyline modal dialogs at the outset of the game
* Modify handleEvent in Player to allow pocket computer to hack pit trap locking passwords in exchange for time
* Modify handleEvent in Player to allow pocket computer to hack robot disable passwords in exchange for time

# Extra Time TO DO
* Expand the furniture list; let the letters and time be random
* Modify Roomba to move so the player must chase it down to search it
* Arrange the password letters vertically in pairs next to mini-map in pocket computer
** Use green/yellow/cyan background with black letters
* Modify pocket computer handling of puzzle pieces; allow swapping and rotation
* Modify pocket computer to dial for proper orientation and position in exchange for time

# Notes and Such

## Security Terminals

    *** SECURITY TERMINAL ## ***

          SELECT FUNCTION

        RESET LIFTING PLATFORMS
          IN THIS ROOM.

        TEMPORARILY DISABLE
          ROBOTS IN THIS ROOM.

    ==> LOG OFF.

    #####################
    # PASSWORD ACCEPTED #
    #####################
