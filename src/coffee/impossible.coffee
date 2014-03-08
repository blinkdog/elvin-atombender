# impossible.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{GUI} = require './gui'

class ImpossibleMission
  constructor: ->
  
  run: ->
    @gui = new GUI()
    @gui.init()
    @gui.render()
    @gui.handleEvent()
  
exports.ImpossibleMission = ImpossibleMission

#----------------------------------------------------------------------
# end of impossible.coffee
