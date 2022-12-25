# ****************************************************************************************
#
# raylib [textures] example - Texture loading and drawing a part defined by a rectangle
#
# This example has been created using raylib 1.3 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2014 Ramon Santamaria (@raysan5)
# Adapted in 2021 by greenfork
#
# ****************************************************************************************

import raylib, std/[lenientops, strutils]

const
  MaxFrameSpeed = 15
  MinFrameSpeed = 1

  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [texture] example - texture rectangle")
  defer: closeWindow() # Close window and OpenGL context

  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  let scarfy = loadTexture("resources/scarfy.png") # Texture loading
  let position = Vector2(x: 350, y: 280)
  var frameRec = Rectangle(x: 0, y: 0, width: scarfy.width/6'f32, height: scarfy.height.float32)
  var currentFrame: int32 = 0
  var framesCounter: int32 = 0
  var framesSpeed: int32 = 8 # Number of spritesheet frames shown by second

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    inc framesCounter
    if framesCounter >= 60 div framesSpeed:
      framesCounter = 0
      inc currentFrame
      if currentFrame > 5:
        currentFrame = 0
      frameRec.x = currentFrame*(scarfy.width/6'f32)
    if isKeyPressed(KeyRight):
      inc framesSpeed
    elif isKeyPressed(KeyLeft):
      dec framesSpeed
    if framesSpeed > MaxFrameSpeed:
      framesSpeed = MaxFrameSpeed
    elif framesSpeed < MinFrameSpeed:
      framesSpeed = MinFrameSpeed
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawTexture(scarfy, 15, 40, White)
    drawRectangleLines(15, 40, scarfy.width, scarfy.height, Lime)
    drawRectangleLines(15 + frameRec.x.int32, 40 + frameRec.y.int32, frameRec.width.int32,
        frameRec.height.int32, Red)
    drawText("FRAME SPEED: ", 165, 210, 10, DarkGray)
    drawText(format("$# FPS", framesSpeed), 575, 210, 10, DarkGray)
    drawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, DarkGray)
    for i in 0..<MaxFrameSpeed:
      if i < framesSpeed:
        drawRectangle(250 + 21*i.int32, 205, 20, 20, Red)
      drawRectangleLines(250 + 21*i.int32, 205, 20, 20, Maroon)
    drawTexture(scarfy, frameRec, position, White) # Draw part of the texture
    drawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, Gray)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
