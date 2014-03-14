# robot.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'

MAX_SPEED = 400
MIN_SPEED = 50

BEHAVIOR_TYPES = ["STATIONARY", "PACING", "SUSPICIOUS", "SEEKING"]
ELECTRIC_TYPES = ["NONE", "PIVOT", "CONSTANT", "HIDDEN"]
PATROL_TYPES = [{x:-1,y:0}, {x:1,y:0}, {x:0,y:-1}, {x:0,y:1}]

class Robot
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'R'
    @fg = '#004'
    @desc = 'Robot Guard'
    @visible = true
    
    @speed = Math.floor(ROT.RNG.getUniform() * (MAX_SPEED-MIN_SPEED)) + MIN_SPEED
    @behavior = BEHAVIOR_TYPES.random()
    @electric = ELECTRIC_TYPES.random()
    @patrol = PATROL_TYPES.random()
    @patrolDir = 1
    
  getSpeed: -> @speed
  
  act: ->
    #alert 'Exterminate!'
  
exports.Robot = Robot

#----------------------------------------------------------------------
# end of robot.coffee
