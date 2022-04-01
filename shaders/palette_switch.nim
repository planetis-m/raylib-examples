# ***************************************************************************************
#
# raylib [shaders] example - Color palette switch
#
# NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#       OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
# NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
#       on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
#       raylib comes with shaders ready for both versions, check raylib/shaders install folder
#
# This example has been created using raylib 2.3 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Marco Lizza (@MarcoLizza) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2019 Marco Lizza (@MarcoLizza) and Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, std/strformat

when defined(PlatformDesktop):
  const
    glslVersion = 330
else:
  const
    glslVersion = 100 # PlatformRpi, PlatformAndroid, PlatformWeb

const
  screenWidth = 800
  screenHeight = 450

  MaxPalettes = 3
  ColorsPerPalette = 8
  ValuesPerColor = 3

  palettes: array[MaxPalettes, array[ColorsPerPalette, array[ValuesPerColor, int32]]] = [
    [[0'i32, 0, 0],
     [255'i32, 0, 0],
     [0'i32, 255, 0],
     [0'i32, 0, 255],
     [0'i32, 255, 255],
     [255'i32, 0, 255],
     [255'i32, 255, 0],
     [255'i32, 255, 255]], # 3-BIT RGB
    [[4'i32, 12, 6],
     [17'i32, 35, 24],
     [30'i32, 58, 41],
     [48'i32, 93, 66],
     [77'i32, 128, 97],
     [137'i32, 162, 87],
     [190'i32, 220, 127],
     [238'i32, 255, 204]], # AMMO-8 (GameBoy-like)
    [[21'i32, 25, 26],
     [138'i32, 76, 88],
     [217'i32, 98, 117],
     [230'i32, 184, 193],
     [69'i32, 107, 115],
     [75'i32, 151, 166],
     [165'i32, 189, 194],
     [255'i32, 245, 247]] # RKBV (2-strip film)
  ]

  paletteText = [
    "3-BIT RGB",
    "AMMO-8 (GameBoy-like)",
    "RKBV (2-strip film)"
  ]

proc main =
  # RKBV (2-strip film)
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - color palette switch")
  defer: closeWindow() # Close window and OpenGL context
  # Load shader to be used on some parts drawing
  # NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
  # NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  let shader = loadShader("", &"resources/shaders/glsl{glslVersion}/palette_switch.fs")
  # Get variable (uniform) location on the shader to connect with the program
  # NOTE: If uniform variable could not be found in the shader, function returns -1
  let paletteLoc = getShaderLocation(shader, "palette")
  var currentPalette = 0
  const lineHeight = screenHeight div ColorsPerPalette
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # -------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    if isKeyPressed(KeyRight): inc currentPalette
    elif isKeyPressed(KeyLeft): dec currentPalette

    if currentPalette >= MaxPalettes: currentPalette = 0
    elif currentPalette < 0: currentPalette = MaxPalettes - 1
    # Send new value to the shader to be used on drawing.
    # NOTE: We are sending RGB triplets w/o the alpha channel
    setShaderValueV(shader, paletteLoc, palettes[currentPalette])
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    beginShaderMode(shader)
    for i in 0..<ColorsPerPalette:
      # Draw horizontal screen-wide rectangles with increasing "palette index"
      # The used palette index is encoded in the RGB components of the pixel
      drawRectangle(0, lineHeight * i.int32, getScreenWidth(), lineHeight,
          Color(r: i.uint8, g: i.uint8, b: i.uint8, a: 255))
    endShaderMode()
    drawText("< >", 10, 10, 30, DarkBlue)
    drawText("CURRENT PALETTE:", 60, 15, 20, RayWhite)
    drawText(paletteText[currentPalette], 300, 15, 20, Red)
    drawFPS(700, 15)
    endDrawing()

main()
