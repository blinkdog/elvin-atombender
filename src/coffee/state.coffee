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
    @started = Date.now()
    @timeLimit = @started + TIME_LIMIT
    
  getTimeLeft: ->
    return Math.floor((@timeLimit - Date.now()) / MILLI_PER_SEC)
  
exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
