# ***************************************************************************************
#
# raylib [textures] example - Texture source and destination rectangles
#
# This example has been created using raylib 1.3 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, std/lenientops

const
  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight,
      "raylib [textures] examples - texture source and destination rectangles")
  defer: closeWindow() # Close window and OpenGL context
  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let scarfy = loadTexture("resources/scarfy.png") # Texture loading
  let frameWidth = scarfy.width div 6
  let frameHeight = scarfy.height
  # Source rectangle (part of the texture to use for drawing)
  let sourceRec = Rectangle(x: 0, y: 0, width: frameWidth.float32, height: frameHeight.float32)
  # Destination rectangle (screen rectangle where drawing part of texture)
  let destRec = Rectangle(x: screenWidth/2'f32,
      y: screenHeight/2'f32, width: frameWidth*2'f32, height: frameHeight*2'f32)
  # Origin of the texture (rotation/scale point), it's relative to destination rectangle size
  let origin = Vector2(x: frameWidth.float32, y: frameHeight.float32)
  var rotation: int32 = 0
  setTargetFPS(60)
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    inc(rotation)
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    # NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
    # sourceRec defines the part of the texture we use for drawing
    # destRec defines the rectangle where our texture part will fit (scaling it to fit)
    # origin defines the point of the texture used as reference for rotation and scaling
    # rotation defines the texture rotation (using origin as rotation point)
    drawTexturePro(scarfy, sourceRec, destRec, origin, rotation.float32, White)
    drawLine(destRec.x.int32, 0, destRec.x.int32, screenHeight, Gray)
    drawLine(0, destRec.y.int32, screenWidth, destRec.y.int32, Gray)
    drawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, Gray)
    endDrawing()

main()
