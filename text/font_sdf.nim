# ***************************************************************************************
#
# raylib [text] example - TTF loading and usage
#
# This example has been created using raylib 1.3.0 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, std/[strformat, lenientops]

when defined(GraphicsApiOpenGl33):
  const
    glslVersion = 330
else:
  const
    glslVersion = 100

const
  screenWidth = 800
  screenHeight = 450

  Message = "Signed Distance Fields"

template toBytes(x: string): untyped =
  toOpenArrayByte(x, 0, x.high)

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [text] example - SDF fonts")
  defer: closeWindow() # Close window and OpenGL context
  # NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
  # Loading file to memory
  let fileData = readFile("resources/anonymous_pro_bold.ttf")
  # Default font generation from TTF font
  # Loading font data from memory data
  # Parameters > font size: 16, no glyphs array provided (0), glyphs count: 95 (autogenerate chars array)
  let glyphsDefault = loadFontData(fileData.toBytes, 16, 95, FontDefault)
  # Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 4 px, pack method: 0 (default)
  let fontDefault = loadFontFromData(glyphsDefault, 16, 4, 0)
  # SDF font generation from TTF font
  # Parameters > font size: 16, no glyphs array provided (0), glyphs count: 0 (defaults to 95)
  let glyphsSdf = loadFontData(fileData.toBytes, 16, 0, FontSdf)
  # Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 0 px, pack method: 1 (Skyline algorythm)
  let fontSdf = loadFontFromData(glyphsSdf, 16, 0, 1)
  # Load SDF required shader (we use default vertex shader)
  var shader = loadShader("", &"resources/shaders/glsl{glslVersion}/sdf.fs")
  setTextureFilter(fontSdf.texture, TextureFilterBilinear) # Required for SDF font
  var fontPosition = Vector2(x: 40, y: screenHeight/2'f32 - 50)
  var textSize = Vector2(x: 0, y: 0)
  var fontSize: float32 = 16
  var currentFont = 0 # 0 - fontDefault, 1 - fontSdf
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    fontSize += getMouseWheelMove()*8
    if fontSize < 6:
      fontSize = 6
    if isKeyDown(KeySpace):
      currentFont = 1
    else:
      currentFont = 0
    if currentFont == 0:
      textSize = measureText(fontDefault, Message, fontSize, 0)
    else:
      textSize = measureText(fontSdf, Message, fontSize, 0)
    fontPosition.x = getScreenWidth()/2'f32 - textSize.x/2'f32
    fontPosition.y = getScreenHeight()/2'f32 - textSize.y/2'f32 + 80
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    if currentFont == 1:
      # NOTE: SDF fonts require a custom SDf shader to compute fragment color
      beginShaderMode(shader) # Activate SDF font shader
      drawText(fontSdf, Message, fontPosition, fontSize, 0, Black)
      endShaderMode() # Activate our default shader for next drawings
      drawTexture(fontSdf.texture, 10, 10, Black)
    else:
      drawText(fontDefault, Message, fontPosition, fontSize, 0, Black)
      drawTexture(fontDefault.texture, 10, 10, Black)
    if currentFont == 1:
      drawText("SDF!", 320, 20, 80, Red)
    else:
      drawText("default font", 315, 40, 30, Gray)
    drawText("FONT SIZE: 16.0", getScreenWidth() - 240, 20, 20, DarkGray)
    drawText(&"RENDER SIZE: {fontSize}:02f", getScreenWidth() - 240, 50, 20, DarkGray)
    drawText("Use MOUSE WHEEL to SCALE TEXT!", getScreenWidth() - 240, 90, 10, DarkGray)
    drawText("HOLD SPACE to USE SDF FONT VERSION!", 340, getScreenHeight() - 30, 20, Maroon)
    endDrawing()

main()
