# impossible.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

FortressLayout = require './layout'
FortressMap = require './map'
{GameState} = require './state'
{GUI} = require './gui'
{SoundBoard} = require './sfx'

class ImpossibleMission
  constructor: ->
  
  run: ->
    @layout = FortressLayout.generateFortress()
    @map = FortressMap.generateFortress @layout
    @state = new GameState @layout, @map

    @sfx = new SoundBoard()
    @sfx.init()

    @gui = new GUI()
    @gui.init()
    @gui.handleEvent()
    @gui.render @state

    @sfx.playSound 'another-visitor'
    setTimeout @state.startGame, 7000

  tick: =>
    if @state.getTimeLeft() > 0
      setTimeout @tick, 1000
    @gui.render @state
    
exports.ImpossibleMission = ImpossibleMission

#----------------------------------------------------------------------
# end of impossible.coffee
