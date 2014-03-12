# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
TIME_LIMIT = 6 * MIN_PER_HOUR * SEC_PER_MIN * MILLI_PER_SEC

{ROOM_SIZE} = require './map'
{Player} = require './actor/player'
{Terminal} = require './actor/terminal'

class GameState
  constructor: (@layout, @map) ->
    @player = new Player()
    @started = false
    @initObjects()

  getTimeLeft: ->
    if @started
      return Math.floor((@timeLimit - Date.now()) / MILLI_PER_SEC)
    return result = Math.floor(TIME_LIMIT / MILLI_PER_SEC)

  startGame: =>
    @started = true
    @timeLimit = Date.now() + TIME_LIMIT
    setTimeout window.game.tick, 1
    window.game.engine.unlock()

  initObjects: ->
    alert 'initObjects'
    @objects = []
    @initSecurityTerminals()
    
  initSecurityTerminals: ->
    alert 'initSecurityTerminals'
#     ||S|| ||S|| ||S||  
#    R##################
#   -###################-
#   S###################S
#   -###################-
#    ###################
#   -###################-
#   S###################S
#   -###################-
#    ###################
#   -###################-
#   S###################S
#   -###################-
#    ###################
#     ||S|| ||S|| ||S||
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            switch @layout[i-1][j] 
              when "1"
                @addSecurityTerminal j, i, {x:3, y:-1}
              when "2"
                @addSecurityTerminal j, i, {x:9, y:-1}
              when "3"
                @addSecurityTerminal j, i, {x:15, y:-1}
            switch @layout[i+1][j] 
              when "1"
                @addSecurityTerminal j, i, {x:3, y:13}
              when "2"
                @addSecurityTerminal j, i, {x:9, y:13}
              when "3"
                @addSecurityTerminal j, i, {x:15, y:13}
            switch @layout[i][j-1] 
              when "1"
                @addSecurityTerminal j, i, {x:-1, y:2}
              when "2"
                @addSecurityTerminal j, i, {x:-1, y:6}
              when "3"
                @addSecurityTerminal j, i, {x:-1, y:10}
            switch @layout[i][j+1] 
              when "1"
                @addSecurityTerminal j, i, {x:19, y:2}
              when "2"
                @addSecurityTerminal j, i, {x:19, y:6}
              when "3"
                @addSecurityTerminal j, i, {x:19, y:10}

  addSecurityTerminal: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    terminal = new Terminal termX, termY, {x:layoutX, y:layoutY}
    @objects.push terminal
    window.game.scheduler.add terminal, true

  getObjectsAt: (x,y) ->
    (object for object in @objects when object.x is x and object.y is y)

exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
