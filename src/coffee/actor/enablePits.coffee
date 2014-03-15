# enablePits.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

class EnablePits
  constructor: (@pits, @time)->
    
  getSpeed: -> 100
  
  act: ->
    @time--
    if @time <= 0
      for pit in @pits
        pit.locked = false
      window.game.scheduler.remove this

exports.EnablePits = EnablePits

#----------------------------------------------------------------------
# end of enablePits.coffee
