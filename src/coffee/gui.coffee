# gui.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

Map = require './map'
{ROT} = require './rot.min'

DISPLAY_SIZE = { width:60, height:40 }

NOT_VISIBLE = 'X'
VISIBLE = '!'

BOX =
  single:
    h: '─'
    ll: '└'
    lr: '┘'
    ul: '┌'
    ur: '┐'
    v: '│'
    pd: '╷'
    pl: '╴'
    pr: '╶'
    pu: '╵'
    td: '┴'
    tl: '├'
    tr: '┤'
    tu: '┬'

PUZZLES = [
  "┌┐││└┘", # 0
  "┌┐┌┘└┘", # 2
  "┌┐╶┤└┘", # 3
  "┌╴└┐╶┘", # 5
  "┌╴├┐└┘", # 6
  "┌┐├┤└┘", # 8
  "┌┐└┤╶┘", # 9
  "┌┐├┤╵╵", # A
  "┌╴├╴└╴", # E
  "┌┐│┐└┘", # G
  "╷╷├┤╵╵", # H
  "╶┬╷│└┘", # J
  "┌┐└┐└┘", # S
  "╷╷││└┘", # U
  "╷╷└┤└┘"  # Y
]

ROTATIONS = [
  "┌┐┘└",
  "┬┤┴├",
  "╷╴╵╶",
  "│─"
]

FLIPS =
  HORIZ: [
    "┌┐",
    "┘└",
    "┬┬",
    "┤├",
    "┴┴",
    "╷╷",
    "╴╶",
    "╵╵",
    "││",
    "──"
  ]
  VERT: [
    "┌└",
    "┐┘",
    "┬┴",
    "┤┤",
    "├├",
    "╷╵",
    "╴╴",
    "╶╶",
    "││",
    "──"
  ]

PUZZLE_WIDTH = 2
PUZZLE_HEIGHT = 3

