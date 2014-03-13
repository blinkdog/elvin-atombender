# terminal.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class Terminal
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'S'
    @fg = '#675200'
    @bg = '#000'
    @desc = 'Security Terminal'
    @visible = true
    
  getSpeed: -> 100
  
  act: ->

exports.Terminal = Terminal

#----------------------------------------------------------------------
# end of terminal.coffee
