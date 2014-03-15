# state.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

CHANCE_DEATHBALL = 0.1
CHANCE_PASSWORD = 0.2
CHANCE_PUZZLE = 0.3

MIN_PITS = 0
MAX_PITS = 6

MIN_ROBOTS = 1
MAX_ROBOTS = 6

MIN_PER_HOUR = 60
SEC_PER_MIN = 60
MILLI_PER_SEC = 1000
# DEBUG: Shorter time limit for testing purposes
#TIME_LIMIT = 11 * SEC_PER_MIN * MILLI_PER_SEC

TIME_LIMIT = 6 * MIN_PER_HOUR * SEC_PER_MIN * MILLI_PER_SEC

TIME_PENALTY_COLLIDE = 10 * SEC_PER_MIN * MILLI_PER_SEC
TIME_PENALTY_FALL = 10 * SEC_PER_MIN * MILLI_PER_SEC
TIME_PENALTY_REVEAL = 10 * MILLI_PER_SEC
TIME_PENALTY_ZAP = 10 * SEC_PER_MIN * MILLI_PER_SEC

Layout = require './layout'
Map = require './map'
{ROOM_SIZE} = require './map'
{AccessPanel} = require './actor/access'
{DeathBall} = require './actor/deathball'
{Elvin} = require './actor/atombender'
{Furniture} = require './actor/furniture'
{MissionAccomplished} = require './actor/endWin'
{MissionFailed} = require './actor/endLose'
{PitTrap} = require './actor/pit'
{Player} = require './actor/player'
{Robot} = require './actor/robot'
{Terminal} = require './actor/terminal'
{Zap} = require './actor/zap'

{ROT} = require './rot.min'
{PUZZLES} = require './gui'

class GameState
  constructor: (@layout, @map) ->
    @player = new Player()
    @pocketComputer = false
    @started = false
    @lastSearch = 0
    @layoutColor = Layout.paint @layout
    @initObjects()
    @initPuzzles()

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
    switch reward
      when "LIFT"
        @lastReward = "Password: Lock Pits"
        @player.lift++
      when "SNOOZE"
        @lastReward = "Password: Robot Snooze"
        @player.snooze++
      when "NOTHING"
        @lastReward = "Nothing Here"
      else
        @lastReward = "Secure Room Password Fragment"
        @player.puzzle.push reward
    window.game.gui.render this

  collide: ->
    @timeLimit -= TIME_PENALTY_COLLIDE
    window.game.scheduler.add new Zap()
    window.game.gui.render this

  zap: ->
    @timeLimit -= TIME_PENALTY_ZAP
    window.game.scheduler.add new Zap()
    window.game.gui.render this

  initObjects: ->
    @objects = []
    @initSecurityTerminals()
    @initAccessPanels()
    @initPitTraps()
    @initFurniture()
    @initRobots()
    @initDeathBalls()

  initPuzzles: ->
    @puzzles = []
    for i in [1..6]
      @puzzles.push PUZZLES.random()

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
    # create a list of all puzzle pieces
    puzzleList = (i for i in [0..35])
    # create a list of passwords
    passwordList = ["LIFT", "SNOOZE"]
    # create a list of rooms in the fortress
    roomList = []
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            roomList.push {x:j,y:i}
    # while we still have puzzle pieces to give away
    while puzzleList.length > 0
      # determine a random reward
      rewardChance = ROT.RNG.getUniform()
      if rewardChance < CHANCE_PUZZLE
        reward = puzzleList.random()
      else if rewardChance < (CHANCE_PUZZLE + CHANCE_PASSWORD)
        reward = passwordList.random()
      else
        reward = "NOTHING"
      # determine a random room for the furniture to inhabit
      room = roomList.random()
      furnRoomOffsetX = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.width)
      furnRoomOffsetY = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.height)
      furnMapX = room.x*ROOM_SIZE.width + furnRoomOffsetX
      furnMapY = room.y*ROOM_SIZE.height + furnRoomOffsetY
      # see if anything already occupies that spot in the room
      alreadyHere = @getObjectsAt furnMapX, furnMapY
      if alreadyHere.length is 0
        # add it to the room and remove the puzzle piece (if any)
        @addFurniture room.x, room.y, {x:furnRoomOffsetX, y:furnRoomOffsetY}, reward
        puzzleList = puzzleList.filter (value, index, array) ->
          return value isnt reward

  initRobots: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            numRobots = Math.floor(ROT.RNG.getUniform() * ((MAX_ROBOTS-MIN_ROBOTS)+1)) + MIN_ROBOTS
            while numRobots > 0
              robotRoomOffsetX = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.width)
              robotRoomOffsetY = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.height)
              robotMapX = j*ROOM_SIZE.width + robotRoomOffsetX
              robotMapY = i*ROOM_SIZE.height + robotRoomOffsetY
              alreadyHere = @getObjectsAt robotMapX, robotMapY
              if alreadyHere.length is 0
                @addRobot j, i, {x:robotRoomOffsetX, y:robotRoomOffsetY}
                numRobots--

  initDeathBalls: ->
    for i in [0..@layout.length-1]
      for j in [0..@layout[i].length-1]
        switch @layout[i][j]
          when "R"
            if ROT.RNG.getUniform() < CHANCE_DEATHBALL
              numDeathBalls = 1
            else
              numDeathBalls = 0
            while numDeathBalls > 0
              deathBallRoomOffsetX = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.width)
              deathBallRoomOffsetY = Math.floor(ROT.RNG.getUniform() * ROOM_SIZE.height)
              deathBallMapX = j*ROOM_SIZE.width + deathBallRoomOffsetX
              deathBallMapY = i*ROOM_SIZE.height + deathBallRoomOffsetY
              alreadyHere = @getObjectsAt deathBallMapX, deathBallMapY
              if alreadyHere.length is 0
                @addDeathBall j, i, {x:deathBallRoomOffsetX, y:deathBallRoomOffsetY}
                numDeathBalls--

  addSecurityTerminal: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    terminal = new Terminal termX, termY, {x:layoutX, y:layoutY}
    @objects.push terminal
    # security terminals are now added when used
    # see Player.use for 'S' objects
    #window.game.scheduler.add terminal, true

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

  addFurniture: (layoutX, layoutY, mapOffset, reward) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    termX = mapX + mapOffset.x
    termY = mapY + mapOffset.y
    furniture = new Furniture termX, termY, {x:layoutX, y:layoutY}, reward
    @objects.push furniture

  addRobot: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    robotX = mapX + mapOffset.x
    robotY = mapY + mapOffset.y
    robot = new Robot robotX, robotY, {x:layoutX, y:layoutY}
    @objects.push robot
    window.game.scheduler.add robot, true

  addDeathBall: (layoutX, layoutY, mapOffset) ->
    mapX = layoutX*ROOM_SIZE.width
    mapY = layoutY*ROOM_SIZE.height
    deathBallX = mapX + mapOffset.x
    deathBallY = mapY + mapOffset.y
    deathBall = new DeathBall deathBallX, deathBallY, {x:layoutX, y:layoutY}
    @objects.push deathBall
    window.game.scheduler.add deathBall, true

  getObjectsAt: (x,y) ->
    (object for object in @objects when object.x is x and object.y is y)
    
  removeObject: (obj) ->
    @objects = @objects.filter (value, index, array) ->
      return value isnt obj
    
exports.GameState = GameState

#----------------------------------------------------------------------
# end of gameState.coffee
