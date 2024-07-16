# ****************************************************************************************
#
#   naylib example - target 9 puzzle game
#
#   Example originally created with naylib 5.1
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, raymath, std/[strformat, math, lenientops, random]

const
  screenWidth = 800
  screenHeight = 450

  TilemapWidth = 348 # Width of the tilemap area
  TilemapOffset = Vector2(
    x: (screenWidth - TilemapWidth) div 2, # Center tilemap horizontally
    y: (screenHeight - TilemapWidth) div 2 # Center tilemap vertically
  )
  TileSpacing = 12 # Spacing between tiles
  TileCount = 3
  TileWidth = (TilemapWidth - (TileCount + 1)*TileSpacing) div TileCount

  # Color scheme
  BackgroundColor = Color(r: 0x2c, g: 0x3e, b: 0x50, a: 255) # Dark blue background
  TileNormalColor = Color(r: 0xec, g: 0xf0, b: 0xf1, a: 255) # Light gray tiles
  TileHighlightColor = Color(r: 0x34, g: 0x98, b: 0xdb, a: 255) # Blue highlight
  TileSelectedColor = Color(r: 0xe7, g: 0x4c, b: 0x3c, a: 255) # Red selected tile
  TextNormalColor = Color(r: 0x2c, g: 0x3e, b: 0x50, a: 255) # Dark blue text
  TextHighlightColor = Color(r: 0xec, g: 0xf0, b: 0xf1, a: 255) # Brighter text
  TileSelectedRingColor = Color(r: 0xf3, g: 0x9c, b: 0x12, a: 255) # Selected tile's outer ring
  WinColor = Color(r: 0x2e, g: 0xcc, b: 0x71, a: 255) # Green for win message
  LoseColor = Color(r: 0xe7, g: 0x4c, b: 0x3c, a: 255) # Red for lose message

type
  Grid = array[TileCount, array[TileCount, int]] # Type for representing the grid of tiles
  Move = object
    row, col: int32

var
  grid: Grid
  undoStack: seq[Move]
  selectedRow, selectedCol: int32 = -1
  remainingMoves: int32 # Count player moves
  gameOver = false
  initialMoves: int32 = 3

proc initGame() =
  # Initialize the game grid
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      grid[row][col] = 9
  # Randomly make initialMoves moves
  for _ in 1..initialMoves:
    let row = rand(0..<TileCount)
    let col = rand(0..<TileCount)
    # Decrement chosen tile and surrounding cells
    for i in 0..<TileCount:
      grid[i][col] = (grid[i][col] + 9) mod 10
    for j in 0..<TileCount:
      if j != col:
        grid[row][j] = (grid[row][j] + 9) mod 10
  # Reset game state
  undoStack.setLen(0)
  selectedRow = -1
  selectedCol = -1
  remainingMoves = initialMoves
  gameOver = false

proc checkWin(): bool =
  # Check if all tiles in the grid are 9 (win condition)
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      if grid[row][col] != 9:
        return false
  return true

proc pushMove(stack: var seq[Move], row, col: int32) =
  selectedRow = row
  selectedCol = col
  stack.add(Move(row: row, col: col))

proc undoMove =
  if undoStack.len > 0:
    let move = undoStack.pop()
    selectedRow = move.row
    selectedCol = move.col
    # Decrement chosen tile and surrounding cells
    for i in 0..<TileCount:
      grid[i][move.col] = (grid[i][move.col] + 9) mod 10
    for j in 0..<TileCount:
      if j != move.col:
        grid[move.row][j] = (grid[move.row][j] + 9) mod 10
    inc remainingMoves # Update move count

proc increaseRowAndColumn(row, col: int32) =
  # Increment clicked tile and surrounding cells
  for i in 0..<TileCount:
    grid[i][col] = (grid[i][col] + 1) mod 10
    if i != col:
      grid[row][i] = (grid[row][i] + 1) mod 10

proc getTileRec(row, col: int32): Rectangle =
  # Calculate the rectangle for a specific tile
  result = Rectangle(
    x: TilemapOffset.x + (col + 1)*TileSpacing + col*TileWidth,
    y: TilemapOffset.y + (row + 1)*TileSpacing + row*TileWidth,
    width: TileWidth, height: TileWidth
  )

