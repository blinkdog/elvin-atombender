# player.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_LEFT, VK_M, VK_P, VK_RIGHT, VK_SPACE, VK_UP} = ROT
{PocketComputer} = require './computer'
{ROOM_SIZE} = require '../map'

# DEBUG: REMOVE THIS!
{VK_X} = ROT

CHANCE_DESTROY_HIM = 0.025

class Player
  constructor: ->
    @x = 20
    @y = 14
    @visible = true
    @safeX = @x
    @safeY = @y
    @lift = 0
    @snooze = 0
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
      when VK_M
        @openPocketComputer()
      when VK_P
        @revealPits()
      # DEBUG: REMOVE THIS!!
      when VK_X
        @puzzle = []
        for i in [0..35]
          @puzzle.push i

        
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
