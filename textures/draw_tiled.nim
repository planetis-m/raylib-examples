# *******************************************************************************************
#
#   raylib [textures] example - draw texture tiled
#
#   Example complexity rating: [★★★☆] 3/4
#
#   Example originally created with raylib 3.0, last time updated with raylib 4.2
#
#   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2020-2025 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
#
# ********************************************************************************************

import raylib, std/[strformat, lenientops]

const
  OptWidth = 220       # Max width for the options container
  MarginSize = 8       # Size for the margins
  ColorSize = 16       # Size of the color select buttons
  MaxColors = 10       # Number of colors in the palette

  ScreenWidth = 800
  ScreenHeight = 450

proc drawTextureTiled(texture: Texture2D, source, dest: Rectangle, origin: Vector2, 
                      rotation, scale: float32, tint: Color)

proc main =
  # Initialization
  setConfigFlags(flags(WindowResizable)) # Make the window resizable
  initWindow(ScreenWidth, ScreenHeight, "raylib [textures] example - draw texture tiled")
  defer: closeWindow() # Close window and OpenGL context

  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let texPattern = loadTexture("resources/patterns.png")
  setTextureFilter(texPattern, Trilinear) # Makes the texture smoother when upscaled

  # Coordinates for all patterns inside the texture
  let recPattern = [
    Rectangle(x: 3, y: 3, width: 66, height: 66),
    Rectangle(x: 75, y: 3, width: 100, height: 100),
    Rectangle(x: 3, y: 75, width: 66, height: 66),
    Rectangle(x: 7, y: 156, width: 50, height: 50),
    Rectangle(x: 85, y: 106, width: 90, height: 45),
    Rectangle(x: 75, y: 154, width: 100, height: 60)
  ]

  # Setup colors
  let colors = [Black, Maroon, Orange, Blue, Purple, Beige, Lime, Red, DarkGray, SkyBlue]
  var colorRec = default array[MaxColors, Rectangle]

  # Calculate rectangle for each color
  var x: int32 = 0
  var y: int32 = 0
  for i in 0..<MaxColors:
    colorRec[i] = Rectangle(
      x: float32(2 + MarginSize + x),
      y: float32(22 + 256 + MarginSize + y),
      width: ColorSize*2'f32,
      height: ColorSize
    )

    if i == (MaxColors div 2 - 1):
      x = 0
      y += ColorSize + MarginSize
    else:
      x += ColorSize*2 + MarginSize

  var activePattern: int32 = 0
  var activeCol: int32 = 0
  var scale: float32 = 1
  var rotation: float32 = 0

  setTargetFPS(60)

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # Handle mouse
    if isMouseButtonPressed(Left):
      let mouse = getMousePosition()

      # Check which pattern was clicked and set it as the active pattern
      for i in 0..<recPattern.len:
        let patternRect = Rectangle(
          x: 2 + MarginSize + recPattern[i].x,
          y: 40 + MarginSize + recPattern[i].y,
          width: recPattern[i].width,
          height: recPattern[i].height
        )
        if checkCollisionPointRec(mouse, patternRect):
          activePattern = int32(i)
          break

      # Check to see which color was clicked and set it as the active color
      for i in 0..<MaxColors:
        if checkCollisionPointRec(mouse, colorRec[i]):
          activeCol = int32(i)
          break

    # Handle keys
    # Change scale
    if isKeyPressed(Up):
      scale += 0.25'f32
    if isKeyPressed(Down):
      scale -= 0.25'f32
    
    if scale > 10.0'f32:
      scale = 10.0'f32
    elif scale <= 0.0'f32:
      scale = 0.25'f32

    # Change rotation
    if isKeyPressed(Left):
      rotation -= 25.0'f32
    if isKeyPressed(Right):
      rotation += 25.0'f32

    # Reset
    if isKeyPressed(Space):
      rotation = 0.0'f32
      scale = 1.0'f32

    # Draw
    drawing():
      clearBackground(RayWhite)

      # Draw the tiled area
      drawTextureTiled(
        texPattern, 
        recPattern[activePattern], 
        Rectangle(
          x: OptWidth + MarginSize,
          y: MarginSize,
          width: getScreenWidth() - OptWidth - 2'f32*MarginSize,
          height: getScreenHeight() - 2'f32*MarginSize
        ),
        Vector2(x: 0, y: 0), 
        rotation, 
        scale, 
        colors[activeCol]
      )

      # Draw options
      drawRectangle(MarginSize, MarginSize, OptWidth - MarginSize, getScreenHeight() - 2*MarginSize, 
                    colorAlpha(LightGray, 0.5'f32))

      drawText("Select Pattern", 2 + MarginSize, 30 + MarginSize, 10, Black)
      drawTexture(texPattern, 2 + MarginSize, 40 + MarginSize, Black)
      drawRectangle(
        2 + MarginSize + int32(recPattern[activePattern].x),
        40 + MarginSize + int32(recPattern[activePattern].y),
        int32(recPattern[activePattern].width),
        int32(recPattern[activePattern].height),
        colorAlpha(DarkBlue, 0.3'f32)
      )

      drawText("Select Color", 2 + MarginSize, 10 + 256 + MarginSize, 10, Black)
      for i in 0..<MaxColors:
        drawRectangle(colorRec[i], colors[i])
        if activeCol == i:
          drawRectangleLines(colorRec[i], 3, colorAlpha(White, 0.5'f32))

      drawText("Scale (UP/DOWN to change)", 2 + MarginSize, 80 + 256 + MarginSize, 10, Black)
      drawText(&"{scale:.2f}x", 2 + MarginSize, 92 + 256 + MarginSize, 20, Black)

      drawText("Rotation (LEFT/RIGHT to change)", 2 + MarginSize, 122 + 256 + MarginSize, 10, Black)
      drawText(&"{rotation:.0f} degrees", 2 + MarginSize, 134 + 256 + MarginSize, 20, Black)

      drawText("Press [SPACE] to reset", 2 + MarginSize, 164 + 256 + MarginSize, 10, DarkBlue)

      # Draw FPS
      drawText(&"{getFPS()} FPS", 2 + MarginSize, 2 + MarginSize, 20, Black)

proc drawTextureTiled(texture: Texture2D, source, dest: Rectangle, origin: Vector2, 
                      rotation, scale: float32, tint: Color) =
  if (texture.id <= 0) or (scale <= 0.0'f32): 
    return # Wanna see a infinite loop?!...just delete this line!
  if (source.width == 0) or (source.height == 0): 
    return

  let tileWidth: int32 = int32(source.width*scale)
  let tileHeight: int32 = int32(source.height*scale)
  
  if (dest.width < tileWidth) and (dest.height < tileHeight):
    # Can fit only one tile
    drawTexture(
      texture, 
      Rectangle(
        x: source.x, 
        y: source.y, 
        width: (dest.width/tileWidth)*source.width, 
        height: (dest.height/tileHeight)*source.height
      ),
      Rectangle(
        x: dest.x, 
        y: dest.y, 
        width: dest.width, 
        height: dest.height
      ), 
      origin, 
      rotation, 
      tint
    )
  elif dest.width <= tileWidth:
    # Tiled vertically (one column)
    var dy: int32 = 0
    while dy + tileHeight < dest.height:
      drawTexture(
        texture, 
        Rectangle(
          x: source.x, 
          y: source.y, 
          width: (dest.width/tileWidth)*source.width, 
          height: source.height
        ), 
        Rectangle(
          x: dest.x, 
          y: dest.y + dy, 
          width: dest.width, 
          height: float32(tileHeight)
        ), 
        origin, 
        rotation, 
        tint
      )
      dy += tileHeight

    # Fit last tile
    if dy < dest.height:
      drawTexture(
        texture, 
        Rectangle(
          x: source.x, 
          y: source.y, 
          width: (dest.width/tileWidth)*source.width, 
          height: ((dest.height - dy)/tileHeight)*source.height
        ),
        Rectangle(
          x: dest.x, 
          y: dest.y + dy, 
          width: dest.width, 
          height: dest.height - dy
        ), 
        origin, 
        rotation, 
        tint
      )
  elif dest.height <= tileHeight:
    # Tiled horizontally (one row)
    var dx: int32 = 0
    while dx + tileWidth < dest.width:
      drawTexture(
        texture, 
        Rectangle(
          x: source.x, 
          y: source.y, 
          width: source.width, 
          height: (dest.height/tileHeight)*source.height
        ), 
        Rectangle(
          x: dest.x + dx, 
          y: dest.y, 
          width: float32(tileWidth), 
          height: dest.height
        ), 
        origin, 
        rotation, 
        tint
      )
      dx += tileWidth

    # Fit last tile
    if dx < dest.width:
      drawTexture(
        texture, 
        Rectangle(
          x: source.x, 
          y: source.y, 
          width: ((dest.width - dx)/tileWidth)*source.width, 
          height: (dest.height/tileHeight)*source.height
        ),
        Rectangle(
          x: dest.x + dx, 
          y: dest.y, 
          width: dest.width - dx, 
          height: dest.height
        ), 
        origin, 
        rotation, 
        tint
      )
  else:
    # Tiled both horizontally and vertically (rows and columns)
    var dx: int32 = 0
    while dx + tileWidth < dest.width:
      var dy: int32 = 0
      while dy + tileHeight < dest.height:
        drawTexture(
          texture, 
          source, 
          Rectangle(
            x: dest.x + dx, 
            y: dest.y + dy, 
            width: float32(tileWidth), 
            height: float32(tileHeight)
          ), 
          origin, 
          rotation, 
          tint
        )
        dy += tileHeight

      if dy < dest.height:
        drawTexture(
          texture, 
          Rectangle(
            x: source.x, 
            y: source.y, 
            width: source.width, 
            height: ((dest.height - dy)/tileHeight)*source.height
          ),
          Rectangle(
            x: dest.x + dx, 
            y: dest.y + dy, 
            width: float32(tileWidth), 
            height: dest.height - dy
          ), 
          origin, 
          rotation, 
          tint
        )
      dx += tileWidth

    # Fit last column of tiles
    if dx < dest.width:
      var dy: int32 = 0
      while dy + tileHeight < dest.height:
        drawTexture(
          texture, 
          Rectangle(
            x: source.x, 
            y: source.y, 
            width: ((dest.width - dx)/tileWidth)*source.width, 
            height: source.height
          ),
          Rectangle(
            x: dest.x + dx, 
            y: dest.y + dy, 
            width: dest.width - dx, 
            height: float32(tileHeight)
          ), 
          origin, 
          rotation, 
          tint
        )
        dy += tileHeight

      # Draw final tile in the bottom right corner
      if dy < dest.height:
        drawTexture(
          texture, 
          Rectangle(
            x: source.x, 
            y: source.y, 
            width: ((dest.width - dx)/tileWidth)*source.width, 
            height: ((dest.height - dy)/tileHeight)*source.height
          ),
          Rectangle(
            x: dest.x + dx, 
            y: dest.y + dy, 
            width: dest.width - dx, 
            height: dest.height - dy
          ), 
          origin, 
          rotation, 
          tint
        )

main()
