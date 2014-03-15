# robot.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROOM_SIZE} = require '../map'
{ROT} = require '../rot.min'

MAX_SPEED = 200
MIN_SPEED = 50

BEHAVIOR_TYPES = ["STATIONARY", "PACING", "SEEKING"]
ELECTRIC_TYPES = ["NONE", "PIVOT", "CONSTANT", "HIDDEN"]
PATROL_TYPES = [{x:-1,y:0}, {x:1,y:0}, {x:0,y:-1}, {x:0,y:1}]

class Robot
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'R'
    @fg = '#600'
    @desc = 'Robot Guard'
    @visible = true
    
    @speed = Math.floor(ROT.RNG.getUniform() * (MAX_SPEED-MIN_SPEED)) + MIN_SPEED
    @behavior = BEHAVIOR_TYPES.random()
    @electric = ELECTRIC_TYPES.random()
    @patrol = PATROL_TYPES.random()
    @patrolDir = 1
    
  getSpeed: -> @speed
  
  act: ->
    {player} = window.game.state
    # figure out where we want to go
    switch @behavior
      when "STATIONARY"
        desireX = @x
        desireY = @y
      when "PACING"
        desireX = @x + (@patrolDir*@patrol.x)
        desireY = @y + (@patrolDir*@patrol.y)
      when "SEEKING"
        xDir = sign (player.x - @x)
        yDir = sign (player.y - @y)
        desireX = @x + (xDir*@patrol.x)
        desireY = @y + (yDir*@patrol.y)
    # if we can go there
    if @canMove desireX, desireY
      # do so
      @lastAction = "MOVE"
      @move desireX, desireY
      @checkCollide()
    else
      # turn around
      @lastAction = "PIVOT"
      @patrolDir *= -1
    # figure out where we want to zap
    @elec = []
    switch @electric
      when "PIVOT"
        if @lastAction is "PIVOT"
          @dischargeWeapon()
      when "CONSTANT"
        @dischargeWeapon()
      when "HIDDEN"
        if @canZap
          @dischargeWeapon()
    # check if the player is caught up in the lightning
    @checkZap()

  canMove: (newX, newY) ->
    # check if we're moving into a different room
    return false if isChangingRooms @x, @y, newX, newY
    # check if we'll run into anything we're not supposed to
    objHere = window.game.state.getObjectsAt newX, newY
    for obj in objHere
      continue if obj is this
      switch obj.ch
        # another robot or pit trap
        when "R", "▒"
          return false
    # tell the caller we're allowed to move there
    return true

  move: (newX, newY) ->
    @x = newX
    @y = newY

  checkCollide: ->
    {player} = window.game.state 
    if (@x is player.x) and (@y is player.y)
      window.game.state.zap()

  canZap: ->
    @dischargeWeapon()
    for bzzt in @elec
      if (bzzt.x is player.x) and (bzzt.y is player.y)
        @elec = []
        return true
    @elec = []
    return false

  dischargeWeapon: ->
    {player} = window.game.state 
    playerDir = {x:sign(player.x-@x), y:sign(player.y-@y)}
    for i in [1..3]
      switch @behavior
        when "STATIONARY"
          zapX = @x + (i*playerDir.x)
          zapY = @y + (i*playerDir.y)
        when "PACING"
          zapX = @x + (i*@patrolDir*@patrol.x)
          zapY = @y + (i*@patrolDir*@patrol.y)
        when "SEEKING"
          zapX = @x + (i*playerDir.x*Math.abs(@patrol.y))
          zapY = @y + (i*playerDir.y*Math.abs(@patrol.x))
      if not isChangingRooms @x, @y, zapX, zapY
        @elec.push {x:zapX, y:zapY}

  checkZap: ->
    {player} = window.game.state 
    for bzzt in @elec
      if (bzzt.x is player.x) and (bzzt.y is player.y)
        window.game.state.zap()
        return

exports.Robot = Robot

#------------------------------------------------------------

isChangingRooms = (ox, oy, nx, ny) ->
  olx = Math.floor ox / ROOM_SIZE.width
  oly = Math.floor oy / ROOM_SIZE.height
  nlx = Math.floor nx / ROOM_SIZE.width
  nly = Math.floor ny / ROOM_SIZE.height
  return ((olx isnt nlx) or (oly isnt nly))

sign = (x) ->
  return -1 if x < 0
  return 1 if x > 0
  return 0

#----------------------------------------------------------------------
# end of robot.coffee
