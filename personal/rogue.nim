# ****************************************************************************************
#
#   Advent Of Code Solution - Beverage Bandits (https://adventofcode.com/2018/day/15)
#
#   Solution originally created with naylib 5.2
#
#   Solution licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, std/[algorithm, math, heapqueue, sets, hashes, fenv]

const
  col1 = Color(r: 160, g: 154, b: 146, a: 255) # DustyGrey
  col2 = Color(r: 47, g: 88, b: 141, a: 255) # LightNavyBlue
  col3 = Color(r: 37, g: 47, b: 64, a: 255) # EbonyClay
  col4 = Color(r: 244, g: 220, b: 109, a: 255) # Goldenrod
  col5 = Color(r: 78, g: 131, b: 87, a: 255) # DarkSage

const
  # Map used for testing
  MapWidth = 7 # Width in tiles
  MapHeight = 7 # Height in tiles
  # 2D array representing map tile IDs
  Map: array[MapWidth*MapHeight, int16] = [
    10, 10, 10, 2, 88, 88, 2,
    2, 146, 146, 146, 189, 146, 2,
    2, 189, 28, 146, 146, 210, 29,
    2, 146, 146, 129, 114, 146, 29,
    2, 210, 146, 146, 28, 209, 28,
    2, 146, 209, 146, 2, 146, 2,
    29, 28, 28, 29, 28, 2, 2
  ]
  # 2D array representing entity IDs on the map
  Entities: array[MapWidth*MapHeight, int16] = [
    0, 0, 0, 0, 0, 0, 0,
    0, 142, 0, 0, 0, 123, 0,
    0, 0, 0, 123, 0, 142, 0,
    0, 142, 0, 0, 0, 0, 0,
    0, 123, 0, 0, 0, 0, 0,
    0, 0, 0, 142, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0
  ]
  # 2D arrays representing foreground and background colors for each tile
  BgColors: array[MapWidth*MapHeight, Color] = [
    col3, col3, col3, col1, col3, col3, col1,
    col1, col3, col3, col3, col3, col3, col1,
    col1, col3, col2, col3, col3, col3, col2,
    col1, col3, col3, col1, col1, col3, col2,
    col1, col3, col3, col3, col2, col3, col2,
    col1, col3, col3, col3, col1, col3, col1,
    col2, col2, col2, col2, col2, col1, col1,
  ]
  FgColors: array[MapWidth*MapHeight, Color] = [
    col2, col2, col2, col2, col2, col2, col2,
    col2, col2, col2, col2, col1, col2, col2,
    col2, col1, col1, col2, col2, col2, col1,
    col2, col2, col2, col2, col2, col2, col1,
    col2, col2, col2, col2, col1, col2, col1,
    col2, col2, col2, col2, col2, col2, col2,
    col1, col1, col1, col1, col1, col2, col2
  ]

# Tileset properties
const
  TileSize = 12 # in pixels
  TilesetWidth = 16 # in tiles
  # Set the source coordinates for each tile in the tileset
  Tileset = block:
    var tileset: array[1..TilesetWidth*TilesetWidth, tuple[x, y: int16]]
    # Calculate tile coordinates from index
    func getTileCoords(index: int16): (int16, int16) =
      let (y, x) = divmod(index, TilesetWidth)
      result = (x*TileSize, y*TileSize)
    # Assign coordinates to each tile
    for i in 1..TilesetWidth*TilesetWidth:
      tileset[i] = getTileCoords(int16(i - 1))
    tileset

const
  AttackPower = 3

type
  TileIdx = distinct int32
  UnitIdx = distinct int32

  Race = enum
    Elf, Goblin

  Unit = object
    cell: TileIdx # Index of the tile the unit is on
    health: int16
    race: Race

  Tile = object
    position: tuple[x, y: int16]
    npc: UnitIdx # Index of the unit on the tile (if any)
    wall: bool # Is the tile a wall?

  Tiles = array[TileIdx(MapWidth*MapHeight), Tile]
  Units = seq[Unit]

