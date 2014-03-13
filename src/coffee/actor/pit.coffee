# pit.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class PitTrap
  constructor: (@x, @y, @layoutRoom)->
    @ch = '▒'
    @fg = '#000'
    @desc = 'Pit Trap'
    @visible = true       # DEBUG: Just for now, false later
    
  getSpeed: -> -1
  
  act: ->
    @visible = true
    window.game.engine.lock()
    window.game.sfx.playSound 'falling'
    setTimeout window.game.state.unfall, 3500

exports.PitTrap = PitTrap

#----------------------------------------------------------------------
# end of pit.coffee
