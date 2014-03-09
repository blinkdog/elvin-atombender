# impossible.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

FortressLayout = require './layout'
FortressMap = require './map'
{GameState} = require './state'
{GUI} = require './gui'

class ImpossibleMission
  constructor: ->
  
  run: ->
    @layout = FortressLayout.generateFortress()
    @map = FortressMap.generateFortress @layout
    @state = new GameState @layout, @map
    
    @gui = new GUI()
    @gui.init()
    @gui.handleEvent()
    @gui.render @state
  
exports.ImpossibleMission = ImpossibleMission

#----------------------------------------------------------------------
# end of impossible.coffee
