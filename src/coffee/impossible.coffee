# impossible.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

FortressLayout = require './layout'
FortressMap = require './map'
{GameState} = require './state'
{GUI} = require './gui'
{ROT} = require './rot.min'
{SoundBoard} = require './sfx'

{BeginGame} = require './actor/begin'

class ImpossibleMission
  constructor: ->
  
  run: ->
    @scheduler = new ROT.Scheduler.Speed()
    @scheduler.add new BeginGame(), false
    
    @layout = FortressLayout.generateFortress()
    @map = FortressMap.generateFortress @layout
    @state = new GameState @layout, @map

    @sfx = new SoundBoard()
    @sfx.init()

    @gui = new GUI()
    @gui.init()
    @gui.handleEvent()
    @gui.render @state
    
    @engine = new ROT.Engine @scheduler
    @engine.start()

  tick: =>
    return if @state.finished?
    if @state.getTimeLeft() > 0
      setTimeout @tick, 1000
    @gui.renderTime @state
    
exports.ImpossibleMission = ImpossibleMission

#----------------------------------------------------------------------
# end of impossible.coffee
