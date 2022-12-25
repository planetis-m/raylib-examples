# ****************************************************************************************
#
#   raylib [shapes] example - easings rectangle array
#
#   NOTE: This example requires 'easings.h' library, provided on raylib/src. Just copy
#   the library to same directory as example or make sure it's available on include path.
#
#   Example originally created with raylib 2.0, last time updated with raylib 2.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2014-2022 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, reasings, std/lenientops

const
  screenWidth = 800
  screenHeight = 450

const
  RecsWidth = 50
  RecsHeight = 50
  MaxRecsX = 800 div RecsWidth
  MaxRecsY = 450 div RecsHeight
  PlayTimeInFrames = 240 # At 60 fps = 4 seconds

type
  State = enum
    Playing, Finished

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shapes] example - easings rectangle array")

  var recs: array[MaxRecsX*MaxRecsY, Rectangle]
  for y in 0 ..< MaxRecsY:
    for x in 0 ..< MaxRecsX:
      recs[y*MaxRecsX + x] = Rectangle(
        x: RecsWidth/2'f32 + RecsWidth*x,
        y: RecsHeight/2'f32 + RecsHeight*y,
        width: RecsWidth,
        height: RecsHeight
      )

  var rotation: float32 = 0
  var framesCounter: int32 = 0
  var state = Playing # Rectangles animation state: 0-Playing, 1-Finished

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if state == Playing:
      inc(framesCounter)
      for i in 0 ..< MaxRecsX*MaxRecsY:
        recs[i].height = circOut(framesCounter.float32, RecsHeight, -RecsHeight, PlayTimeInFrames)
        recs[i].width = circOut(framesCounter.float32, RecsWidth, -RecsWidth, PlayTimeInFrames)
        if recs[i].height < 0:
          recs[i].height = 0
        if recs[i].width < 0:
          recs[i].width = 0
        if recs[i].height == 0 and recs[i].width == 0:
          state = Finished
        rotation = linearIn(framesCounter.float32, 0, 360, PlayTimeInFrames)
    elif state == Finished and isKeyPressed(KeySpace):
      # When animation has finished, press space to restart
      framesCounter = 0
      for i in 0 ..< MaxRecsX*MaxRecsY:
        recs[i].height = RecsHeight
        recs[i].width = RecsWidth
      state = Playing
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    if state == Playing:
      for i in 0 ..< MaxRecsX*MaxRecsY:
        drawRectangle(recs[i], Vector2(x: recs[i].width/2, y: recs[i].height/2), rotation, Red)
    elif state == Finished:
      drawText("PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, Gray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
