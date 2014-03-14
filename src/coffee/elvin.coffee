# elvin.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require './rot.min'
{ImpossibleMission} = require './impossible'

exports.run = ->
  # nice little bits of CoffeeScript
  # http://stackoverflow.com/a/4826179
  Array::remove ?= (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
  # https://www.youtube.com/watch?v=FrLequ6dUdM
  if isMSIE()
    window.location.href = 'http://donotuseie.com/'
    return;
  if not ROT.isSupported()
    window.location.href = 'https://mozilla.org/firefox'
    return;
  # https://www.youtube.com/watch?v=i1_fDwX1VVY
  window.game = new ImpossibleMission()
  window.game.run()

isMSIE = ->
  return true if navigator?.appName is 'Microsoft Internet Explorer'
  return true if window?.msRequestAnimationFrame?
  return false

#----------------------------------------------------------------------
# end of elvin.coffee
