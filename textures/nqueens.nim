# ****************************************************************************************
#
#   raylib example - 8 queens puzzle
#
#   Example originally created with naylib 1.8
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2022 Antonis Geralis (@planetis)
#
# ****************************************************************************************

import raylib, std/strformat

const
  screenSize = 600

  N = 8
  SquareSize = 75

type
  QueensArr = array[N, int32]

  Queens = object
    count: int32
    queenInRow: QueensArr # column number of queen in each row
    colFree: array[N, bool]
    upwardFree: array[N*2-1, bool]
    downwardFree: array[N*2-1, bool]

proc initQueens(): Queens =
  # The Queens object is set up as an empty configuration on a chessboard with N
  # cells in each row and column.
  result.count = 0
  for i in 0..<N:
    result.queenInRow[i] = -1
    result.colFree[i] = true
  for i in 0..<N*2-1:
    result.upwardFree[i] = true
    result.downwardFree[i] = true

proc placeQueen(x: var Queens, col: int) =
  # Insert a queen in the next row, in the given column.
  x.queenInRow[x.count] = col.int32
  x.colFree[col] = false
  x.upwardFree[x.count + col] = false
  x.downwardFree[x.count - col + N - 1] = false
  inc x.count

proc removeQueen(x: var Queens; col: int) =
  # Remove the queen in the last row.
  dec x.count
  x.colFree[col] = true
  x.upwardFree[x.count + col] = true
  x.downwardFree[x.count - col + N - 1] = true

proc isSafe(x: Queens; col: int): bool =
  # Return true if it is possible to place a queen in the given column on the next row.
  result = x.colFree[col] and x.upwardFree[x.count + col] and x.downwardFree[x.count - col + N - 1]

proc solve(x: var Queens; solutions: var seq[QueensArr]) =
  # Return true if a solution is found.
  if x.count >= N:
    solutions.add x.queenInRow
  else:
    for col in 0..<N:
      if x.isSafe(col):
        x.placeQueen(col)
        x.solve(solutions)
        x.removeQueen(col)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenSize, screenSize, "raylib example - 8 queens puzzle")
  defer: closeWindow() # Close window and OpenGL context
  let queenPiece = loadTexture("resources/wQ.png")
  var queens = initQueens()
  var solutions: seq[QueensArr] = @[]
  queens.solve(solutions)
  # --------------------------------------------------------------------------------------
  # Main game loop
  setTargetFPS(60)
  var index = 0
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(KeyEnter):
      inc index
      if index >= solutions.len: index = 0
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    # Draw the chess board
    for row in 0..<N:
      for col in 0..<N:
        drawRectangle(col.int32*SquareSize, row.int32*SquareSize, SquareSize, SquareSize,
            if (row + col) mod 2 == 0: getColor(0xf0d9b5ff'u32) else: getColor(0xb58863ff'u32))
    # Draw the queen
    for row in 0..<N:
      let col = solutions[index][row]
      drawTexture(queenPiece, col.int32*SquareSize, row.int32*SquareSize, White)
    drawText(&"Solution {index+1}", 420, 10, 30, Black)
    drawText("Press ENTER to continue", 15, 570, 20, Black)
    endDrawing()

main()