const
  NilUnitIdx = UnitIdx(-1) # Invalid unit index
  NilTileIdx = TileIdx(-1) # Invalid tile index

proc parseMap(map, entities: array[MapWidth*MapHeight, int16]): (Tiles, Units) =
  var tiles: Tiles
  var units: seq[Unit] = @[]
  var count: int32 = 0
  for i in 0..<MapWidth*MapHeight:
    # Calculate the row and column of the tile
    let (y, x) = divmod(i.int16, MapWidth)
    tiles[TileIdx(i)].position = (x, y)
    case entities[i]
    of 142: # Stalker (Elf)
      units.add(Unit(race: Elf, cell: TileIdx(i), health: 200))
      tiles[TileIdx(i)].npc = UnitIdx(count)
      inc count
    of 123: # Zombie (Goblin)
      units.add(Unit(race: Goblin, cell: TileIdx(i), health: 200))
      tiles[TileIdx(i)].npc = UnitIdx(count)
      inc count
    else:
      tiles[TileIdx(i)].npc = NilUnitIdx # No unit is present
    case map[i]
    of 146, 189, 209, 210: # Passable terrain
      tiles[TileIdx(i)].wall = false
    else:
      tiles[TileIdx(i)].wall = true
  result = (tiles, units)

proc `==`(a, b: UnitIdx): bool {.borrow.}

iterator neighbors(index: TileIdx): TileIdx =
  # Returns the neighboring tile indices of a given tile index
  const offsets = [ # Stores all cardinal directions
    # Up, Left, Right, Down,
    -MapWidth.int32, -1, 1, MapWidth
  ]
  for x in offsets.items:
    # Relies on the fact that the map's borders are walls
    yield TileIdx(index.int32 + x)

proc isOpenPosition(tiles: Tiles, index: TileIdx): bool {.inline.} =
  # Checks if a given tile index represents an open position
  result = not tiles[index].wall and tiles[index].npc == NilUnitIdx

proc heuristic(a, b: tuple[x, y: int16]): float32 {.inline.} =
  # Calculate the heuristic between two positions using the Euclidean distance formula
  result = sqrt(float32((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y)))

proc cmp(a, b: TileIdx): int {.inline.} =
  # Compares two tile indices in reading order
  # Returns a negative value if a < b, 0 if a == b, and a positive value if a > b
  result = a.int32 - b.int32

proc inssort(a: var seq[Unit]) =
  # Sorts the units based on their cell indices in reading order.
  # Uses the insertion sort algorithm
  for i in 1..high(a):
    let value = a[i]
    var j = i
    while j > 0 and cmp(value.cell, a[j-1].cell) < 0:
      a[j] = a[j-1]
      dec j
    a[j] = value

type
  PathPlanning = object
    goal: TileIdx
    g, f: float32 # Cost from start and total cost

proc `==`(a, b: TileIdx): bool {.borrow.}
proc hash(x: TileIdx): Hash {.borrow.}

# Stores the path planning information for each tile on the map
var planning: array[TileIdx(MapWidth*MapHeight), PathPlanning]

proc `<`(a, b: TileIdx): bool {.inline.} =
  # Used to maintain the heap property
  if planning[a].f < planning[b].f:
    return true
  if planning[a].f > planning[b].f:
    return false
  if cmp(planning[a].goal, planning[b].goal) < 0:
    return true
  if cmp(planning[a].goal, planning[b].goal) < 0:
    return false
  return cmp(a, b) < 0

proc `not`(x: Race): Race = Race(not x.bool)

type
  BattleSimStatus = enum
    ElfVictory,
    ElfDefeat,
    Running,
    Uninitialized,

