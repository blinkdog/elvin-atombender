# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
# DEBUG: Shorter time limit for testing purposes
#TIME_LIMIT = 6 * MIN_PER_HOUR * SEC_PER_MIN * MILLI_PER_SEC

TIME_LIMIT = 11 * SEC_PER_MIN * MILLI_PER_SEC

TIME_PENALTY_FALL = 10 * SEC_PER_MIN * MILLI_PER_SEC
TIME_PENALTY_REVEAL = 10 * MILLI_PER_SEC

MIN_PITS = 1
MAX_PITS = 6

MIN_FURNITURE = 1
MAX_FURNITURE = 10

Layout = require './layout'
Map = require './map'
{ROOM_SIZE} = require './map'
{AccessPanel} = require './actor/access'
{Elvin} = require './actor/atombender'
{Furniture} = require './actor/furniture'
{MissionAccomplished} = require './actor/endWin'
{MissionFailed} = require './actor/endLose'
{PitTrap} = require './actor/pit'
{Player} = require './actor/player'
{Terminal} = require './actor/terminal'

{ROT} = require './rot.min'

class GameState
  constructor: (@layout, @map) ->
    @player = new Player()
    @pocketComputer = false
    @started = false
    @lastSearch = 0
    @layoutColor = Layout.paint @layout
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

  endGameWin: =>
    window.game.scheduler.clear()
    window.game.scheduler.add new MissionAccomplished()
    window.game.engine.unlock()

  endGameLose: =>
    @finished = true
    window.game.gui.render this
    window.game.scheduler.clear()
    window.game.scheduler.add new MissionFailed()

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

  fall: (pit) ->
    @timeLimit -= TIME_PENALTY_FALL
    window.game.scheduler.add pit
    window.game.gui.render this

  unfall: =>
    window.game.state.player.x = window.game.state.player.safeX
    window.game.state.player.y = window.game.state.player.safeY
    window.game.engine.unlock()
    window.game.gui.render this

  revealPits: ->
    @timeLimit -= TIME_PENALTY_REVEAL
    foundPit = false
    for i in [@player.y-2..@player.y+2]
      for j in [@player.x-2..@player.x+2]
        objHere = @getObjectsAt j, i
        for obj in objHere
          switch obj.ch
            when "▒"
              if not obj.visible
                obj.visible = true
                foundPit = true
    return foundPit

  addReward: (reward) ->
    alert 'Rewards not supported yet'

  initObjects: ->
    @objects = []
    @initSecurityTerminals()
    @initAccessPanels()
    @initPitTraps()
    @initFurniture()
    
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

  initPitTraps: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            numPitTraps = Math.floor(ROT.RNG.getUniform() * ((MAX_PITS-MIN_PITS)+1)) + MIN_PITS
            while numPitTraps > 0
              pitRoomOffsetX = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.width)
              pitRoomOffsetY = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.height)
              pitMapX = j*ROOM_SIZE.width + pitRoomOffsetX
              pitMapY = i*ROOM_SIZE.height + pitRoomOffsetY
              alreadyHere = @getObjectsAt pitMapX, pitMapY
              if alreadyHere.length is 0
                @addPitTrap j, i, {x:pitRoomOffsetX, y:pitRoomOffsetY}
                numPitTraps--

  initFurniture: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            numFurniture = Math.floor(ROT.RNG.getUniform() * ((MAX_FURNITURE-MIN_FURNITURE)+1)) + MIN_FURNITURE
            while numFurniture > 0
              furnRoomOffsetX = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.width)
              furnRoomOffsetY = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.height)
              furnMapX = j*ROOM_SIZE.width + furnRoomOffsetX
              furnMapY = i*ROOM_SIZE.height + furnRoomOffsetY
              alreadyHere = @getObjectsAt furnMapX, furnMapY
              if alreadyHere.length is 0
                @addFurniture j, i, {x:furnRoomOffsetX, y:furnRoomOffsetY}
                numFurniture--

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

  addPitTrap: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    pitTrap = new PitTrap termX, termY, {x:layoutX, y:layoutY}
    @objects.push pitTrap

  addFurniture: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    furniture = new Furniture termX, termY, {x:layoutX, y:layoutY}, 'REWARD'
    @objects.push furniture

  getObjectsAt: (x,y) ->
    (object for object in @objects when object.x is x and object.y is y)
    
  removeObject: (obj) ->
    @objects = @objects.filter (value, index, array) ->
      return value isnt obj
    
exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
