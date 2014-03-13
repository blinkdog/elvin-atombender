# computer.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_LEFT, VK_M, VK_RIGHT, VK_SPACE, VK_UP} = ROT

class PocketComputer
  constructor: ->
    
  getSpeed: -> -1
  
  act: ->
    window.game.engine.lock()
    window.game.sfx.playSound 'pc-on'
    window.addEventListener 'keydown', this

  handleEvent: (event) ->
    switch event.keyCode
      when VK_M
        @closePocketComputer()
    window.game.gui.render window.game.state

  closePocketComputer: ->
    window.game.state.pocketComputer = false
    window.game.scheduler.remove this
    window.removeEventListener 'keydown', this
    window.game.sfx.playSound 'pc-off'
    window.game.engine.unlock()
    window.game.gui.render window.game.state

exports.PocketComputer = PocketComputer

#----------------------------------------------------------------------
# end of computer.coffee
