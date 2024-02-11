# ****************************************************************************************
#
#   raylib example - 8 queens puzzle
#
#   Example originally created with naylib 1.8
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2022 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, reasings, std/strformat

const
  screenSize = 600
  N = 8
  SquareSize = 75
  AnimationFrames = 20

type
  QueensArr = array[N, int32]
  Queens = object
    queenInRow: QueensArr # column number of queen in each row
    colFree: array[N, bool]
    upwardFree: array[N*2 - 1, bool]
    downwardFree: array[N*2 - 1, bool]

proc initQueens(): Queens =
  # The Queens object is set up as an empty configuration on a chessboard with N
  # cells in each row and column.
  result = Queens()
  for i in 0..<N:
    result.queenInRow[i] = -1
    result.colFree[i] = true
  for i in 0..<N*2 - 1:
    result.upwardFree[i] = true
    result.downwardFree[i] = true

proc placeQueen(x: var Queens; row, col: int) =
  # Insert a queen in the next row, in the given column.
  x.queenInRow[row] = col.int32
  x.colFree[col] = false
  x.upwardFree[row + col] = false
  x.downwardFree[row - col + N - 1] = false

proc removeQueen(x: var Queens; row, col: int) =
  # Remove the queen in the last row.
  x.colFree[col] = true
  x.upwardFree[row + col] = true
  x.downwardFree[row - col + N - 1] = true

proc isSafe(x: Queens; row, col: int): bool =
  # Return true if it is possible to place a queen in the given column on the next row.
  result = x.colFree[col] and x.upwardFree[row + col] and x.downwardFree[row - col + N - 1]

proc solve(x: var Queens; row: int; solutions: var seq[QueensArr]) =
  # Return true if a solution is found.
  if row >= N:
    solutions.add x.queenInRow
  else:
    for col in 0..<N:
      if x.isSafe(row, col):
        x.placeQueen(row, col)
        x.solve(row + 1, solutions)
        x.removeQueen(row, col)

proc animateQueenPlacement(queenPiece: Texture, row, oldCol, newCol, count: int32) =
  # Animation for placing a queen
  if count <= AnimationFrames:
    let x = expoInOut(count.float32, oldCol.float32*SquareSize,
        float32(newCol - oldCol)*SquareSize, AnimationFrames)
    drawTexture(queenPiece, x.int32, row*SquareSize, White)
  else:
    drawTexture(queenPiece, newCol*SquareSize, row*SquareSize, White)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenSize, screenSize, "raylib example - 8 queens puzzle")
  let queenPiece = loadTexture("resources/wQ.png")
  var queens = initQueens()
  var solutions: seq[QueensArr] = @[]
  queens.solve(0, solutions)
  setTargetFPS(60)
  # --------------------------------------------------------------------------------------
  # Main game loop
  var index = 0
  var framesCounter: int32 = 0
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(Enter):
      inc index
      if index >= solutions.len: index = 0
      framesCounter = 0
    if framesCounter <= AnimationFrames:
      inc framesCounter
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    # Draw the chess board
    for row in 0..<N:
      for col in 0..<N:
        drawRectangle(col.int32*SquareSize, row.int32*SquareSize, SquareSize, SquareSize,
            if (row + col) mod 2 == 0: getColor(0xf0d9b5ff'u32) else: getColor(0xb58863ff'u32))
    # Draw the queens with animation
    for row in 0..<N:
      # Get previous queen position
      let oldCol = solutions[if index > 0: index - 1 else: solutions.high][row]
      let newCol = solutions[index][row]
      animateQueenPlacement(queenPiece, row.int32, oldCol, newCol, framesCounter)
    drawText(&"Solution {index+1}", 420, 10, 30, Black)
    drawText("Press ENTER to continue", 15, 570, 20, Black)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
