# ****************************************************************************************
#
#   raylib [textures] example - Load textures from raw data
#
#   NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#   Example originally created with raylib 1.3, last time updated with raylib 3.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2015-2022 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  width = 960
  height = 480

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - texture from raw data")
  defer: closeWindow() # Close window and OpenGL context

  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  # Load RAW image data (512x512, 32bit RGBA, no file header)
  let fudesumiRaw = loadImageRaw("resources/fudesumi.raw", 384, 512, UncompressedR8g8b8a8, 0)
  let fudesumi = loadTextureFromImage(fudesumiRaw) # Upload CPU (RAM) image to GPU (VRAM)

  # Generate a checked texture by code
  # Dynamic memory allocation to store pixels data (Color type)
  var pixels = newSeq[Color](width*height)
  for y in 0..<height:
    for x in 0..<width:
      if ((x div 32 + y div 32) div 1) mod 2 == 0:
        pixels[y*width + x] = Orange
      else:
        pixels[y*width + x] = Gold

  # Load pixels data into an image structure and create texture
  let checked = loadTextureFromData(pixels, width, height)
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # TODO: Update your variables here
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawTexture(checked, screenWidth div 2 - checked.width div 2,
        screenHeight div 2 - checked.height div 2, fade(White, 0.5))
    drawTexture(fudesumi, 430, -30, White)
    drawText("CHECKED TEXTURE ", 84, 85, 30, Brown)
    drawText("GENERATED by CODE", 72, 148, 30, Brown)
    drawText("and RAW IMAGE LOADING", 46, 210, 30, Brown)
    drawText("(c) Fudesumi sprite by Eiden Marsal", 310, screenHeight - 20, 10, Brown)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
