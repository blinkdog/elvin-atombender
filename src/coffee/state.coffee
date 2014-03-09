# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
TIME_LIMIT = 6 * MIN_PER_HOUR * SEC_PER_MIN * MILLI_PER_SEC

class GameState
  constructor: (@layout, @map) ->
    @player = {x:20, y:14}
    @started = false

  getTimeLeft: ->
    if @started
      return Math.floor((@timeLimit - Date.now()) / MILLI_PER_SEC)
    return result = Math.floor(TIME_LIMIT / MILLI_PER_SEC)

  startGame: =>
    @started = true
    @timeLimit = Date.now() + TIME_LIMIT
    setTimeout window.game.tick, 1

exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
