import raylib, std/[heapqueue, sets, hashes, math, random, lenientops, options]

const
  Rows = 40
  Cols = 24

  CellSize = 20 # Width and height of each cell in pixels
  WallChance = 4 # Percentage of cells that are walls

const
  screenWidth = Rows*CellSize
  screenHeight = Cols*CellSize

const
  bgColor = Color(r: 45, g: 197, b: 244, a: 255) # Background
  wallColor = Color(r: 112, g: 50, b: 126, a: 255)
  nextColor = Color(r: 240, g: 99, b: 164, a: 255)
  doneColor = Color(r: 236, g: 1, b: 90, a: 255)
  pathColor = Color(r: 252, g: 238, b: 33, a: 255)

type
  SpotIdx = distinct int32 # Index type of a spot in the grid

  Spot = object
    i, j: int32
    previous: SpotIdx # Previous spot in the path
    wall: bool
    g, f: float32 # Cost from start and total cost

  PathFindingStatus = enum
    Processing,
    Successful,
    Failed,

const
  FirstIdx = SpotIdx(0) # Top-left corner
  LastIdx = SpotIdx(Rows*Cols-1) # Bottom-right corner
  InvalidIdx = SpotIdx(-1) # Invalid or nonexistent index

# proc `<`(a, b: SpotIdx): bool {.borrow.}
proc `==`(a, b: SpotIdx): bool {.borrow.}
proc hash(x: SpotIdx): Hash {.borrow.}

var grid: array[FirstIdx..LastIdx, Spot]

proc `<`(a, b: SpotIdx): bool {.inline.} =
  grid[a].f < grid[b].f

proc isOnBoard(x, y: int32): bool {.inline.} =
  result = x >= 0 and y >= 0 and x < Rows and y < Cols

proc indexAt(x, y: int32): SpotIdx {.inline.} =
  doAssert isOnBoard(x, y)
  result = SpotIdx(x*Cols + y)

proc heuristic(a, b: Spot): float32 =
  # Calculate the heuristic between two spots
  result = sqrt(float32((a.i - b.i)*(a.i - b.i) + (a.j - b.j)*(a.j - b.j)))
  # Alternatively, use the Manhattan distance as the heuristic
  #result = float32(abs(a.i - b.i) + abs(a.j - b.j))

iterator neighbours(spot: Spot): SpotIdx =
  # Iterator to get the neighbours of a spot
  # Check the four cardinal directions
  if spot.i < Rows - 1:
    yield indexAt(spot.i + 1, spot.j)
  if spot.i > 0:
    yield indexAt(spot.i - 1, spot.j)
  if spot.j < Cols - 1:
    yield indexAt(spot.i, spot.j + 1)
  if spot.j > 0:
    yield indexAt(spot.i, spot.j - 1)
  # Also check the four diagonals
  if spot.i > 0 and spot.j > 0:
    yield indexAt(spot.i - 1, spot.j - 1)
  if spot.i < Rows - 1 and spot.j > 0:
    yield indexAt(spot.i + 1, spot.j - 1)
  if spot.i > 0 and spot.j < Cols - 1:
    yield indexAt(spot.i - 1, spot.j + 1)
  if spot.i < Rows - 1 and spot.j < Cols - 1:
    yield indexAt(spot.i + 1, spot.j + 1)

proc drawSpot(spot: Spot, col: Option[Color]) =
  # Draws a cell on the board with a given color
  if spot.wall:
    drawCircle(Vector2(x: spot.i*CellSize + CellSize/2'f32, y: spot.j*CellSize + CellSize/2'f32),
        CellSize/4'f32, wallColor)
  elif col.isSome:
    drawRectangle(spot.i*CellSize + 2, spot.j*CellSize + 2, CellSize - 4, CellSize - 4, col.get())

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib example - A* path finding")
  randomize()
  # Initialize the grid
  for i in FirstIdx.int32..LastIdx.int32:
    let (x, y) = divmod(i, Cols)
    grid[SpotIdx(i)] = Spot(
      i: x, j: y,
      previous: InvalidIdx,
      f: Inf, g: Inf,
      wall: bool(rand(10) < WallChance)
    )
  # Make sure the first and last spots are not walls
  grid[FirstIdx].wall = false
  grid[LastIdx].wall = false
  # Initialize the frontier queue and the discovered set
  var frontier: HeapQueue[SpotIdx]
  frontier.push(FirstIdx)
  var discovered: HashSet[SpotIdx]
  discovered.incl(FirstIdx)

  var status = Processing
  var currentIdx = InvalidIdx
  var path: seq[Vector2] = @[] # Use Vector2 type for the path
  setTargetFPS(25) # Set our game to run at 25 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if frontier.len > 0 and status == Processing:
      # Pop the lowest f value spot from the frontier
      currentIdx = frontier.pop()
      # If it is the goal point, the path is found
      if currentIdx == LastIdx:
        status = Successful
      else:
        # Otherwise, check its neighbours
        template current: untyped = grid[currentIdx]
        for neighborIdx in neighbours(current):
          template neighbor: untyped = grid[neighborIdx]
          if neighborIdx notin discovered and not neighbor.wall:
            let tempG = current.g + heuristic(neighbor, current)
            # Is this a better path than before?
            var newPath = false;
            if neighborIdx in frontier:
              if tempG < neighbor.g:
                neighbor.g = tempG
                newPath = true
            else:
              neighbor.g = tempG
              newPath = true
              frontier.push(neighborIdx)
              discovered.incl(neighborIdx)
            # Yes, it's a better path
            if newPath:
              neighbor.f = neighbor.g + heuristic(neighbor, grid[LastIdx])
              neighbor.previous = currentIdx
      # Trace back the path from the current spot
      path.setLen(0)
      var tempIdx = currentIdx
      while tempIdx != InvalidIdx:
        template temp: untyped = grid[tempIdx]
        path.add(Vector2(
          x: temp.i*CellSize + CellSize/2'f32,
          y: temp.j*CellSize + CellSize/2'f32)
        )
        tempIdx = temp.previous
    elif status == Processing:
      status = Failed
      path.setLen(0)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(bgColor)
      # Draw the grid, frontier and discovered sets
      for i in FirstIdx.int32..LastIdx.int32:
        drawSpot(grid[SpotIdx(i)], none(Color))
      for i in 0..<len(frontier):
        drawSpot(grid[frontier[i]], some(nextColor))
      for i in items(discovered):
        drawSpot(grid[i], some(doneColor))
      # Draw the path as a continuous line
      drawSplineBasis(path, CellSize/2'f32, pathColor)
      if status == Failed:
        drawText("Pathfinding failed", 10, 10, 20, Red)
      elif status == Successful:
        drawText("Pathfinding succeeded", 10, 10, 20, Green)
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
