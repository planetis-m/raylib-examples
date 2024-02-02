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

type
  Grid = array[TileCount, array[TileCount, int]] # Type for representing the grid of tiles

var
  grid: Grid
  selectedRow, selectedCol: int32 = -1
  moves: int32 = 0 # Count player moves
  gameOver = false

proc initGame() =
  # Initialize the game grid
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      grid[row][col] = 9
  # Randomly make 3 moves
  for _ in 1..3:
    let row = rand(0..<TileCount)
    let col = rand(0..<TileCount)
    # Decrement chosen tile and surrounding cells
    for i in 0..<TileCount:
      grid[i][col] = (grid[i][col] + 9) mod 10
    for j in 0..<TileCount:
      if j != col:
        grid[row][j] = (grid[row][j] + 9) mod 10

proc checkWin(): bool =
  # Check if all tiles in the grid are 9 (win condition)
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      if grid[row][col] != 9:
        return false
  return true

proc handleInput() =
  # Handle mouse input and update game state accordingly
  if isMouseButtonPressed(Left) and not gameOver:
    # Get mouse position relative to tilemap area
    let mousePos = getMousePosition() - TilemapOffset
    # Check if mouse is within tilemap bounds
    if mousePos.x >= 0 and mousePos.x < TilemapWidth and
        mousePos.y >= 0 and mousePos.y < TilemapWidth:
      # Calculate row and column of clicked tile
      selectedRow = int32(mousePos.y / (TileWidth + TileSpacing))
      selectedCol = int32(mousePos.x / (TileWidth + TileSpacing))
      # Ensure clicked tile is within grid bounds
      if selectedRow >= 0 and selectedRow < TileCount and
          selectedCol >= 0 and selectedCol < TileCount:
        # Increment clicked tile and surrounding cells
        for i in 0..<TileCount:
          grid[i][selectedCol] = (grid[i][selectedCol] + 1) mod 10
          if i != selectedCol:
            grid[selectedRow][i] = (grid[selectedRow][i] + 1) mod 10
        inc moves # Update move count

proc drawBoxedText(text: string, rect: Rectangle, fontSize: int32, fgcolor: Color) =
  # Center text within a given rectangle
  let font = getFontDefault()
  let spacing = ceil(fontSize / 20'f32)
  let textSize = measureText(font, text, fontSize.float32, spacing)
  # Calculate centered position for text
  let pos = Vector2(
    x: rect.x + (rect.width - textSize.x) / 2,
    y: rect.y + (rect.height - textSize.y) / 2)
  drawText(font, text, pos, fontSize.float32, spacing, fgcolor)

proc getTileRec(row, col: int32): Rectangle =
  # Calculate the rectangle for a specific tile
  result = Rectangle(
    x: TilemapOffset.x + (col + 1) * TileSpacing + col * TileWidth,
    y: TilemapOffset.y + (row + 1) * TileSpacing + row * TileWidth,
    width: TileWidth, height: TileWidth
  )

proc drawTilesGrid() =
  # Draw the grid of tiles and game elements
  drawRectangle(TilemapOffset.x.int32, TilemapOffset.y.int32, TilemapWidth, TilemapWidth, DarkBrown)
  for row in 0..<TileCount:
    for col in 0..<TileCount:
      # Apply different colors based on tile selection state
      let tileColor = if row == selectedRow and col == selectedCol: fade(Brown, 0.4)
                      elif row == selectedRow or col == selectedCol: fade(Brown, 0.2)
                      else: fade(Brown, 0.1)

      drawRectangle(getTileRec(row.int32, col.int32), tileColor)
      # Draw text in each cell
      drawBoxedText($grid[row][col], getTileRec(row.int32, col.int32), 40, LightGray)

proc main() =
  # Initialize graphics and window
  initWindow(screenWidth, screenHeight, "Target 9")
  setTargetFPS(60)
  # Initialize game state
  randomize()
  initGame()
  while not windowShouldClose():
    # Handle mouse input and logic
    handleInput()
    # Check for win condition
    if checkWin():
      gameOver = true

    beginDrawing()
    clearBackground(RayWhite)
    # Draw the grid and game elements
    drawTilesGrid()

    if gameOver:
      drawText("You Win!", getScreenWidth() div 2 - 80, getScreenHeight() div 2 - 20, 40, Green)
    else:
      drawText(&"Moves: {moves}", 5, 5, 20, Black)

    endDrawing()

  closeWindow()

main()