# Game Screen properties
const
  WindowScale = 4

  screenWidth = MapWidth*TileSize*WindowScale
  screenHeight = MapHeight*TileSize*WindowScale

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "Advent Of Code - Beverage Bandits")
  defer: closeWindow() # Close window and OpenGL context
  # Create a Camera2D
  var camera = Camera2D(zoom: WindowScale)
  # Load the tileset image
  let tileset = loadTexture("resources/lambdarogue.png")
  # Create RenderTexture2D objects for rendering to textures
  # target is used for the main rendering, and background is used for the background colors
  let target = loadRenderTexture(screenWidth, screenHeight)
  let background = loadRenderTexture(screenWidth, screenHeight)
  # Load the CRT shader
  let shader = loadShader("", "resources/shaders/retro_crt.fs")
  # Set the shader uniform for the screen size.
  let screenSize = [screenWidth.float32, screenHeight.float32]
  setShaderValue(shader, getShaderLocation(shader, "size"), screenSize)
  # Draw the background colors to the background texture
  textureMode(background):
    for i in 0..<MapWidth*MapWidth:
      let (y, x) = divmod(i, MapWidth) # In Tiled: y*Width + x
      let pos = Vector2(x: x.float32*TileSize, y: y.float32*TileSize)
      drawRectangle(pos, Vector2(x: TileSize, y: TileSize), BgColors[i])
  # Parse the map data
  var (tiles, units) = parseMap(Map, Entities)
  # Declare the frontier queue and the discovered set for pathfinding
  var frontier: HeapQueue[TileIdx]
  var discovered: HashSet[TileIdx]
  # Initialize the round counter and the battle simulation status
  var round: int32 = 0
  var status = Uninitialized
  var count: array[Race, int8]
  # --------------------------------------------------------------------------------------
  # Main game loop
  setTargetFPS(1) # Set our game to run at 60 frames-per-second
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if status == Uninitialized:
      # Count the number of units for each race
      for unit in units.items:
        inc count[unit.race]
      status = Running
    elif status == Running:
      # Remove dead units from the units seq
      for i in countdown(high(units), 0):
        if units[i].health <= 0:
          units.del(i)
          # Repair the location of the moved item
          tiles[units[i].cell].npc = UnitIdx(i)
      # Sort the units in reading order
      units.inssort()
      # Update the unit indices on the tiles
      for i in 0..high(units):
        tiles[units[i].cell].npc = UnitIdx(i)
      # Iterate in reading order
      for i in 0..high(units):
        template unit: untyped = units[i]
        # Check if the opposing race has no units left
        if count[not unit.race] == 0:
          status = BattleSimStatus(unit.race)
          break
        elif unit.health > 0:
          var targetIdx = NilUnitIdx
          # Check if there's an enemy unit in range
          # and find the target with the lowest health
          var minHealth = high(int16)
          for neighborIdx in neighbors(unit.cell):
            let idx = tiles[neighborIdx].npc
            if idx != NilUnitIdx:
              template target: untyped = units[idx.int]
              if target.race != unit.race and minHealth > target.health:
                minHealth = target.health
                targetIdx = idx
          if targetIdx == NilUnitIdx:
            # Clear the frontier, discovered set, and reset the path planning
            frontier.clear()
            discovered.clear()
            planning.fill(PathPlanning(
              goal: NilTileIdx,
              f: maximumPositiveValue(float32), g: maximumPositiveValue(float32)
            ))
            # Find all enemy units and add their neighboring open positions to the frontier
            for target in units.items:
              if target.health > 0 and target.race != unit.race:
                template neighbor: untyped = planning[neighborIdx]
                for neighborIdx in neighbors(target.cell):
                  if neighbor.goal == NilTileIdx and isOpenPosition(tiles, neighborIdx):
                    neighbor.goal = neighborIdx
                    neighbor.g = 0
                    neighbor.f = heuristic(tiles[unit.cell].position, tiles[neighborIdx].position)
                    frontier.push(neighborIdx)
                # Simultaneously plans backwards from all goal positions to the unit
                while frontier.len > 0:
                  let currentIdx = frontier.pop()
                  discovered.incl(currentIdx)
                  template current: untyped = planning[currentIdx]
                  # Check the neighbors of the current position
                  for neighborIdx in neighbors(currentIdx):
                    if neighborIdx notin discovered and isOpenPosition(tiles, neighborIdx):
                      let tempG = current.g + 1
                      # Is this a better path than before?
                      var newPath = false
                      if neighborIdx in frontier:
                        # Break ties with path length, then goal positions and then positions
                        if tempG < neighbor.g or
                            (tempG == neighbor.g and cmp(current.goal, neighbor.goal) < 0):
                          neighbor.g = tempG
                          newPath = true
                      else:
                        neighbor.g = tempG
                        newPath = true
                        frontier.push(neighborIdx)
                      # Yes, it's a better path
                      if newPath:
                        neighbor.f = neighbor.g + heuristic(tiles[unit.cell].position, tiles[neighborIdx].position)
                        neighbor.goal = current.goal
                # Find the best neighboring position to move to
                var bestGoal = NilTileIdx
                var bestG = maximumPositiveValue(float32)
                var bestNeighbor = NilTileIdx
                for neighborIdx in neighbors(unit.cell):
                  if isOpenPosition(tiles, neighborIdx) and (neighbor.g < bestG or
                      (neighbor.g == bestG and cmp(neighbor.goal, bestGoal) < 0)):
                    bestGoal = neighbor.goal
                    bestG = neighbor.g
                    bestNeighbor = neighborIdx
                if bestNeighbor != NilTileIdx:
                  # Move the unit to the best neighboring position
                  tiles[unit.cell].npc = NilUnitIdx
                  unit.cell = bestNeighbor
                  tiles[unit.cell].npc = UnitIdx(i)
                  # Update the target to the enemy unit with the lowest health in range
                  var minHealth = high(int16)
                  for neighborIdx in neighbors(unit.cell):
                    let idx = tiles[neighborIdx].npc
                    template target: untyped = units[idx.int]
                    if idx != NilUnitIdx:
                      if target.race != unit.race and minHealth > target.health:
                        minHealth = target.health
                        targetIdx = idx
          if targetIdx != NilUnitIdx:
            # If a target is found, attack the target
            template target: untyped = units[targetIdx.int]
            target.health -= AttackPower
            if target.health <= 0:
              # Reduce the team count
              dec count[target.race]
              # Clear out the targets location
              tiles[target.cell].npc = NilUnitIdx
              #target.cell = NilTileIdx
      inc round
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    textureMode(target): # Enable drawing to texture
      mode2D(camera):
        # Draw the background texture
        let src = Rectangle(x: 0, y: 0, width: background.texture.width.float32,
            height: -background.texture.height.float32)
        drawTexture(background.texture, src, Vector2(x: 0, y: 0), White)
        # Iterate over each tile in the map and draw the corresponding textures
        for i in 0..<MapWidth*MapWidth:
          template tile: untyped = tiles[TileIdx(i)]
          let (x, y) = tile.position
          let pos = Vector2(x: x.float32*TileSize, y: y.float32*TileSize)
          let (tileX, tileY) = Tileset[Map[i]]
          let rec = Rectangle(x: tileX.float32, y: tileY.float32, width: TileSize, height: TileSize)
          let idx = tile.npc
          template unit: untyped = units[idx.int]
          if idx == NilUnitIdx: # or unit.health <= 0
            drawTexture(tileset, rec, pos, FgColors[i.int])
          else:
            # Draw the entity tile if any
            let (entX, entY) = Tileset[if unit.race == Elf: 142 else: 123]
            let rec = Rectangle(x: entX.float32, y: entY.float32, width: TileSize, height: TileSize)
            drawTexture(tileset, rec, pos, if unit.race == Elf: col4 else: col5)
    drawing():
      clearBackground(Black)
      shaderMode(shader):
        # Draw the target texture using the shader.
        let src = Rectangle(x: 0, y: 0, width: target.texture.width.float32,
            height: -target.texture.height.float32)
        drawTexture(target.texture, src, Vector2(x: 0, y: 0), White)
    # ------------------------------------------------------------------------------------

main()