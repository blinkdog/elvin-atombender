# player.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_H, VK_LEFT, VK_M, VK_S, VK_RIGHT, VK_SPACE, VK_UP} = ROT
{PocketComputer} = require './computer'
{ROOM_SIZE} = require '../map'

# DEBUG: REMOVE THIS!
{VK_X} = ROT

CHANCE_DESTROY_HIM = 0.025
CHANCE_HACK_SUCCEED = 0.75

NUM_STARTING_PASSWORD =
  LIFT: 3
  SNOOZE: 3

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
TIME_PENALTY_HACK = 2 * SEC_PER_MIN * MILLI_PER_SEC

class Player
  constructor: ->
    @x = 20
    @y = 14
    @visible = true
    @safeX = @x
    @safeY = @y
    @lift = NUM_STARTING_PASSWORD.LIFT
    @snooze = NUM_STARTING_PASSWORD.SNOOZE
    @puzzle = []
    
  getSpeed: -> 100
  
  act: ->
    window.game.engine.lock()
    window.addEventListener 'keydown', this

  handleEvent: (event) ->
    # reset some temporary displays
    window.game.state.lastSearch = 0
    delete window.game.state.lastReward
    # handle the player's input
    switch event.keyCode
      when VK_UP
        @move {x:0, y:-1}
      when VK_DOWN
        @move {x:0, y:1}
      when VK_LEFT
        @move {x:-1, y:0}
      when VK_RIGHT
        @move {x:1, y:0}
      when VK_SPACE
        @use()
      when VK_H
        @hackSecurityTerminal()
      when VK_M
        @openPocketComputer()
      when VK_S
        @revealPits()
      # DEBUG: REMOVE THIS!!
      when VK_X
        @puzzle = []
        for i in [0..35]
          @puzzle.push i
        for y in [0..(window.game.gui.visibleLayout.length-1)]
          for x in [0..(window.game.gui.visibleLayout[i]-1)]
            window.game.gui.visibleLayout[y][x] = '!'
    # regardless, let's get back to the game
    window.removeEventListener 'keydown', this
    window.game.engine.unlock()
    window.game.gui.render window.game.state

  move: (dir) ->
    # define some time savers   
    {map, sfx, state} = window.game
    # figure out the destination square
    newX = @x + dir.x
    newY = @y + dir.y
    # determine if the player is changing rooms
    changeRooms = isChangingRooms @x, @y, newX, newY
    # determine if the destination is legal
    if map[newY][newX] is ' '
      @x = newX
      @y = newY
    # determine if this is a new 'safe' square
    layoutX = Math.floor(@x / ROOM_SIZE.width)
    layoutY = Math.floor(@y / ROOM_SIZE.height)
    if ((layoutX % 2) is 0) or ((layoutY % 2) is 0)
      @safeX = @x
      @safeY = @y
    else
      # if we're changing rooms to a non-safe room
      if changeRooms
        if ROT.RNG.getUniform() < CHANCE_DESTROY_HIM
          window.game.sfx.playSound 'destroy-him'
    # determine if anything wants to interact with us
    objHere = state.getObjectsAt @x, @y
    for obj in objHere
      switch obj.ch
        when "▒"
          if not obj.locked
            state.fall obj
            break
    
  use: ->
    # figure out what we might use here
    objHere = window.game.state.getObjectsAt @x, @y
    return if objHere.length is 0
    # for each object in this location
    for obj in objHere
      # if this is a searchable piece of furniture
      if obj.searchTime?
        obj.searchTime--
        window.game.state.lastSearch = obj.searchTime
        window.game.state.searchDesc = obj.desc
        if obj.searchTime is 0
          window.game.scheduler.add obj, false
      # otherwise it is a security terminal or something
      else
        switch obj.ch
          when "M"                             # access panel
            if @puzzle.length is 36
              window.game.state.unlockDoor()
            else
              window.game.sfx.playSound 'elvin-laugh'
          when "S"                             # security terminal
            window.game.state.securityTerminal = obj
            window.game.scheduler.add obj, true
          when "▒"                             # locked pit trap
            obj=obj
          else
            alert 'Unknown Object: ' + obj.ch

  openPocketComputer: ->
    window.game.state.pocketComputer = true
    window.game.scheduler.add new PocketComputer(), true

  revealPits: ->
    revealed = window.game.state.revealPits()
    if revealed
      window.game.sfx.playSound 'pc-positive'
    else
      window.game.sfx.playSound 'pc-negative'

  hasPuzzle: (index) ->
    matching = (puzzle for puzzle in @puzzle when puzzle is index)
    return matching.length > 0

  hackSecurityTerminal: ->
    foundIt = false
    {sfx, state} = window.game
    sfx.playSound 'dial-a-hack'
    state.timeLimit -= TIME_PENALTY_HACK
    # figure out what we might use here
    objHere = state.getObjectsAt @x, @y
    for obj in objHere
      # if this is a searchable piece of furniture
      switch obj.ch
        when "S"
          foundIt = true
    # determine which reward will be used
    if not foundIt
      reward = "NEEDTERM"
    else
      if ROT.RNG.getUniform() < CHANCE_HACK_SUCCEED
        if ROT.RNG.getUniform() < 0.5
          reward = "HACKLIFT"
        else
          reward = "HACKSNOOZE"
      else
        reward = "HACKNONE"
    # define the function
    rewardResult = -> 
      state.addReward reward
      window.game.gui.render window.game.state
    setTimeout rewardResult, 7000

exports.Player = Player

#----------------------------------------------------------------------

isChangingRooms = (ox, oy, nx, ny) ->
  olx = Math.floor ox / ROOM_SIZE.width
  oly = Math.floor oy / ROOM_SIZE.height
  nlx = Math.floor nx / ROOM_SIZE.width
  nly = Math.floor ny / ROOM_SIZE.height
  return ((olx isnt nlx) or (oly isnt nly))
  
#----------------------------------------------------------------------
# end of player.coffee
