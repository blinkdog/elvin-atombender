# furniture.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

FURNITURE = [
  # TODO: Revise the search time and colors on these items
  { ch:'a', fg:'#000', desc:'Coat Rack', time: 5 },
  { ch:'b', fg:'#000', desc:'Bookcase', time: 5 },
  { ch:'c', fg:'#000', desc:'Couch', time: 5 },
  { ch:'d', fg:'#000', desc:'Desk', time: 5 },
  { ch:'e', fg:'#000', desc:'Recliner', time: 5 },
  { ch:'f', fg:'#000', desc:'Floor Lamp', time: 5 },
  { ch:'g', fg:'#000', desc:'Gas Stove', time: 5 },
  { ch:'h', fg:'#000', desc:'Bathtub', time: 5 },
  { ch:'i', fg:'#000', desc:'iPhone 5', time: 5 },
  { ch:'j', fg:'#000', desc:'Coffee Table', time: 5 },
  { ch:'k', fg:'#000', desc:'Desktop Computer', time: 5 },
  { ch:'l', fg:'#000', desc:'Laptop Computer', time: 5 },
  { ch:'m', fg:'#000', desc:'Refridgerator', time: 5 },
  { ch:'n', fg:'#000', desc:'Sink', time: 5 },
  { ch:'o', fg:'#000', desc:'Piano', time: 5 },
  { ch:'p', fg:'#000', desc:'Toilet Paper', time: 5 },
  { ch:'q', fg:'#000', desc:'Chia Pet', time: 5 },
  { ch:'r', fg:'#000', desc:'Roomba', time: 5 },
  { ch:'s', fg:'#000', desc:'Television', time: 5 },
  { ch:'t', fg:'#000', desc:'Toilet', time: 5 },
  { ch:'u', fg:'#000', desc:'Hanging Lamp', time: 5 },
  { ch:'v', fg:'#000', desc:'Vending Machine', time: 5 },
  { ch:'w', fg:'#000', desc:'Twin Bed', time: 5 },
  # yeah... you were searching it for the articles... sure
  { ch:'x', fg:'#000', desc:'Adult Magazine', time: 5 },
  { ch:'y', fg:'#000', desc:'Decorative Pillow', time: 5 },
  { ch:'z', fg:'#000', desc:'Stuffed Animal', time: 5 }
]

class Furniture
  constructor: (@x, @y, @layoutRoom, @reward)->
    me = FURNITURE.random()
    @ch = me.ch
    @fg = me.fg
    @desc = me.desc
    @searchTime = me.time
    @visible = true
    
  getSpeed: -> -1
  
  act: ->
    if @reward?
      window.game.state.addReward @reward
    window.game.state.removeObject this
    window.game.scheduler.remove this
  
exports.Furniture = Furniture

#----------------------------------------------------------------------
# end of furniture.coffee
