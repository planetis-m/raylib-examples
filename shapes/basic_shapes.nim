# ****************************************************************************************
#
#   raylib [shapes] example - Draw basic shapes 2d (rectangle, circle, line...)
#
#   This example has been created using raylib 1.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2014 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight, "raylib [shapes] example - basic shapes drawing")
  setTargetFPS(60)
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("some basic shapes available on raylib", 20, 20, 20, DarkGray)

    # Circle shapes and lines
    drawCircle(screenWidth div 5, 120, 35, DarkBlue)
    drawCircleGradient(screenWidth div 5, 220, 60, Green, SkyBlue)
    drawCircleLines(screenWidth div 5, 340, 80, DarkBlue)

    # Rectangle shapes and lines
    drawRectangle(screenWidth div 4 * 2 - 60, 100, 120, 60, Red)
    drawRectangleGradientH(screenWidth div 4 * 2 - 90, 170, 180, 130, Maroon, Gold)
    drawRectangleLines(screenWidth div 4 * 2 - 40, 320, 80, 60, Orange) # NOTE: Uses QUADS internally, not lines

    # Triangle shapes and lines
    drawTriangle(Vector2(x: screenWidth/4'f32 * 3, y: 80),
                 Vector2(x: screenWidth/4'f32 * 3 - 60, y: 150),
                 Vector2(x: screenWidth/4'f32 * 3 + 60, y: 150), Violet)

    drawTriangleLines(Vector2(x: screenWidth/4'f32 * 3, y: 160),
                      Vector2(x: screenWidth/4'f32 * 3 - 20, y: 230),
                      Vector2(x: screenWidth/4'f32 * 3 + 20, y: 230), DarkBlue)

    # Polygon shapes and lines
    drawPoly(Vector2(x: screenWidth/4'f32 * 3, y: 320), 6, 80, 0, Brown)
    drawPolyLines(Vector2(x: screenWidth/4'f32 * 3, y: 320), 6, 80, 0, 6, Beige)

    # NOTE: We draw all LINES based shapes together to optimize internal drawing,
    # this way, all LINES are rendered in a single draw pass
    drawLine(18, 42, screenWidth - 18'i32, 42, Black)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
