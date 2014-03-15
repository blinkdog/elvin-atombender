# sfx.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

SOUNDS = [
  "another-visitor",
  "destroy-him",
  "dial-a-hack",
  "elvin-laugh",
  "elvin-no",
  "falling",
  "mission-accomplished",
  "pc-negative",
  "pc-off",
  "pc-on",
  "pc-positive",
  "player-zapped"
]

class SoundBoard
  constructor: ->
  
  init: ->
    @supported = window.Audio?
    if @supported
      micCheck = new Audio()
      @supported = micCheck.canPlayType 'audio/ogg'
    if @supported
      @audio = {}
      for name in SOUNDS
        @loadSound name

  loadSound: (name) ->
    @audio[name] = new Audio getFilename name
    @audio[name].load()

  playSound: (name) ->
    return if not @supported
    @audio[name].play()

exports.SoundBoard = SoundBoard

#------------------------------------------------------------

getFilename = (name) ->
  "sfx/" + name  + ".ogg"

#----------------------------------------------------------------------
# end of sfx.coffee
