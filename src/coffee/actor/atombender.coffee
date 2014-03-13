# atombender.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class Elvin
  constructor: (@x, @y, @layoutRoom)->
    @ch = '@'
    @fg = '#bd7570'
    @bg = '#000'
    @desc = 'Elvin Atombender'
    
  getSpeed: -> -1
  
  act: ->
    window.game.engine.lock()
    window.game.sfx.playSound 'elvin-no'
    setTimeout window.game.state.endGameWin, 5000

exports.Elvin = Elvin

#----------------------------------------------------------------------
# end of atombender.coffee
