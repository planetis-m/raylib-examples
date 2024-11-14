# ****************************************************************************************
#
#    raylib [text] example - Font loading
#
#    NOTE: raylib can load fonts from multiple input file formats:
#
#      - TTF/OTF > Sprite font atlas is generated on loading, user can configure
#                  some of the generation parameters (size, characters to include)
#      - BMFonts > Angel code font fileformat, sprite font image must be provided
#                  together with the .fnt file, font generation cna not be configured
#      - XNA Spritefont > Sprite font image, following XNA Spritefont conventions,
#                  Characters in image must follow some spacing and order rules
#
#    Example originally created with raylib 1.4, last time updated with raylib 3.0
#
#    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#    BSD-like license that allows static linking with closed source software
#
#    Copyright (c) 2016-2024 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450
  msg = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ" # Define characters to draw

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main() =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [text] example - font loading")
  defer: closeWindow() # Ensure window closure on proc exit

  # Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
  let
    # BMFont (AngelCode) : Font data and image atlas have been generated using external program
    fontBm = loadFont("resources/pixantiqua.fnt")
    # TTF font : Font data and atlas are generated directly from TTF
    # NOTE: We define a font base size of 32 pixels tall and up-to 250 characters
    fontTtf = loadFont("resources/pixantiqua.ttf", 32, 250)

  setTextLineSpacing(16) # Set line spacing for multiline text (when line breaks are included '\n')
  var useTtf = false
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    if isKeyDown(Space):
      useTtf = true
    else:
      useTtf = false
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("Hold SPACE to use TTF generated font", 20, 20, 20, LightGray)

    if not useTtf:
      drawText(fontBm, msg, Vector2(x: 20, y: 100), fontBm.baseSize.float32, 2, Maroon)
      drawText("Using BMFont (Angelcode) imported", 20, getScreenHeight() - 30, 20, Gray)
    else:
      drawText(fontTtf, msg, Vector2(x: 20, y: 100), fontTtf.baseSize.float32, 2, Lime)
      drawText("Using TTF font generated", 20, getScreenHeight() - 30, 20, Gray)

    endDrawing()

main()