class GUI
  constructor: ->
  
  init: ->
    # http://ondras.github.io/rot.js/manual/#display
    displayOptions =
      width: DISPLAY_SIZE.width
      height: DISPLAY_SIZE.height
      fontSize: 15
      fontFamily: 'monospace'
      fg: '#fff'
      bg: '#000'
      spacing: 1.0
      layout: 'rect'

    document.body.innerHTML = ''
    @display = new ROT.Display displayOptions
    document.body.appendChild @display.getContainer()
    window.addEventListener 'resize', this
    
  handleEvent: (event) ->
    # resize the display canvas
    {innerHeight} = window
    charHeight = Math.floor(innerHeight / DISPLAY_SIZE.height)
    @display.setOptions {fontSize:charHeight}
    # center the display canvas vertically in the window
    canvasHeight = document.body.firstChild.height
    spacerHeight = (innerHeight - canvasHeight) / 2
    document.body.firstChild.style.marginTop = "" + spacerHeight + "px"    
    
  render: (state) ->
    # HACK: stateful visibility in the GUI? yuck!
    if not @visibleLayout?
      @visibleLayout = deepCloneLayout state.layout
    # define some time savers
    centerX = Math.floor DISPLAY_SIZE.width / 2
    centerY = Math.floor DISPLAY_SIZE.height / 2
    dispW = DISPLAY_SIZE.width-1
    dispH = DISPLAY_SIZE.height-1
    {map, player} = state
    # calculate map FOV
    maxVisibilityDistance = Math.sqrt((centerX*centerX)+(centerY*centerY))
    visibleMap = deepCloneMap map
    updateVisibleMap = (x, y, r, v) ->
      visibleMap[y][x] = NOT_VISIBLE
      visibleMap[y][x] = VISIBLE if v > 0.0
    lightPasses = (x,y) ->
      return false if y < 0
      return false if y >= map.length
      return false if x < 0
      return false if x >= map[y].length
      return (map[y][x] is ' ')
    mapFov = new ROT.FOV.PreciseShadowcasting lightPasses
    mapFov.compute player.x, player.y, maxVisibilityDistance, updateVisibleMap
    # fill the grid with magic pink hashes
      # DEBUG: Just to give a sense of the full display; remove later
    @fillRect 0, 0, dispW, dispH, '#', '#f0f', '#000'
    #@fillRect 0, 0, dispW, dispH, ' ', '#fff', '#000'
    # render the defined map into the display
    for i in [0..dispH]
      for j in [0..dispW]
        mapX = ((player.x - centerX) + j)
        mapY = ((player.y - centerY) + i)
        layoutX = Math.floor (mapX / Map.ROOM_SIZE.width)
        layoutY = Math.floor (mapY / Map.ROOM_SIZE.height)
        if (mapX >= 0) and (mapX < map[0].length)
          if (mapY >= 0) and (mapY < map.length)
            if (visibleMap[mapY][mapX] is VISIBLE)
              @visibleLayout[layoutY][layoutX] = VISIBLE
              if map[mapY][mapX] is ' ' 
                bg = state.layoutColor[layoutY][layoutX]
              else
                bg = '#000'
              @display.draw j, i, map[mapY][mapX], '#888', bg
              objHere = state.getObjectsAt mapX, mapY
              for obj in objHere
                if obj.visible or (obj.ch is '▒')  # DEBUG: Test pit sensor!
                  @display.draw j, i, obj.ch, obj.fg, bg
    # render the player into the display
    layoutX = Math.floor (player.x / Map.ROOM_SIZE.width)
    layoutY = Math.floor (player.y / Map.ROOM_SIZE.height)
    bg = state.layoutColor[layoutY][layoutX]
    @display.draw centerX, centerY, '@', '#fff', bg
    # render the search bar at the top
    @renderTopBar state
    # render the timer bar at the bottom
    @renderTime state
    # render the pocket computer, if it's open
    if state.pocketComputer
      @renderPocketComputer state
      
  renderTopBar: (state) ->
    if state.lastReward?
      # define some time savers
      centerX = Math.floor DISPLAY_SIZE.width / 2
      centerY = Math.floor DISPLAY_SIZE.height / 2
      dispW = DISPLAY_SIZE.width-1
      dispH = DISPLAY_SIZE.height-1
      {map, player} = state
      # make room to display the search bar at the top
      @fillRect 0, 0, dispW, 0, ' ', '#fff', '#000'
      # build up the searching string
      space = (DISPLAY_SIZE.width - state.lastReward.length) >> 1
      rewardMsg = "%c{yellow}" + state.lastReward
      # draw it to the display
      @display.drawText space, 0, rewardMsg
    else
      @renderSearch state

  renderSearch: (state) ->
    # don't render the bar if the player isn't searching
    return if state.lastSearch is 0
    # define some time savers
    centerX = Math.floor DISPLAY_SIZE.width / 2
    centerY = Math.floor DISPLAY_SIZE.height / 2
    dispW = DISPLAY_SIZE.width-1
    dispH = DISPLAY_SIZE.height-1
    {map, player} = state
    # make room to display the search bar at the top
    @fillRect 0, 0, dispW, 0, ' ', '#fff', '#000'
    # build up the searching string
    searchMsg = "%c{cyan}" + state.searchDesc + "%c{yellow}: %c{red}"
    for i in [1..state.lastSearch]
      searchMsg += '━'
    # draw it to the display
    @display.drawText 0, 0, searchMsg

  renderTime: (state) ->
    # define some time savers
    centerX = Math.floor DISPLAY_SIZE.width / 2
    centerY = Math.floor DISPLAY_SIZE.height / 2
    dispW = DISPLAY_SIZE.width-1
    dispH = DISPLAY_SIZE.height-1
    {map, player} = state
    # make room to display some status stuff at the bottom
    @fillRect 0, dispH, dispW, dispH, ' ', '#fff', '#000'
    # render the name of the pocket computer at the bottom
    pocketComputer = "%c{yellow}[%c{cyan}M%c{yellow}]%c{cyan}1A9366b  %c{yellow}[%c{cyan}P%c{yellow}]%c{cyan}it Sensor"
    @display.drawText 0, dispH, pocketComputer
    # render the time remaining at the bottom
    if state.finished?
      timeLeft = "%c{cyan}00%c{yellow}:%c{cyan}00%c{yellow}:%c{cyan}00"
    else
      timeDisp = formatTime state.getTimeLeft()
      timeLeft = "%c{cyan}" + timeDisp[0] + "%c{yellow}:%c{cyan}" + timeDisp[1] + "%c{yellow}:%c{cyan}" + timeDisp[2]
    @display.drawText dispW-7, dispH, timeLeft

  renderPocketComputer: (state) ->
    # define some time savers
    centerX = Math.floor DISPLAY_SIZE.width / 2
    centerY = Math.floor DISPLAY_SIZE.height / 2
    dispW = DISPLAY_SIZE.width-1
    dispH = DISPLAY_SIZE.height-1
    {layout, map, player} = state
    # figure out where the pocket computer will display
    pcX1 = 0
    pcY1 = (dispH - centerY) >> 1
    pcX2 = dispW
    pcY2 = pcY1 + centerY
    # figure out where the minimap will display
    miniX1 = pcX1+1
    miniY1 = pcY1+1
    miniX2 = miniX1 + layout[0].length + 1
    miniY2 = miniY1 + layout.length + 1
    # clear the area for the mini-computer to display
    @fillRect pcX1, pcY1, pcX2, pcY2, ' ', '#fff', '#000'
    @drawBox pcX1, pcY1, pcX2, pcY2, BOX.single, '#84c5cc', '#000'
    @drawBox miniX1, miniY1, miniX2, miniY2, BOX.single, '#d5df7c', '#000'
    # determine where the player is at
    playerLayoutX = Math.floor (player.x / Map.ROOM_SIZE.width)
    playerLayoutY = Math.floor (player.y / Map.ROOM_SIZE.height)
    # roll over the layout, displaying on the mini-map
    for i in [0..layout.length-1]
      for j in [0..layout[i].length-1]
        oddRow = false if i%2 is 0
        oddRow = true if i%2 is 1
        fg = '#000'
        bg = '#72b14b'
        switch layout[i][j]
          when 'E'
            ch = '█'
          when 'R'
            ch = '█'
          when 'P'
            ch = '█'
            fg = '#800'
          when '1', '2', '3'
            if oddRow
              ch = '─'
            else
              ch = '|'
          else
            ch = ' '
        # if this is where the player currently is, use white
        if (j is playerLayoutX) and (i is playerLayoutY)
          fg = '#fff'
        # if we've seen it, display it
          # DEBUG: Make sure the whole map is vvvvvvvvvvvvv visible
        if (@visibleLayout[i][j] is VISIBLE) or (1 is 1)
        #if (@visibleLayout[i][j] is VISIBLE)
          @display.draw miniX1+j+1, miniY1+i+1, ch, fg, bg
        else
          @display.draw miniX1+j+1, miniY1+i+1, ' ', fg, bg
    # display the boxes for the puzzle pieces
    for i in [0..5]
      puzX1 = miniX2+i*(PUZZLE_WIDTH+2)+1
      puzY1 = pcY1+1
      puzX2 = puzX1+PUZZLE_WIDTH+1
      puzY2 = puzY1+PUZZLE_HEIGHT+1
      @drawBox puzX1, puzY1, puzX2, puzY2, BOX.single, '#d5df7c', '#000'
      @drawPuzzle state, i, puzX1, puzY1
    # display the pit sensor capability
    pitSensor = "%c{yellow}[%c{cyan}P%c{yellow}]%c{cyan}it Sensor"
    @display.drawText miniX2+1, miniY2, pitSensor

  fillRect: (x1, y1, x2, y2, ch, fg, bg) ->
    for y in [y1..y2]
      for x in [x1..x2]
        @display.draw x, y, ch, fg, bg

  drawBox: (x1, y1, x2, y2, boxSet, fg, bg) ->
    for y in [y1..y2]
      @display.draw x1, y, boxSet.v, fg, bg
      @display.draw x2, y, boxSet.v, fg, bg
    for x in [x1..x2]
      @display.draw x, y1, boxSet.h, fg, bg
      @display.draw x, y2, boxSet.h, fg, bg
    @display.draw x1, y1, boxSet.ul, fg, bg
    @display.draw x2, y1, boxSet.ur, fg, bg
    @display.draw x1, y2, boxSet.ll, fg, bg
    @display.draw x2, y2, boxSet.lr, fg, bg

  drawPuzzle: (state, index, px, py) ->
    {player} = state
    for i in [0..PUZZLE_HEIGHT-1]
      for j in [0..PUZZLE_WIDTH-1]
        puzzleId = index*6 + i*2 + j
        if player.hasPuzzle puzzleId
          ch = state.puzzles[index].charAt i*2+j
          @display.draw px+j+1, py+i+1, ch, '#ffffff', '#606060'
        else
          @display.draw px+j+1, py+i+1, ' ', '#fff', '#000'

exports.GUI = GUI
exports.PUZZLES = PUZZLES

#------------------------------------------------------------

deepCloneMap = (map) ->
  newMap = []
  for i in [0..map.length-1]
    newMap[i] = []
    for j in [0..map[i].length-1]
      newMap[i][j] = map[i][j]
  return newMap

deepCloneLayout = (layout) ->
  newLayout = []
  for i in [0..layout.length-1]
    newLayout[i] = []
    for j in [0..layout[i].length-1]
      newLayout[i][j] = layout[i][j]
  return newLayout

formatTime = (timeLeft) ->
  timeRemain = 0
  timeRemain = timeLeft if timeLeft >= 0
  MINS = 60
  HOURS = 60 * MINS
  hours = Math.floor timeRemain / HOURS
  minLeft = timeRemain % HOURS
  minutes = Math.floor minLeft / MINS
  secLeft = minLeft % MINS
  seconds = Math.floor secLeft
  [("" + hours).lpad(), ("" + minutes).lpad(), ("" + seconds).lpad()]

#----------------------------------------------------------------------
# end of gui.coffee
