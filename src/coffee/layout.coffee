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
  layoutX = src.x*2+1
  layoutY = src.y*2+1
  tunnelX = layoutX+dir.x*1
  tunnelY = layoutY+dir.y*1
  newLayout[tunnelY][tunnelX] = tunType
  roomX = layoutX+dir.x*2
  roomY = layoutY+dir.y*2
  newLayout[roomY][roomX] = roomType
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
      layoutX = j*2+1
      layoutY = i*2+1
      roomType = layout[layoutY][layoutX]
      if (roomType is 'E') or (roomType is 'R')
        north = layout[layoutY-1][layoutX]
        if (north is 'X')
          north2 = layout[layoutY-2][layoutX]
          if (north2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:0,y:-1}}
        south = layout[layoutY+1][layoutX]
        if (south is 'X')
          south2 = layout[layoutY+2][layoutX]
          if (south2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:0,y:1}}
        east = layout[layoutY][layoutX+1]
        if (east is 'X')
          east2 = layout[layoutY][layoutX+2]
          if (east2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:1,y:0}}
        west = layout[layoutY][layoutX-1]
        if (west is 'X')
          west2 = layout[layoutY][layoutX-2]
          if (west2 is 'X')
            expandibles.push {src:{x:j,y:i}, dir:{x:-1,y:0}}
  return expandibles

exports.generateFortress = ->
  layout = exports.create()
  layout = exports.initialize layout
  layout = exports.addEntryRoom layout
  while (exports.countRooms(layout) < 31)
    expandibles = exports.expandibleRooms layout
    expandible = expandibles.random()
    layout = exports.addRoom layout, expandible.src, expandible.dir, exports.TUNNEL_TYPE.random(), 'R'
  expandibles = exports.expandibleRooms layout
  expandible = expandibles.random()
  layout = exports.addRoom layout, expandible.src, expandible.dir, exports.TUNNEL_TYPE.random(), 'P'
  return layout

# -----------------------------------------------------------

cloneLayout = (layout) -> layout.slice 0

#----------------------------------------------------------------------
# end of layout.coffee
