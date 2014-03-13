# endWin.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class MissionAccomplished
  constructor: ->
    @visible = false

  getSpeed: -> -1

  act: ->
    window.game.engine.lock()
    window.game.sfx.playSound 'mission-accomplished'
    setTimeout @reloadToPlayAgain, 4000

  reloadToPlayAgain: =>
    alert 'Hit Restore Or Run/Stop For New Game'

exports.MissionAccomplished = MissionAccomplished

#----------------------------------------------------------------------
# end of endWin.coffee
