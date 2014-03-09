# mapTest.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

should = require 'should'
Layout = require '../lib/layout'
Map = require '../lib/map'

describe 'FortressMap', ->
  it 'should be testable', ->
    should(true).equal true

  it 'should have a specific ROOM_SIZE', ->
    Map.ROOM_SIZE.width.should.equal 19
    Map.ROOM_SIZE.height.should.equal 13

  it 'should create a blank map', ->
    layout = Layout.generateFortress()
    layoutHeight = layout.length
    layoutWidth = layout[0].length
    map = Map.create layout
    map.length.should.equal Map.ROOM_SIZE.height * layoutHeight
    for i in [0..map.length-1]
      map[i].length.should.equal Map.ROOM_SIZE.width * layoutWidth
    for i in [0..map.length-1]
      for j in [0..map[i].length-1]
        map[i][j].should.equal '#'

  it 'should add a layout', ->
    layout = Layout.generateFortress()
    layoutHeight = layout.length
    layoutWidth = layout[0].length
    map = Map.create layout
    map = Map.addLayout map, layout
#    result = (map[row].join '' for row in [0..map.length-1])
#    console.log '\n'+result.join '\n'
#    result = (layout[row].join '' for row in [0..layout.length-1])
#    console.log '\n'+result.join '\n'

  xit 'should display nicely', ->
    Array::random ?= ->
      return null if not this.length?
      return this[Math.floor(Math.random() * this.length)]
    layout = Layout.generateFortress()
    Layout.countRooms(layout).should.equal 32
    result = (layout[row].join '' for row in [0..layout.length-1])
    console.log '\n'+result.join '\n'

#----------------------------------------------------------------------
# end of mapTest.coffee
