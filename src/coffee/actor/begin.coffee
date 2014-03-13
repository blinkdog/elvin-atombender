# begin.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class BeginGame
  constructor: ->
    @visible = false

  getSpeed: -> -1

  act: ->
    window.game.engine.lock()
    window.game.scheduler.add window.game.state.player, true
    window.game.sfx.playSound 'another-visitor'
# DEBUG: Shorter time to game start for debugging purposes
#    setTimeout window.game.state.startGame, 7000
    setTimeout window.game.state.startGame, 1

exports.BeginGame = BeginGame

#----------------------------------------------------------------------
# end of begin.coffee
