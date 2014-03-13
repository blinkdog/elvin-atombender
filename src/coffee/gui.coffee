# gui.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require './rot.min'

DISPLAY_SIZE = { width:60, height:40 }

NOT_VISIBLE = 'X'
VISIBLE = '!'

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
    @fillRect 0, 0, dispW, dispH, '#', '#f0f', '#000'
    # render the defined map into the display
    for i in [0..dispH]
      for j in [0..dispW]
        mapX = ((player.x - centerX) + j)
        mapY = ((player.y - centerY) + i)
        if (mapX >= 0) and (mapX < map[0].length)
          if (mapY >= 0) and (mapY < map.length)
            if (visibleMap[mapY][mapX] is VISIBLE)
              @display.draw j, i, map[mapY][mapX], '#888', '#000'
              objHere = state.getObjectsAt mapX, mapY
              for obj in objHere
                @display.draw j, i, obj.ch, obj.fg, obj.bg
    # render the player into the display
    @display.draw centerX, centerY, '@', '#fff', '#000'
    # render the timer bar at the bottom
    @renderTime state

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
    pocketComputer = "%c{yellow}[%c{cyan}M%c{yellow}]%c{cyan}1A9366b"
    @display.drawText 0, dispH, pocketComputer
    # render the time remaining at the bottom
    if state.finished?
      timeLeft = "%c{cyan}00%c{yellow}:%c{cyan}00%c{yellow}:%c{cyan}00"
    else
      timeDisp = formatTime state.getTimeLeft()
      timeLeft = "%c{cyan}" + timeDisp[0] + "%c{yellow}:%c{cyan}" + timeDisp[1] + "%c{yellow}:%c{cyan}" + timeDisp[2]
    @display.drawText dispW-7, dispH, timeLeft

  fillRect: (x1, y1, x2, y2, ch, fg, bg) ->
    for y in [y1..y2]
      for x in [x1..x2]
        @display.draw x, y, ch, fg, bg

exports.GUI = GUI

#------------------------------------------------------------

deepCloneMap = (map) ->
  newMap = []
  for i in [0..map.length-1]
    newMap[i] = []
    for j in [0..map[i].length-1]
      newMap[i][j] = map[i][j]
  return newMap

formatTime = (timeLeft) ->
  MINS = 60
  HOURS = 60 * MINS
  hours = Math.floor timeLeft / HOURS
  minLeft = timeLeft % HOURS
  minutes = Math.floor minLeft / MINS
  secLeft = minLeft % MINS
  seconds = Math.floor secLeft
  [("" + hours).lpad(), ("" + minutes).lpad(), ("" + seconds).lpad()]

#----------------------------------------------------------------------
# end of gui.coffee
