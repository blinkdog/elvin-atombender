# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class GameState
  constructor: (@layout, @map) ->
    @player = {x:20, y:14}
  
exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
