# gui.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require './rot.min'

DISPLAY_SIZE = { width:60, height:40 }

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
    dispW = DISPLAY_SIZE.width-1
    dispH = DISPLAY_SIZE.height-1
    {map, player} = state
    # fill the grid with magic pink hashes
    @fillRect 0, 0, dispW, dispH, '#', '#f0f', '#000'
    # figure out where we are going to draw the player
    centerX = Math.floor DISPLAY_SIZE.width / 2
    centerY = Math.floor DISPLAY_SIZE.height / 2
    # render the defined map into the display
    for i in [0..dispH]
      for j in [0..dispW]
        mapX = ((player.x - centerX) + j)
        mapY = ((player.y - centerY) + i)
        if (mapX >= 0) and (mapX < map[0].length)
          if (mapY >= 0) and (mapY < map.length)
            @display.draw j, i, map[mapY][mapX], '#888', '#000'
    # render the player into the display
    @display.draw centerX, centerY, '@', '#fff', '#000'

  fillRect: (x1, y1, x2, y2, ch, fg, bg) ->
    for y in [y1..y2]
      for x in [x1..x2]
        @display.draw x, y, ch, fg, bg

exports.GUI = GUI

#----------------------------------------------------------------------
# end of gui.coffee
