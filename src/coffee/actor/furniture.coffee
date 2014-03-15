# furniture.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{ROT} = require '../rot.min'

MIN_TIME = 2
MAX_TIME = 20

FURNITURE =
  DESC: [
    # yeah, you were searching it for the articles...
    'Adult Magazine',
    'Bathroom Mirror',
    'Bathroom Sink',
    'Bathtub',
    'Book',
    'Bookcase',
    'Bookshelf',
    'Boombox',
    'Boring Book',
    'Chia Pet',
    'Chromebook',
    'Coat Rack',
    'Coffee Table',
    'Couch',
    'Computer',
    'Computer Table',
    'Crock-Pot',
    'CRT Television',
    'Cupboard',
    'Decorative Pillow',
    'Desktop Computer',
    'Drafting Table',
    'Dresser',
    'Dryer',
    'Electric Dryer',
    'Electric Stove',
    'Electric Washer',
    'Entertainment Center',
    'Filing Cabinet',
    'Floor Lamp',
    'Freezer',
    'Full Bed',
    'Gas Dryer',
    'Gas Stove',
    'Google Nexus',
    'Griddle',
    'Hanging Lamp',
    'Ice Chest',
    'iPad',
    'iPhone',
    'iPod',
    'iPod Touch',
    'Interesting Book',
    'King Bed',
    'Kitchen Sink',
    'Kitchen Table',
    'Lamp',
    'Laptop Computer',
    'Lava Lamp',
    'LCD Television',
    'Magazine',
    'MAKE Magazine',
    'Mixer',
    'Microwave',
    'Netbook',
    'Organ',
    'Pet Rock',
    'Piano',
    'Pillow',
    'Plasma Television',
    'Queen Bed',
    'Radio',
    'Recliner',
    'Refrigerator',
    'Roomba',
    'Samsung Galaxy',
    'Shoebox',
    'Sink',
    'Sitting Desk',
    'Sports Illustrated',
    'Sports Illustrated Swimsuit Issue',
    'Sports Magazine',
    'Standing Desk',
    'Stereo System',
    'Stuffed Animal',
    'Television',
    'Toaster Oven',
    'Toilet',
    'Toilet Paper',
    'Twin Bed',
    'Urinal',
    'Vacuum-Tube Radio',
    'Vacuum-Tube Television',
    'Vending Machine',
    'Waffle Maker',
    'Wardrobe',
    'Workbench'
  ]
  SYMBOL: "abcdefghijklmnopqrstuvwxyz".split ''
  
class Furniture
  constructor: (@x, @y, @layoutRoom, @reward)->
    @ch = FURNITURE.SYMBOL.random()
    @fg = '#000'
    @desc = FURNITURE.DESC.random()
    @searchTime = Math.floor(ROT.RNG.getUniform() * ((MAX_TIME-MIN_TIME)+1)) + MIN_TIME
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
