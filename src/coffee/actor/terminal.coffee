# terminal.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class Terminal
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'S'
    @fg = '#8a8a8a'
    @bg = '#000'
    @desc = 'Security Terminal'
    
  getSpeed: -> 100
  
  act: ->

exports.Terminal = Terminal

#----------------------------------------------------------------------
# end of terminal.coffee
