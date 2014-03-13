# map.coffee
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

exports.ROOM_SIZE = ROOM_SIZE = {width: 19, height: 13}

exports.create = (layout) ->
  layoutHeight = layout.length
  layoutWidth = layout[0].length
  mapHeight = ROOM_SIZE.height * layoutHeight
  mapWidth = ROOM_SIZE.width * layoutWidth
  (('#' for i in [0..mapWidth-1]) for j in [0..mapHeight-1])

exports.addLayout = (map, layout) ->
  newMap = cloneMap map
  for i in [0..layout.length-1]
    for j in [0..layout[i].length-1]
      addBlock newMap, j*ROOM_SIZE.width, i*ROOM_SIZE.height, layout[i][j], i%2
  return newMap

exports.generateFortress = (layout) ->
  newMap = exports.create layout
  newMap = exports.addLayout newMap, layout
  return newMap

exports.revealSecureRoom = (map, layout) ->
  newMap = cloneMap map
  for i in [0..layout.length-1]
    for j in [0..layout[i].length-1]
      if layout[i][j] is 'P'
        addBlock newMap, j*ROOM_SIZE.width, i*ROOM_SIZE.height, 'M', i%2
  return newMap

#------------------------------------------------------------

cloneMap = (map) -> map.slice 0

addBlock = (map, mapX, mapY, blockType, rowParity) ->
  oddRow = false if rowParity is 0
  oddRow = true if rowParity is 1
  switch blockType
    when 'E', 'R'
      for i in [0..ROOM_SIZE.height-1]
        for j in [0..ROOM_SIZE.width-1]
          map[mapY+i][mapX+j] = ' '
    when 'P'
      for i in [0..ROOM_SIZE.height-1]
        for j in [0..ROOM_SIZE.width-1]
          map[mapY+i][mapX+j] = 'X'
    when '1'
      if oddRow
        # horizontal tunnel
        for i in [1..3]
          for j in [0..ROOM_SIZE.width-1]
            map[mapY+i][mapX+j] = ' '
      else
        # vertical tunnel
        for i in [0..ROOM_SIZE.height-1]
          for j in [1..5]
            map[mapY+i][mapX+j] = ' '
    when '2'
      if oddRow
        # horizontal tunnel
        for i in [5..7]
          for j in [0..ROOM_SIZE.width-1]
            map[mapY+i][mapX+j] = ' '
      else
        # vertical tunnel
        for i in [0..ROOM_SIZE.height-1]
          for j in [7..11]
            map[mapY+i][mapX+j] = ' '
    when '3'
      if oddRow
        # horizontal tunnel
        for i in [9..11]
          for j in [0..ROOM_SIZE.width-1]
            map[mapY+i][mapX+j] = ' '
      else
        # vertical tunnel
        for i in [0..ROOM_SIZE.height-1]
          for j in [13..17]
            map[mapY+i][mapX+j] = ' '
    when 'M'
      for i in [0..ROOM_SIZE.height-1]
        for j in [0..ROOM_SIZE.width-1]
          map[mapY+i][mapX+j] = ' '

#----------------------------------------------------------------------
# end of map.coffee
