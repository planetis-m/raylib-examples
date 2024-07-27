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

# Include map data
include map14

# Tileset properties
const
  TileSize = 12 # in pixels
  TilesetWidth = 16 # in tiles
  TilesetSize = TilesetWidth*TilesetWidth

  ElfTileIdx = 142
  GoblinTileIdx = 123

# Function to calculate tile coordinates from index
func getTilesetCoords(index: int16): (int16, int16) =
  let (y, x) = divmod(index, TilesetWidth)
  result = (x*TileSize, y*TileSize)

# Create lookup table (LUT) for tileset coordinates
const
  Tileset = block:
    var lut: array[1..TilesetSize, tuple[x, y: int16]]
    # Assign coordinates to each tile
    for i in 1..TilesetSize:
      lut[i] = getTilesetCoords(int16(i - 1))
    lut

# Game constants
const
  AttackPower = 3
  DefaultHealth = 200

# Type definitions for game entities and map tiles
type
  CellIdx = distinct int32
  UnitIdx = distinct int32

  Race = enum
    Elf, Goblin

  Unit = object
    cell: CellIdx # Index of the cell the unit is on
    health: int16
    race: Race

  Cell = object
    position: tuple[x, y: int16]
    unit: UnitIdx # Index of the unit on the cell (if any)
    wall: bool # Is the cell a wall?

  Cells = array[CellIdx(MapWidth*MapHeight), Cell]
  Units = seq[Unit]

const
  NilUnitIdx = UnitIdx(-1) # Invalid unit index
  NilCellIdx = CellIdx(-1) # Invalid cell index

proc parseEntityLayer(entities: array[MapWidth*MapHeight, int16]): (Cells, Units) =
  var cells: Cells
  var units: seq[Unit] = @[]
  var count: int32 = 0
  for i in 0..<MapWidth*MapHeight:
    # Calculate the row and column of the cell
    let (y, x) = divmod(i.int16, MapWidth)
    cells[CellIdx(i)] = Cell(
      position: (x, y),
      unit: NilUnitIdx,
      wall: Walls[i]
    )
    case entities[i]
    of ElfTileIdx:
      units.add(Unit(race: Elf, cell: CellIdx(i), health: DefaultHealth))
      cells[CellIdx(i)].unit = UnitIdx(count)
      inc count
    of GoblinTileIdx:
      units.add(Unit(race: Goblin, cell: CellIdx(i), health: DefaultHealth))
      cells[CellIdx(i)].unit = UnitIdx(count)
      inc count
    else:
      cells[CellIdx(i)].unit = NilUnitIdx # No unit is present
  (cells, units)

func healthToAlpha(health: int16): float32 {.inline.} =
  # Converts a unit's health value to the alpha parameter of
  # the fade function in two steps
  if health < 10:
    return 0.2
  elif health < 110:
    return 0.6
  else:
    return 1.0

func raceToTileIndex(race: Race): int16 {.inline.} =
  # Get the tile index based on the race
  case race
  of Elf: ElfTileIdx
  of Goblin: GoblinTileIdx

func raceToColor(race: Race): Color =
  case race
  of Elf: ElfColor
  of Goblin: GoblinColor

proc `==`(a, b: UnitIdx): bool {.borrow.}

iterator neighbors(index: CellIdx): CellIdx =
  # Returns the neighboring cell indices of a given cell index
  const offsets = [ # Stores all cardinal directions
    # Up, Left, Right, Down,
    -MapWidth.int32, -1, 1, MapWidth
  ]
  for x in offsets.items:
    # Relies on the fact that the map's borders are all walls
    yield CellIdx(index.int32 + x)

proc isOpenPosition(cells: Cells, index: CellIdx): bool {.inline.} =
  # Checks if a given cell index represents an open position
  not cells[index].wall and cells[index].unit == NilUnitIdx

proc heuristic(a, b: tuple[x, y: int16]): float32 {.inline.} =
  # Calculate the heuristic between two positions using the Euclidean distance formula
  sqrt(float32((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y)))

proc cmp(a, b: CellIdx): int {.inline.} =
  # Compares two cell indices in reading order
  # Returns a negative value if a < b, 0 if a == b, and a positive value if a > b
  a.int32 - b.int32

