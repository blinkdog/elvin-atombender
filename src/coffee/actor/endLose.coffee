# endLose.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class MissionFailed
  constructor: ->

  getSpeed: -> -1

  act: ->
    window.game.engine.lock()
    window.game.sfx.playSound 'elvin-laugh'
    setTimeout @reloadToPlayAgain, 4000

  reloadToPlayAgain: =>
    alert 'Hit Restore Or Run/Stop For New Game'

exports.MissionFailed = MissionFailed

#----------------------------------------------------------------------
# end of endLose.coffee
