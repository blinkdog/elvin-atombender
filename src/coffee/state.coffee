# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
TIME_LIMIT = 6 * MIN_PER_HOUR * SEC_PER_MIN * MILLI_PER_SEC

Map = require './map'
{ROOM_SIZE} = require './map'
{AccessPanel} = require './actor/access'
{Elvin} = require './actor/atombender'
{MissionAccomplished} = require './actor/endWin'
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
    # DEBUG: display the fortress layout
    result = (@layout[row].join '' for row in [0..@layout.length-1])
    alert '\n'+result.join '\n'

  endGameWin: =>
    window.game.scheduler.clear()
    window.game.scheduler.add new MissionAccomplished()
    window.game.engine.unlock()

  unlockDoor: =>
    # we've won, no need for more actions
    @finished = true
    # replace the security room with an open security room
    @map = Map.revealSecureRoom @map, @layout
    # remove everybody from the scheduler
    window.game.scheduler.clear()
    # add Elvin to the middle of the room
    @initElvin()
    # display everything to the user
    window.game.gui.render this

  initObjects: ->
    @objects = []
    @initSecurityTerminals()
    @initAccessPanels()
    
  initSecurityTerminals: ->
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

  initAccessPanels: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "P"
            switch @layout[i-1][j] 
              when "1"
                @addAccessPanel j, i, {x:3, y:-1}
              when "2"
                @addAccessPanel j, i, {x:9, y:-1}
              when "3"
                @addAccessPanel j, i, {x:15, y:-1}
            switch @layout[i+1][j] 
              when "1"
                @addAccessPanel j, i, {x:3, y:13}
              when "2"
                @addAccessPanel j, i, {x:9, y:13}
              when "3"
                @addAccessPanel j, i, {x:15, y:13}
            switch @layout[i][j-1] 
              when "1"
                @addAccessPanel j, i, {x:-1, y:2}
              when "2"
                @addAccessPanel j, i, {x:-1, y:6}
              when "3"
                @addAccessPanel j, i, {x:-1, y:10}
            switch @layout[i][j+1] 
              when "1"
                @addAccessPanel j, i, {x:19, y:2}
              when "2"
                @addAccessPanel j, i, {x:19, y:6}
              when "3"
                @addAccessPanel j, i, {x:19, y:10}

  initElvin: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "P"
            @addElvin j, i, {x:9, y:6}

  addSecurityTerminal: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    terminal = new Terminal termX, termY, {x:layoutX, y:layoutY}
    @objects.push terminal
    window.game.scheduler.add terminal, true

  addAccessPanel: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    accessPanel = new AccessPanel termX, termY, {x:layoutX, y:layoutY}
    @objects.push accessPanel
    window.game.scheduler.add accessPanel, true

  addElvin: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    elvinAtom = new Elvin termX, termY, {x:layoutX, y:layoutY}
    @objects.push elvinAtom
    window.game.scheduler.add elvinAtom, true

  getObjectsAt: (x,y) ->
    (object for object in @objects when object.x is x and object.y is y)

exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