proc `<`(a, b: CellIdx): bool {.inline.} = cmp(a, b) < 0
proc `<`(a, b: Unit): bool {.inline.} = a.cell < b.cell

proc inssort(a: var seq[Unit]) =
  # Sorts the units based on their cell indices in reading order.
  # Uses the insertion sort algorithm
  for i in 1..high(a):
    let value = a[i]
    var j = i
    while j > 0 and value < a[j - 1]:
      a[j] = a[j - 1]
      dec j
    a[j] = value

type
  TilePriority = distinct CellIdx # Special type for use with the heapqueue

  PathPlanning = object
    goal: CellIdx
    g, f: float32 # Cost from start and total cost

proc `==`(a, b: CellIdx): bool {.borrow.}
proc hash(x: CellIdx): Hash {.borrow.}

proc `==`(a, b: TilePriority): bool {.borrow.}

# Stores the path planning information for each cell on the map
var planning: array[CellIdx(MapWidth*MapHeight), PathPlanning]

proc `<`(a, b: TilePriority): bool {.inline.} =
  # Used to maintain the heap property
  if planning[a].f < planning[b].f:
    return true
  if planning[a].f > planning[b].f:
    return false
  if planning[a].goal < planning[b].goal:
    return true
  if planning[a].goal > planning[b].goal:
    return false
  a.CellIdx < b.CellIdx

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
  # setConfigFlags(flags(WindowHighDPI))
  initWindow(screenWidth, screenHeight, "Advent Of Code - Beverage Bandits")
  defer: closeWindow() # Close window and OpenGL context
  # Create a Camera2D
  var camera = Camera2D(zoom: WindowScale)
  # Load the tileset image
  let tileset = loadTexture("resources/lambdarogue.png")
  # Create RenderTexture2D objects for rendering to textures
  # target is used for rendering the units, and background for the map
  let target = loadRenderTexture(screenWidth, screenHeight)
  let background = loadRenderTexture(screenWidth, screenHeight)
  # Load the CRT shader
  let shader = loadShader("", "resources/shaders/retro_crt.fs")
  # Set the shader uniform for the screen size.
  let screenSize = Vector2(x: screenWidth, y: screenHeight)
  setShaderValue(shader, getShaderLocation(shader, "size"), screenSize)
  # Parse the map data
  var (cells, units) = parseEntityLayer(Entities)
  # Iterate over each cell in the map and draw the corresponding textures
  textureMode(background):
    for i in 0..<MapWidth*MapHeight:
      template cell: untyped = cells[CellIdx(i)]
      let (x, y) = cell.position
      let pos = Vector2(x: x.float32*TileSize, y: y.float32*TileSize)
      # Draw the background color
      drawRectangle(pos, Vector2(x: TileSize, y: TileSize), BgColors[i])
      let (tileX, tileY) = Tileset[Map[i]]
      let rec = Rectangle(x: tileX.float32, y: tileY.float32, width: TileSize, height: TileSize)
      drawTexture(tileset, rec, pos, FgColors[i])
  # Declare the frontier queue and the discovered set for pathfinding
  var frontier: HeapQueue[TilePriority]
  var discovered: HashSet[CellIdx]
  # Initialize the round counter and the battle simulation status
  var round: int32 = 0
  var status = Uninitialized
  var count: array[Race, int8]
  # --------------------------------------------------------------------------------------
  # Main game loop
  setTargetFPS(2) # Set our game to run at 2 frames-per-second
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
          if i <= high(units):
            cells[units[i].cell].unit = UnitIdx(i)
      # Sort the units in reading order
      units.inssort()
      # Update the unit indices on the cells
      for i in 0..high(units):
        # if units[i].cell != NilCellIdx:
        cells[units[i].cell].unit = UnitIdx(i)
      # Iterate in reading order
      for i in 0..high(units):
        template unit: untyped = units[i]
        # Check if the opposing race has no units left
        if count[not unit.race] == 0:
          status = BattleSimStatus(unit.race)
          break
        elif unit.health > 0:
          var targetIdx = NilUnitIdx
          # Check if there're enemy units in range
          # and target the one with the lowest health
          var minHealth = high(int16)
          for neighborIdx in neighbors(unit.cell):
            let idx = cells[neighborIdx].unit
            if idx != NilUnitIdx:
              template target: untyped = units[idx.int]
              if target.race != unit.race and minHealth > target.health:
                minHealth = target.health
                targetIdx = idx
          if targetIdx == NilUnitIdx:
            # Clear the frontier, discovered set, and reset the path planning data
            frontier.clear()
            discovered.clear()
            planning.fill(PathPlanning(
              goal: NilCellIdx,
              g: maximumPositiveValue(float32), f: maximumPositiveValue(float32)
            ))
            # Find all enemy units and add their neighboring open positions to the frontier
            for target in units.items:
              if target.health > 0 and target.race != unit.race:
                template neighbor: untyped = planning[neighborIdx]
                for neighborIdx in neighbors(target.cell):
                  if neighbor.goal == NilCellIdx and isOpenPosition(cells, neighborIdx):
                    neighbor.goal = neighborIdx
                    neighbor.g = 0
                    neighbor.f = heuristic(cells[unit.cell].position, cells[neighborIdx].position)
                    frontier.push(neighborIdx.TilePriority)
                # Simultaneously plans backwards from all goal positions to the unit
                while frontier.len > 0:
                  let currentIdx = frontier.pop().CellIdx
                  discovered.incl(currentIdx)
                  template current: untyped = planning[currentIdx]
                  # Check the neighbors of the current position
                  for neighborIdx in neighbors(currentIdx):
                    if neighborIdx notin discovered and isOpenPosition(cells, neighborIdx):
                      let tempG = current.g + 1
                      # Is this a better path than before?
                      var newPath = false
                      if neighborIdx.TilePriority in frontier:
                        # Break ties with path length, then goal positions and then positions
                        if tempG < neighbor.g or
                            (tempG == neighbor.g and current.goal < neighbor.goal):
                          neighbor.g = tempG
                          newPath = true
                      else:
                        neighbor.g = tempG
                        newPath = true
                        frontier.push(neighborIdx.TilePriority)
                      # Yes, it's a better path
                      if newPath:
                        neighbor.f = neighbor.g + heuristic(cells[unit.cell].position, cells[neighborIdx].position)
                        neighbor.goal = current.goal
            # Find the best neighboring position to move to
            var bestGoal = NilCellIdx
            var bestG = maximumPositiveValue(float32)
            var bestNeighbor = NilCellIdx
            for neighborIdx in neighbors(unit.cell):
              template neighbor: untyped = planning[neighborIdx]
              if isOpenPosition(cells, neighborIdx) and (neighbor.g < bestG or
                  (neighbor.g == bestG and neighbor.goal < bestGoal)):
                bestGoal = neighbor.goal
                bestG = neighbor.g
                bestNeighbor = neighborIdx
            if bestNeighbor != NilCellIdx:
              # Move the unit to the best neighboring position
              cells[unit.cell].unit = NilUnitIdx
              unit.cell = bestNeighbor
              cells[unit.cell].unit = UnitIdx(i)
              # Update the target to the enemy unit with the lowest health in range
              var minHealth = high(int16)
              for neighborIdx in neighbors(unit.cell):
                let idx = cells[neighborIdx].unit
                if idx != NilUnitIdx:
                  template target: untyped = units[idx.int]
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
              cells[target.cell].unit = NilUnitIdx
              #target.cell = NilCellIdx
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
        # Iterate over each unit and draw the corresponding textures
        for unit in units.items:
          template cell: untyped = cells[unit.cell]
          let (x, y) = cell.position
          let pos = Vector2(x: x.float32*TileSize, y: y.float32*TileSize)
          # Draw the background color again to mask the background
          drawRectangle(pos, Vector2(x: TileSize, y: TileSize), BgColors[unit.cell.int])
          let (entX, entY) = Tileset[raceToTileIndex(unit.race)]
          let rec = Rectangle(x: entX.float32, y: entY.float32, width: TileSize, height: TileSize)
          drawTexture(tileset, rec, pos, fade(raceToColor(unit.race), healthToAlpha(unit.health)))
    drawing():
      clearBackground(Black)
      shaderMode(shader):
        # Draw the target texture using the shader
        let src = Rectangle(x: 0, y: 0, width: target.texture.width.float32,
            height: -target.texture.height.float32)
        drawTexture(target.texture, src, Vector2(x: 0, y: 0), White)
    # ------------------------------------------------------------------------------------

main()
