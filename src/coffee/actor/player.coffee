# player.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_LEFT, VK_RIGHT, VK_SPACE, VK_UP} = ROT

class Player
  constructor: ->
    @x = 20
    @y = 14
    
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
        
    window.removeEventListener 'keydown', this
    window.game.engine.unlock()
    window.game.gui.render window.game.state

  move: (dir) ->
    newX = @x + dir.x
    newY = @y + dir.y
    if window.game.map[newY][newX] is ' '
      @x = newX
      @y = newY

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

exports.Player = Player

#----------------------------------------------------------------------
# end of player.coffee
