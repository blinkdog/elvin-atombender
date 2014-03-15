# zap.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class Zap
  constructor: ->
    
  getSpeed: -> -1
  
  act: ->
    window.game.engine.lock()
    window.game.sfx.playSound 'player-zapped'
    setTimeout window.game.state.unfall, 3500

exports.Zap = Zap

#----------------------------------------------------------------------
# end of zap.coffee
