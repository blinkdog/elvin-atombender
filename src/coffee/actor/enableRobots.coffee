# enableRobots.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class EnableRobots
  constructor: (@robots, @time)->
    
  getSpeed: -> 100
  
  act: ->
    @time--
    if @time <= 0
      for robot in @robots
        robot.disabled = false
      window.game.scheduler.remove this

exports.EnableRobots = EnableRobots

#----------------------------------------------------------------------
# end of enableRobots.coffee
