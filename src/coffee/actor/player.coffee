# player.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_LEFT, VK_M, VK_P, VK_RIGHT, VK_SPACE, VK_UP} = ROT
{PocketComputer} = require './computer'
{ROOM_SIZE} = require '../map'

class Player
  constructor: ->
    @x = 20
    @y = 14
    @visible = true
    @safeX = @x
    @safeY = @y
    
  getSpeed: -> 100
  
  act: ->
    window.game.engine.lock()
    window.addEventListener 'keydown', this

  handleEvent: (event) ->
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
        
    window.removeEventListener 'keydown', this
    window.game.engine.unlock()
    window.game.gui.render window.game.state

  move: (dir) ->
    # define some time savers   
    {map, sfx, state} = window.game
    # figure out the destination square
    newX = @x + dir.x
    newY = @y + dir.y
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
    # determine if anything wants to interact with us
    objHere = state.getObjectsAt @x, @y
    for obj in objHere
      switch obj.ch
        when "▒"
          state.fall obj
          break
    
  use: ->
    objHere = window.game.state.getObjectsAt @x, @y
    if objHere.length is 0
      alert 'Nothing Here'
      return
    for obj in objHere
      switch obj.ch
        when "M"
          window.game.state.unlockDoor()
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

exports.Player = Player

#----------------------------------------------------------------------
# end of player.coffee
