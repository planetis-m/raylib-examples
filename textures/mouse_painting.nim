# ****************************************************************************************
#
#   raylib [textures] example - Mouse painting
#
#   Example originally created with raylib 3.0, last time updated with raylib 3.0
#
#   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2019-2022 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  MaxColorsCount = 23
  # Colors to choose from
  colors: array[MaxColorsCount, Color] = [
    RayWhite, Yellow, Gold, Orange, Pink, Red,
    Maroon, Green, Lime, DarkGreen, SkyBlue, Blue,
    DarkBlue, Purple, Violet, DarkPurple, Beige, Brown,
    DarkBrown, LightGray, Gray, DarkGray, Black
  ]

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - mouse painting")
  defer: closeWindow() # Close window and OpenGL context
  # Define colorsRecs data (for every rectangle)
  var colorsRecs: array[MaxColorsCount, Rectangle]
  for i in 0..<MaxColorsCount:
    colorsRecs[i] = Rectangle(x: 10 + 30*i.float32 + 2*i.float32, y: 10, width: 30, height: 30)
  var colorSelected: int32 = 0
  var colorSelectedPrev: int32 = colorSelected
  var colorMouseHover: int32 = 0
  var brushSize: float32 = 20
  var mouseWasPressed = false
  var btnSaveRec = Rectangle(x: 750, y: 10, width: 40, height: 30)
  var btnSaveMouseHover = false
  var showSaveMessage = false
  var saveMessageCounter: int32 = 0
  # Create a RenderTexture2D to use as a canvas
  let target = loadRenderTexture(screenWidth, screenHeight)
  # Clear render texture before entering the game loop
  beginTextureMode(target)
  clearBackground(colors[0])
  endTextureMode()
  setTargetFPS(120) # Set our game to run at 120 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    let mousePos = getMousePosition()
    # Move between colors with keys
    if isKeyPressed(Right):
      inc(colorSelected)
    elif isKeyPressed(Left):
      dec(colorSelected)
    if colorSelected >= MaxColorsCount:
      colorSelected = MaxColorsCount - 1
    elif colorSelected < 0: # Choose color with mouse
      colorSelected = 0
    for i in 0..<MaxColorsCount:
      if checkCollisionPointRec(mousePos, colorsRecs[i]):
        colorMouseHover = i.int32
        break
      else:
        colorMouseHover = -1
    if colorMouseHover >= 0 and isMouseButtonPressed(Left):
      colorSelected = colorMouseHover
      colorSelectedPrev = colorSelected
    brushSize += getMouseWheelMove()*5
    if brushSize < 2:
      brushSize = 2
    if brushSize > 50:
      brushSize = 50
    if isKeyPressed(C):
      # Clear render texture to clear color
      beginTextureMode(target)
      clearBackground(colors[0])
      endTextureMode()
    if isMouseButtonDown(Left) or getGestureDetected() == Drag:
      # Paint circle into render texture
      # NOTE: To avoid discontinuous circles, we could store
      # previous-next mouse points and just draw a line using brush size
      beginTextureMode(target)
      if mousePos.y > 50:
        drawCircle(mousePos.x.int32, mousePos.y.int32, brushSize, colors[colorSelected])
      endTextureMode()
    if isMouseButtonDown(Right):
      if not mouseWasPressed:
        colorSelectedPrev = colorSelected
        colorSelected = 0
      mouseWasPressed = true
      # Erase circle from render texture
      beginTextureMode(target)
      if mousePos.y > 50:
        drawCircle(mousePos.x.int32, mousePos.y.int32, brushSize, colors[0])
      endTextureMode()
    elif isMouseButtonReleased(Right) and mouseWasPressed: # Check mouse hover save button
      colorSelected = colorSelectedPrev
      mouseWasPressed = false
    if checkCollisionPointRec(mousePos, btnSaveRec):
      btnSaveMouseHover = true
    else:
      btnSaveMouseHover = false
    # Image saving logic
    # NOTE: Saving painted texture to a default named image
    if btnSaveMouseHover and isMouseButtonReleased(Left) or isKeyPressed(S):
      var image = loadImageFromTexture(target.texture)
      imageFlipVertical(image)
      discard exportImage(image, "my_amazing_texture_painting.png")
      showSaveMessage = true
    if showSaveMessage:
      # On saving, show a full screen message for 2 seconds
      inc(saveMessageCounter)
      if saveMessageCounter > 240:
        showSaveMessage = false
        saveMessageCounter = 0
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    # NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
    drawTexture(target.texture, Rectangle(x: 0, y: 0,
        width: target.texture.width.float32, height: -target.texture.height.float32), Vector2(x: 0, y: 0), White)
    # Draw drawing circle for reference
    if mousePos.y > 50:
      if isMouseButtonDown(Right):
        drawCircleLines(mousePos.x.int32, mousePos.y.int32, brushSize, Gray)
      else:
        drawCircle(getMouseX(), getMouseY(), brushSize, colors[colorSelected])
    drawRectangle(0, 0, getScreenWidth(), 50, RayWhite)
    drawLine(0, 50, getScreenWidth(), 50, LightGray)
    # Draw color selection rectangles
    for i in 0..<MaxColorsCount:
      drawRectangle(colorsRecs[i], colors[i])
    drawRectangleLines(10, 10, 30, 30, LightGray)
    if colorMouseHover >= 0:
      drawRectangle(colorsRecs[colorMouseHover], fade(White, 0.6))
    drawRectangleLines(
        Rectangle(
          x: colorsRecs[colorSelected].x - 2,
          y: colorsRecs[colorSelected].y - 2,
          width: colorsRecs[colorSelected].width + 4,
          height: colorsRecs[colorSelected].height + 4
        ), 2, Black)
    # Draw save image button
    drawRectangleLines(btnSaveRec, 2, if btnSaveMouseHover: Red else: Black)
    drawText("SAVE!", 755, 20, 10, if btnSaveMouseHover: Red else: Black)
    # Draw save image message
    if showSaveMessage:
      drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), fade(RayWhite, 0.8))
      drawRectangle(0, 150, getScreenWidth(), 80, Black)
      drawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20, RayWhite)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
