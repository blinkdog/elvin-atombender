# access.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class AccessPanel
  constructor: (@x, @y, @layoutRoom)->
    @ch = 'M'
    @fg = '#483aaa'
    @bg = '#000'
    @desc = 'Access Panel'
    @visible = true
    
  getSpeed: -> 100
  
  act: ->
  
exports.AccessPanel = AccessPanel

#----------------------------------------------------------------------
# end of access.coffee
