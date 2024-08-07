# ****************************************************************************************
#
#   raylib example - IDA* path finding
#
#   Example originally created with naylib 5.2
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, std/[heapqueue, sets, hashes, math, random, lenientops, options, fenv]

const
  Rows = 40
  Cols = 24

  CellSize = 20 # Width and height of each cell in pixels
  WallChance = 4 # Percentage of cells that are walls

const
  screenWidth = Rows*CellSize
  screenHeight = Cols*CellSize

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
    Incomplete,

const
  FirstIdx = SpotIdx(0) # Top-left corner
  LastIdx = SpotIdx(Rows*Cols-1) # Bottom-right corner
  InvalidIdx = SpotIdx(-1) # Invalid or nonexistent index

proc `==`(a, b: SpotIdx): bool {.borrow.}
proc hash(x: SpotIdx): Hash {.borrow.}

var grid: array[FirstIdx..LastIdx, Spot]

proc `<`(a, b: SpotIdx): bool {.inline.} =
  # Used to maintain the heap property
  grid[a].f < grid[b].f

proc isOnBoard(x, y: int32): bool {.inline.} =
  result = x >= 0 and y >= 0 and x < Rows and y < Cols

proc indexAt(x, y: int32): SpotIdx {.inline.} =
  result = SpotIdx(x*Cols + y)

proc heuristic(a, b: Spot): float32 =
  # Calculate the heuristic between two cells with the Manhattan distance
  result = float32(abs(a.i - b.i) + abs(a.j - b.j))

iterator neighbors(spot: Spot): SpotIdx =
  # Iterator to get the valid neighbors of a cell
  const
    offsets = [ # Stores all eight directions (cardinal and diagonal)
      (-1'i32, 0'i32), # Up
      (1, 0),   # Down
      (0, -1),  # Left
      (0, 1),   # Right
      (-1, 1),  # UpRight
      (1, -1),  # DownLeft
      (-1, -1), # UpLeft
      (1, 1),   # DownRight
    ]
  # shuffle(offsets) # Randomize the order of directions
  for (dx, dy) in offsets.items:
    let newX = spot.i + dx
    let newY = spot.j + dy
    # If neighbor is within grid boundaries
    if isOnBoard(newX, newY):
      yield indexAt(newX, newY) # Yield the neighbor's index

proc drawSpot(spot: Spot, col: Option[Color]) =
  # Draws a cell on the board with a given color
  if spot.wall:
    drawCircle(Vector2(x: spot.i*CellSize + CellSize/2'f32, y: spot.j*CellSize + CellSize/2'f32),
        CellSize/4'f32, Violet)
  elif col.isSome():
    drawRectangleRounded(Rectangle(x: spot.i*CellSize + 2'f32, y: spot.j*CellSize + 2'f32,
        width: CellSize - 4, height: CellSize - 4), 0.4, 0, col.get())

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib example - IDA* path finding")
  randomize()
  # If reached fail the search to prevent memory problems
  const MemoryLimit = 420
  # Initialize the grid with random walls
  for i in FirstIdx.int32..LastIdx.int32:
    let (x, y) = divmod(i, Cols)
    grid[SpotIdx(i)] = Spot(
      i: x, j: y,
      previous: InvalidIdx,
      f: maximumPositiveValue(float32), g: maximumPositiveValue(float32),
      wall: bool(rand(10'i32) < WallChance)
    )
  # Set the starting spot's g and f values
  grid[FirstIdx].g = 0
  grid[FirstIdx].f = grid[FirstIdx].g + heuristic(grid[FirstIdx], grid[LastIdx])
  # Make sure the first and last cells are not walls
  grid[FirstIdx].wall = false
  grid[LastIdx].wall = false
  # Initialize the frontier queue and the discovered set
  var frontier: HeapQueue[SpotIdx]
  frontier.push(FirstIdx)
  var discovered: HashSet[SpotIdx]

  var status = Processing
  var currentIdx = InvalidIdx # Index of the current node being explored
  var path: seq[Vector2] = @[] # Use Vector2 type for the path
  var threshold = grid[FirstIdx].f # Initial threshold
  setTargetFPS(25) # Set our game to run at 25 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if status == Processing and frontier.len > 0:
      # Pop the lowest f value spot from the frontier
      currentIdx = frontier.pop()
      discovered.incl(currentIdx)
      template current: untyped = grid[currentIdx]
      # Found the goal!
      if currentIdx == LastIdx:
        status = Successful
      # Threshold exceeded, try higher threshold
      elif current.f > threshold:
        # Update threshold to the current f, representing the minimum in the frontier queue,
        # allowing higher-cost paths to be explored in the next IDA* iteration
        threshold = current.f
        status = Incomplete
      else:
        # Otherwise, check its neighbors
        for neighborIdx in neighbors(current):
          template neighbor: untyped = grid[neighborIdx]
          if not neighbor.wall and neighborIdx notin discovered:
            let tempG = current.g + heuristic(neighbor, current)
            # Is this a better path than before?
            var newPath = false
            if neighborIdx in frontier:
              if tempG < neighbor.g:
                neighbor.g = tempG
                newPath = true
            else:
              neighbor.g = tempG
              newPath = true
              frontier.push(neighborIdx)
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
    # No more spots to explore
    elif status == Processing:
      status = Failed
      path.setLen(0)
    if status == Incomplete:
      # Check the memory limit
      if frontier.len + discovered.len <= MemoryLimit:
        # Reset search
        status = Processing
        frontier.clear()
        frontier.push(FirstIdx)
        discovered.clear()
      else:
        status = Failed
        path.setLen(0)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(SkyBlue)
      # Draw the grid, frontier and discovered sets
      for i in FirstIdx.int32..LastIdx.int32:
        drawSpot(grid[SpotIdx(i)], none(Color))
      for i in items(frontier):
        drawSpot(grid[i], some(Pink))
      for i in items(discovered):
        drawSpot(grid[i], some(Red))
      # Draw the path as a continuous line
      drawSplineBasis(path, CellSize/2'f32, Yellow)
      if status == Failed:
        drawText("Pathfinding failed", 10, 10, 20, DarkGray)
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
