# terminal.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'
{VK_DOWN, VK_SPACE, VK_UP} = ROT

{EnablePits} = require './enablePits'
{EnableRobots} = require './enableRobots'

TURNS_DISABLE_PITS = 30
TURNS_DISABLE_ROBOTS = 75

class Terminal
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'S'
    @fg = '#675200'
    @bg = '#000'
    @desc = 'Security Terminal'
    @visible = true
    @accepted = false
    @required = false
    
  getSpeed: -> -1
  
  act: ->
    @cursor = 2
    window.game.engine.lock()
    window.game.sfx.playSound 'pc-on'
    window.addEventListener 'keydown', this

  handleEvent: (event) ->
    @accepted = false
    @required = false
    switch event.keyCode
      when VK_UP
        @cursor = Math.max(0, @cursor-1)
      when VK_DOWN
        @cursor = Math.min(2, @cursor+1)
      when VK_SPACE
        switch @cursor
          when 0
            @disablePits()
          when 1
            @disableRobots()
          when 2
            @logOffSecurityTerminal()
    window.game.gui.render window.game.state

  disablePits: ->
    {state} = window.game
    {player} = state
    if player.lift <= 0
      @required = true
      return
    player.lift--
    @accepted = true
    # lock pits
    pits = state.objects.filter (value, index, array) =>
      return (value.ch is '▒') and (value.layoutRoom.x is @layoutRoom.x) and (value.layoutRoom.y is @layoutRoom.y)
    enablePits = new EnablePits pits, TURNS_DISABLE_PITS
    window.game.scheduler.add enablePits, true
    for pit in pits
      pit.locked = true
      pit.visible = true

  disableRobots: ->
    {state} = window.game
    {player} = state
    if player.snooze <= 0
      @required = true
      return
    player.snooze--
    @accepted = true
    # disable robots
    robots = state.objects.filter (value, index, array) =>
      return ((value.ch is 'R') or (value.ch is '⬤')) and (value.layoutRoom.x is @layoutRoom.x) and (value.layoutRoom.y is @layoutRoom.y)
    enableRobots = new EnableRobots robots, TURNS_DISABLE_ROBOTS
    window.game.scheduler.add enableRobots, true
    for robot in robots
      robot.disabled = true

  logOffSecurityTerminal: ->
    delete window.game.state.securityTerminal
    window.game.scheduler.remove this
    window.removeEventListener 'keydown', this
    window.game.sfx.playSound 'pc-off'
    window.game.engine.unlock()
    window.game.gui.render window.game.state

exports.Terminal = Terminal

#----------------------------------------------------------------------
# end of terminal.coffee
