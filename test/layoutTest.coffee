# layoutTest.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

should = require 'should'
Layout = require '../lib/layout'

describe 'FortressLayout', ->
  it 'should be testable', ->
    should(true).equal true

  it 'should create an empty layout', ->
    layout = Layout.create()
    layout.length.should.equal 13
    for i in [0..layout.length-1]
      layout[i].length.should.equal 19
    for i in [0..layout.length-1]
      for j in [0..layout[i].length-1]
        layout[i][j].should.equal '#'

  it 'should initialize a starting layout', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout.height = layout.length
    layout.width = layout[0].length
    for i in [0..layout.width-1]
      layout[0][i].should.equal '#'
      layout[layout.length-1][i].should.equal '#'
    for i in [0..layout.height-1]
      layout[i][0].should.equal '#'
      layout[i][layout.width-1].should.equal '#'
    for i in [0..Layout.FORTRESS_SIZE.height-2]
      for j in [0..Layout.FORTRESS_SIZE.width-2]
        layout[i*2+1][j*2+1].should.equal 'X'
        layout[i*2+1][j*2+2].should.equal 'X'
        layout[i*2+2][j*2+1].should.equal 'X'
        layout[i*2+2][j*2+2].should.equal ' '
    for i in [1..layout.height-2]
      layout[i][layout.width-2].should.equal 'X'
    for j in [1..layout.width-2]
      layout[layout.height-2][j].should.equal 'X'

  it 'should add a entry room', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout = Layout.addEntryRoom layout
    layout.height = layout.length
    layout.width = layout[0].length
    layout[1][1].should.equal 'E'

  it 'should add a room to the south', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout = Layout.addEntryRoom layout
    layout = Layout.addRoom layout, {x:0,y:0}, {x:0,y:1}, '2', 'R'
    layout.height = layout.length
    layout.width = layout[0].length
    layout[1][1].should.equal 'E'
    layout[2][1].should.equal '2'
    layout[3][1].should.equal 'R'

  it 'should add a room to the east', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout = Layout.addEntryRoom layout
    layout = Layout.addRoom layout, {x:0,y:0}, {x:1,y:0}, '1', 'R'
    layout.height = layout.length
    layout.width = layout[0].length
    layout[1][1].should.equal 'E'
    layout[1][2].should.equal '1'
    layout[1][3].should.equal 'R'

  it 'should be able to count rooms', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout = Layout.addEntryRoom layout
    layout = Layout.addRoom layout, {x:0,y:0}, {x:0,y:1}, '2', 'R'
    layout = Layout.addRoom layout, {x:0,y:1}, {x:1,y:0}, '1', 'R'
    layout = Layout.addRoom layout, {x:1,y:1}, {x:0,y:-1}, '3', 'R'
    Layout.countRooms(layout).should.equal 4

  it 'should be able to enumerate expandible rooms', ->
    layout = Layout.create()
    layout = Layout.initialize layout
    layout = Layout.addEntryRoom layout
    Layout.expandibleRooms(layout).length.should.equal 2

  it 'should be able to provide a complete layout', ->
    Array::random ?= ->
      return null if not this.length?
      return this[Math.floor(Math.random() * this.length)]
    layout = Layout.generateFortress()
    Layout.countRooms(layout).should.equal 32

  xit 'should display nicely', ->
    Array::random ?= ->
      return null if not this.length?
      return this[Math.floor(Math.random() * this.length)]
    layout = Layout.generateFortress()
    Layout.countRooms(layout).should.equal 32
    result = (layout[row].join '' for row in [0..layout.length-1])
    console.log '\n'+result.join '\n'

#----------------------------------------------------------------------
# end of layoutTest.coffee
