# layout.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

exports.FORTRESS_SIZE = FORTRESS_SIZE = { width:9, height:6 }
exports.TUNNEL_TYPE = ['1', '2', '3']

exports.create = ->
  layoutWidth = ((FORTRESS_SIZE.width-1)*2)+3
  layoutHeight = ((FORTRESS_SIZE.height-1)*2)+3
  (('#' for i in [0..layoutWidth-1]) for j in [0..layoutHeight-1])

exports.initialize = (layout) ->
  newLayout = cloneLayout layout
  layoutWidth = ((FORTRESS_SIZE.width-1)*2)+3
  layoutHeight = ((FORTRESS_SIZE.height-1)*2)+3
  for i in [1..layoutHeight-2]
    for j in [1..layoutWidth-2]
      newLayout[i][j] = 'X'
  for i in [0..FORTRESS_SIZE.height-2]
    for j in [0..FORTRESS_SIZE.width-2]
      newLayout[i*2+2][j*2+2] = ' '
  return newLayout

exports.addEntryRoom = (layout) ->
  newLayout = cloneLayout layout
  newLayout[1][1] = 'E'
  return newLayout

exports.addRoom = (layout, src, dir, tunType, roomType) ->
  newLayout = cloneLayout layout
  srcLayoutX = src.x*2+1
  srcLayoutY = src.y*2+1
  tunLayoutX = srcLayoutX+dir.x*1
  tunLayoutY = srcLayoutY+dir.y*1
  newLayout[tunLayoutY][tunLayoutX] = tunType
  roomLayoutX = srcLayoutX+dir.x*2
  roomLayoutY = srcLayoutY+dir.y*2
  newLayout[roomLayoutY][roomLayoutX] = roomType
  return newLayout

exports.countRooms = (layout) ->
  roomCount = 0
  for i in [0..FORTRESS_SIZE.height-1]
    for j in [0..FORTRESS_SIZE.width-1]
      roomCount++ if layout[i*2+1][j*2+1] is 'E'
      roomCount++ if layout[i*2+1][j*2+1] is 'R'
      roomCount++ if layout[i*2+1][j*2+1] is 'P'
  return roomCount

exports.expandibleRooms = (layout) ->
  expandibles = []
  for i in [0..FORTRESS_SIZE.height-1]
    for j in [0..FORTRESS_SIZE.width-1]
      roomType = layout[i*2+1][j*2+1]
      if (roomType is 'E') or (roomType is 'R')
        north = layout[i*2][j*2+1]
        if (north is 'X')
          north2 = layout[i*2-1][j*2+1]
          if (north2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:0,y:-1}, replace:north}
        south = layout[i*2+2][j*2+1]
        if (south is 'X')
          south2 = layout[i*2+3][j*2+1]
          if (south2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:0,y:1}, replace:south}
        east = layout[i*2+1][j*2+2]
        if (east is 'X')
          east2 = layout[i*2+1][j*2+3]
          if (east2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:1,y:0}, replace:east}
        west = layout[i*2+1][j*2]
        if (west is 'X')
          west2 = layout[i*2+1][j*2]
          if (west2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:-1,y:0}, replace:west}
  return expandibles

exports.generateFortress = ->
  layout = exports.create()
  layout = exports.initialize layout
  layout = exports.addEntryRoom layout
  while exports.countRooms(layout) < 31
    expandibles = exports.expandibleRooms layout
    expandible = expandibles.random()
    layout = exports.addRoom layout, expandible.src, expandible.dir, exports.TUNNEL_TYPE.random(), 'R'
  expandibles = exports.expandibleRooms layout
  expandible = expandibles.random()
  layout = exports.addRoom layout, expandible.src, expandible.dir, exports.TUNNEL_TYPE.random(), 'P'
  return layout

# -----------------------------------------------------------

cloneLayout = (layout) ->
  newLayout = []
  for i in [0..layout.length-1]
    newLayout[i] = []
    for j in [0..layout[i].length-1]
      newLayout[i][j] = layout[i][j]
  return newLayout

#----------------------------------------------------------------------
# end of layout.coffee
