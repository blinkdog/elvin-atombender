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
    for i in [0..DISPLAY_SIZE.height]
      for j in [0..DISPLAY_SIZE.width]
        @display.draw j, i, '#', '#aaa', '#000'

exports.GUI = GUI

#----------------------------------------------------------------------
# end of gui.coffee