proc handleInput() =
  const GridRec = Rectangle(
    x: TilemapOffset.x, y: TilemapOffset.y,
    width: TilemapWidth, height: TilemapWidth)
  # Handle mouse input and update game state accordingly
  if isMouseButtonPressed(Left):
    # Get mouse position
    let mousePos = getMousePosition()
    # Check if mouse is within tilemap bounds
    if not gameOver and checkCollisionPointRec(mousePos, GridRec):
      # Loop through each tile in the grid
      block outer:
        for row in 0..<TileCount:
          for col in 0..<TileCount:
            # Get the rectangle for the current tile
            let tileRec = getTileRec(row.int32, col.int32)
            # Check if mouse is within the tile rectangle
            if checkCollisionPointRec(mousePos, tileRec):
              # Save the current state before making a move
              pushMove(undoStack, row.int32, col.int32)
              increaseRowAndColumn(row.int32, col.int32)
              dec remainingMoves # Update move count
              break outer
  # Check for undo command
  if isKeyPressed(U) or isGestureDetected(SwipeRight):
    undoMove()
    gameOver = false
  elif isKeyPressed(R) or isGestureDetected(SwipeUp):
    initGame()

proc drawBoxedText(text: string, rect: Rectangle, fontSize: int32, fgColor: Color) =
  # Center text within a given rectangle
  let font = getFontDefault()
  let spacing = ceil(fontSize / 20'f32)
  let textSize = measureText(font, text, fontSize.float32, spacing)
  # Calculate centered position for text
  let pos = Vector2(
    x: rect.x + (rect.width - textSize.x) / 2,
    y: rect.y + (rect.height - textSize.y) / 2
  )
  drawText(font, text, pos, fontSize.float32, spacing, fgColor)

proc drawTilesGrid() =
  drawRectangleRounded(Rectangle(
      x: TilemapOffset.x - 10, y: TilemapOffset.y - 10,
      width: TilemapWidth + 20, height: TilemapWidth + 20
    ), 0.1, 10, BackgroundColor)
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      let tileRect = getTileRec(row.int32, col.int32)
      let isSelected = row == selectedRow and col == selectedCol
      let isHighlighted = row == selectedRow or col == selectedCol
      let tileColor = if isSelected: TileSelectedColor
                      elif isHighlighted: TileHighlightColor
                      else: TileNormalColor
      drawRectangleRounded(tileRect, 0.2, 10, tileColor)
      # Draw outer ring for selected tile
      if isSelected:
        drawRectangleRoundedLines(tileRect, 0.2, 10, 3, TileSelectedRingColor)
      let textColor = if isSelected or isHighlighted: TextHighlightColor else: TextNormalColor
      drawBoxedText($grid[row][col], tileRect, 40, textColor)

proc drawGameOverMessage() =
  const messageRect = Rectangle(
    x: 0, y: screenHeight div 2 - 30,
    width: screenWidth, height: 60)
  if checkWin():
    drawRectangle(messageRect, colorAlpha(WinColor, 0.6))
    drawBoxedText("You Win!", messageRect, 40, TileNormalColor)
  else:
    drawRectangle(messageRect, colorAlpha(LoseColor, 0.6))
    drawBoxedText("Game Over!", messageRect, 40, TileNormalColor)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main() =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  initWindow(screenWidth, screenHeight, "raylib example - target 9 puzzle")
  try:
    randomize()
    # Initialize game state
    initGame()
    setTargetFPS(60)
    # ------------------------------------------------------------------------------------
    # Main game loop
    while not windowShouldClose():
      # Update
      # ----------------------------------------------------------------------------------
      handleInput() # Handle mouse input and logic
      gameOver = remainingMoves <= 0
      # ----------------------------------------------------------------------------------
      # Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()
      clearBackground(RayWhite)
      # Draw the grid and game elements
      drawTilesGrid()
      if gameOver:
        drawGameOverMessage()
      else:
        drawText(&"Remaining moves: {remainingMoves}", 10, 10, 20, DarkGray)
      drawText("Press U to undo last move, R to start a new game.", 10, 420, 20, DarkGray)
      endDrawing()
      # ----------------------------------------------------------------------------------
    # De-Initialization
    # ------------------------------------------------------------------------------------
  finally:
    closeWindow() # Close window and OpenGL context

main()
