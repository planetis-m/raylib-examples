import raylib, std/[heapqueue, sets, hashes, math, random]

const
  Rows = 50
  Cols = 50

  CellSize = 20
  WallChance = 4

  screenWidth = Rows*CellSize
  screenHeight = Cols*CellSize

  bgColor = Color(r: 45, g: 197, b: 244, a: 255)
  wlColor = Color(r: 112, g: 50, b: 126, a: 255)

type
  SpotIdx = distinct int32

  Spot = object
    i, j: int32
    previous: SpotIdx
    wall: bool
    g, f: float32 # cost from start, and total cost

const
  FirstIdx = SpotIdx(0)
  LastIdx = SpotIdx(Rows*Cols-1)
  InvalidIdx = SpotIdx(-1)

# proc `<`(a, b: SpotIdx): bool {.borrow.}
proc `==`(a, b: SpotIdx): bool {.borrow.}
proc hash(x: SpotIdx): Hash {.borrow.}

var
  grid: array[FirstIdx..LastIdx, Spot]
  pathFound = false

proc `<`(a, b: SpotIdx): bool {.inline.} =
  grid[a].f < grid[b].f

proc isOnBoard(x, y: int32): bool {.inline.} =
  result = x >= 0 and y >= 0 and x < Rows and y < Cols

proc indexAt(x, y: int32): SpotIdx {.inline.} =
  assert isOnBoard(x, y)
  result = SpotIdx(x*Cols + y)

proc heuristic(a, b: Spot): float32 =
  # Calculate the heuristic between two spots using Euclidean distance
  sqrt(float32((a.i - b.i)*(a.i - b.i) + (a.j - b.j)*(a.j - b.j)))

iterator neighbours(spot: Spot): SpotIdx =
  # Iterator to get the neighbours of a spot
  if spot.i < Cols - 1:
    yield indexAt(spot.i + 1, spot.j)
  if spot.i > 0:
    yield indexAt(spot.i - 1, spot.j)
  if spot.j < Rows - 1:
    yield indexAt(spot.i, spot.j + 1)
  if spot.j > 0:
    yield indexAt(spot.i, spot.j - 1)
  if spot.i > 0 and spot.j > 0:
    yield indexAt(spot.i - 1, spot.j - 1)
  if spot.i < Cols - 1 and spot.j > 0:
    yield indexAt(spot.i + 1, spot.j - 1)
  if spot.i > 0 and spot.j < Rows - 1:
    yield indexAt(spot.i - 1, spot.j + 1)
  if spot.i < Cols - 1 and spot.j < Rows - 1:
    yield indexAt(spot.i + 1, spot.j + 1)

proc drawSpot(spot: Spot, col: Color) =
  drawRectangle(spot.i*CellSize, spot.j*CellSize, CellSize - 1, CellSize - 1, col)

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

  for i in FirstIdx.int32..LastIdx.int32:
    let (x, y) = divmod(i, Cols)
    grid[SpotIdx(i)] = Spot(
      i: x, j: y,
      previous: InvalidIdx,
      f: 0, g: 0,
      wall: bool(rand(10) < WallChance)
    )

  grid[FirstIdx].wall = false
  grid[LastIdx].wall = false

  var frontier: HeapQueue[SpotIdx]
  frontier.push(FirstIdx)
  var discovered: HashSet[SpotIdx]

  var current: SpotIdx
  setTargetFPS(25) # Set our game to run at 25 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if frontier.len > 0 and not pathFound:
      current = frontier.pop()
      discovered.incl(current)
      if current == LastIdx:
        pathFound = true
      else:
        for neighborIdx in neighbours(grid[current]):
          template neighbor: untyped = grid[neighborIdx]
          if indexAt(neighbor.i, neighbor.j) notin discovered and not neighbor.wall:
            let tempG = grid[current].g + heuristic(neighbor, grid[current])
            # Is this a better path than before?
            var newPath = false;
            if find(frontier, neighborIdx) >= 0:
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
              neighbor.previous = current
    elif not pathFound:
      echo "no solution"
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(bgColor)
      for i in FirstIdx.int32..LastIdx.int32:
        let spot = grid[SpotIdx(i)]
        if spot.wall:
          drawCircle(spot.i*CellSize + CellSize div 2, spot.j*CellSize + CellSize div 2,
              CellSize/4'f32, wlColor)
      for i in 0..<len(frontier):
        drawSpot(grid[frontier[i]], Color(r: 240, g: 99, b: 164, a: 255))
      for i in items(discovered):
        drawSpot(grid[i], Color(r: 236, g: 1, b: 90, a: 255))
      var temp = current
      var path: seq[Vector2] # use Vector2 type for the path
      while temp != InvalidIdx:
        path.add(Vector2(
          x: grid[temp].i.float32*CellSize + CellSize/2'f32,
          y: grid[temp].j.float32*CellSize + CellSize/2'f32)
        )
        temp = grid[temp].previous
      # draw the path as a continuous line
      drawSplineLinear(path, CellSize/2'f32, Color(r: 252, g: 238, b: 33, a: 255))
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
