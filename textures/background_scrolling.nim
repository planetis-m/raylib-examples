# ****************************************************************************************
#
#   raylib [textures] example - Background scrolling
#
#   This example has been created using raylib 2.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2019 Ramon Santamaria (@raysan5)
#   Converted in 2021 by greenfork
#
# ****************************************************************************************

import std/lenientops, raylib

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - background scrolling")
  defer: closeWindow() # Close window and OpenGL context

  # NOTE: Be careful, background width must be equal or bigger than screen width
  # if not, texture should be draw more than two times for scrolling effect
  let background = loadTexture("resources/cyberpunk_street_background.png")
  let midground = loadTexture("resources/cyberpunk_street_midground.png")
  let foreground = loadTexture("resources/cyberpunk_street_foreground.png")

  var scrollingBack: float32 = 0
  var scrollingMid: float32 = 0
  var scrollingFore: float32 = 0

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    scrollingBack -= 0.1
    scrollingMid -= 0.5
    scrollingFore -= 1.0

    # NOTE: Texture is scaled twice its size, so it sould be considered on scrolling
    if scrollingBack <= -background.width * 2'f32:
      scrollingBack = 0
    if scrollingMid <= -midground.width * 2'f32:
      scrollingMid = 0
    if scrollingFore <= -foreground.width * 2'f32:
      scrollingFore = 0

    beginDrawing()
    clearBackground(getColor(0x052c46ff))
    # Draw background image twice
    # NOTE: Texture is scaled twice its size
    drawTexture(background, Vector2(x: scrollingBack, y: 20), 0, 2, White)
    drawTexture(background, Vector2(x: background.width * 2 + scrollingBack, y: 20), 0, 2, White)
    # Draw midground image twice
    drawTexture(midground, Vector2(x: scrollingMid, y: 20), 0, 2, White)
    drawTexture(midground, Vector2(x: midground.width * 2 + scrollingMid, y: 20), 0, 2, White)
    # Draw foreground image twice
    drawTexture(foreground, Vector2(x: scrollingFore, y: 70), 0, 2, White)
    drawTexture(foreground, Vector2(x: foreground.width * 2 + scrollingFore, y: 70), 0, 2, White)
    drawText("BACKGROUND SCROLLING & PARALLAX", 10, 10, 20, Red)
    drawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
        screenWidth - 330, screenHeight - 20, 10, RayWhite)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
