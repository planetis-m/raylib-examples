# ****************************************************************************************
#
#   raylib [textures] example - Image processing
#
#   NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#   Example originally created with raylib 1.4, last time updated with raylib 3.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2016-2022 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  NumProcesses = 9

type
  ImageProcess = enum
    None = 0,
    ColorGrayscale,
    ColorTint,
    ColorInvert,
    ColorContrast,
    ColorBrightness,
    GaussianBlur,
    FlipVertical,
    FlipHorizontal

const
  processText = [
    "NO PROCESSING",
    "COLOR GRAYSCALE",
    "COLOR TINT",
    "COLOR INVERT",
    "COLOR CONTRAST",
    "COLOR BRIGHTNESS",
    "GAUSSIAN BLUR",
    "FLIP VERTICAL",
    "FLIP HORIZONTAL"
  ]

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - image processing")
  defer: closeWindow() # Close window and OpenGL context

  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  var imOrigin = loadImage("resources/parrots.png") # Loaded in CPU memory (RAM)
  imageFormat(imOrigin, UncompressedR8g8b8a8) # Format image to RGBA 32bit (required for texture update) <-- ISSUE
  var texture = loadTextureFromImage(imOrigin) # Image converted to texture, GPU memory (VRAM)
  var imCopy: Image = imOrigin
  var currentProcess: ImageProcess = None
  var textureReload = false
  var toggleRecs: array[NumProcesses, Rectangle]
  var mouseHoverRec = -1
  for i in 0..<NumProcesses:
    toggleRecs[i] = Rectangle(x: 40, y: float32(50 + 32*i), width: 150, height: 30)

  setTargetFPS(60)
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Mouse toggle group logic
    for i in 0..<NumProcesses:
      if checkCollisionPointRec(getMousePosition(), toggleRecs[i]):
        mouseHoverRec = i
        if isMouseButtonReleased(Left):
          currentProcess = ImageProcess(i)
          textureReload = true
        break
      else:
        mouseHoverRec = -1
    # Keyboard toggle group logic
    if isKeyPressed(Down):
      if currentProcess == high(ImageProcess): currentProcess = low(ImageProcess)
      else: inc(currentProcess)
      textureReload = true
    elif isKeyPressed(Up):
      if currentProcess == low(ImageProcess): currentProcess = high(ImageProcess)
      else: dec(currentProcess)
      textureReload = true
    # Reload texture when required
    if textureReload:
      imCopy = imOrigin # Restore image-copy from image-origin
      # NOTE: Image processing is a costly CPU process to be done every frame,
      # If image processing is required in a frame-basis, it should be done
      # with a texture and by shaders
      case currentProcess
      of ColorGrayscale:
        imageColorGrayscale(imCopy)
      of ColorTint:
        imageColorTint(imCopy, Green)
      of ColorInvert:
        imageColorInvert(imCopy)
      of ColorContrast:
        imageColorContrast(imCopy, -40)
      of ColorBrightness:
        imageColorBrightness(imCopy, -80)
      of GaussianBlur:
        imageBlurGaussian(imCopy, 10)
      of FlipVertical:
        imageFlipVertical(imCopy)
      of FlipHorizontal:
        imageFlipHorizontal(imCopy)
      else:
        discard
      let pixels: Array[Color] = loadImageColors(imCopy) # Load pixel data from image (RGBA 32bit)
      updateTexture(texture, pixels.toOpenArray) # Update texture with new image data
      textureReload = false
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("IMAGE PROCESSING:", 40, 30, 10, DarkGray)
    # Draw rectangles
    for i in 0..<NumProcesses:
      drawRectangle(toggleRecs[i],
          if i == currentProcess.ord or i == mouseHoverRec: SkyBlue else: LightGray)
      drawRectangleLines(toggleRecs[i].x.int32, toggleRecs[i].y.int32,
          toggleRecs[i].width.int32, toggleRecs[i].height.int32,
          if i == currentProcess.ord or i == mouseHoverRec: Blue else: Gray)
      drawText(processText[i], int32(toggleRecs[i].x + toggleRecs[i].width/2 - measureText(processText[i], 10)/2),
          toggleRecs[i].y.int32 + 11, 10,
          if i == currentProcess.ord or i == mouseHoverRec: DarkBlue else: DarkGray)
    drawTexture(texture, screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2, White)
    drawRectangleLines(screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2,
        texture.width, texture.height, Black)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
