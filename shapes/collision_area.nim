# ***************************************************************************************
#
# raylib [shapes] example - collision area
#
# This example has been created using raylib 2.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2013-2019 Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import nimraylib_now, std/lenientops

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shapes] example - collision area")
  # Box A: Moving box
  var boxA = Rectangle(
    x: 10,
    y: getScreenHeight() / 2'f32 - 50,
    width: 200,
    height: 100
  )
  var boxASpeedX = 4'i32
  # Box B: Mouse moved box
  var boxB = Rectangle(
    x: getScreenWidth() / 2'f32 - 30,
    y: getScreenHeight() / 2'f32 - 30,
    width: 60,
    height: 60
  )
  var boxCollision: Rectangle # Collision rectangle
  var screenUpperLimit = 40'i32 # Top menu limits
  var pause = false # Movement pause
  var collision = false # Collision detection
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    # Move box if not paused
    if not pause:
      boxA.x += boxASpeedX.float32
    if boxA.x + boxA.width >= getScreenWidth() or boxA.x <= 0:
      boxASpeedX = boxASpeedX * -1
    boxB.x = getMouseX() - boxB.width / 2
    boxB.y = getMouseY() - boxB.height / 2
    # Make sure Box B does not go out of move area limits
    if boxB.x + boxB.width >= getScreenWidth():
      boxB.x = getScreenWidth() - boxB.width
    elif boxB.x <= 0:
      boxB.x = 0
    if boxB.y + boxB.height >= getScreenHeight():
      boxB.y = getScreenHeight() - boxB.height
    elif boxB.y <= screenUpperLimit: # Check boxes collision
      boxB.y = screenUpperLimit.float32
    collision = checkCollisionRecs(boxA, boxB)
    # Get collision rectangle (only on collision)
    if collision:
      boxCollision = getCollisionRec(boxA, boxB)
    if isKeyPressed(Space):
      pause = not pause
    beginDrawing()
    clearBackground(White)
    drawRectangle(0, 0, screenWidth, screenUpperLimit, if collision: Red else: Black)
    drawRectangleRec(boxA, Gold)
    drawRectangleRec(boxB, Blue)
    if collision:
      # Draw collision area
      drawRectangleRec(boxCollision, Lime)
      # Draw collision message
      drawText("COLLISION!",
          getScreenWidth() div 2 - measureText("COLLISION!", 20) div 2,
          screenUpperLimit div 2 - 10, 20, Black)
      # Draw collision area
      drawText(textFormat("Collision Area: %i", boxCollision.width.int32 *
          boxCollision.height.int32), getScreenWidth() div 2 - 100,
          screenUpperLimit + 10, 20, Black)
    drawFPS(10, 10)
    endDrawing()
  # De-Initialization
  # -------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
