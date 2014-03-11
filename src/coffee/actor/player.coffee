# player.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_LEFT, VK_RIGHT, VK_UP} = ROT

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
    window.removeEventListener 'keydown', this
    window.game.engine.unlock()
    window.game.gui.render window.game.state

  move: (dir) ->
    newX = @x + dir.x
    newY = @y + dir.y
    if window.game.map[newY][newX] is ' '
      @x = newX
      @y = newY

exports.Player = Player

#----------------------------------------------------------------------
# end of player.coffee
