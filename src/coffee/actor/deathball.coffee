# deathball.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROOM_SIZE} = require '../map'

class DeathBall
  constructor: (@x, @y, @layoutRoom)->
    @ch = '⬤'
    @fg = '#000'
    @desc = 'Death Ball'
    @visible = true
    @disabled = false
    @speed = 50 # Math.floor(player.speed / 2)
    
  getSpeed: -> @speed
  
  act: ->
    return if @disabled
    {player} = window.game.state
    xDir = sign(player.x-@x)
    yDir = sign(player.y-@y)
    desireX = @x+xDir
    desireY = @y+yDir
    # if we can go there
    if @canMove desireX, desireY
      # do so
      @move desireX, desireY
    # see if we've collided with the player yet
    @checkCollide()

  canMove: (newX, newY) ->
    # check if we're moving into a different room
    return false if isChangingRooms @x, @y, newX, newY
    # check if we'll run into anything we're not supposed to
    objHere = window.game.state.getObjectsAt newX, newY
    for obj in objHere
      continue if obj is this
      switch obj.ch
        # another robot
        when "R"
          return false
    # tell the caller we're allowed to move there
    return true

  move: (newX, newY) ->
    @x = newX
    @y = newY

  checkCollide: ->
    {player} = window.game.state 
    if (@x is player.x) and (@y is player.y)
      window.game.state.collide()

exports.DeathBall = DeathBall

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
# end of deathball.coffee
