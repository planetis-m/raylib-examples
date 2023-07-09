# ****************************************************************************************
#
#   raylib [core] example - custom frame control
#
#   WARNING: This is an example for advance users willing to have full control over
#   the frame processes. By default, EndDrawing() calls the following processes:
#       1. Draw remaining batch data: rlDrawRenderBatchActive()
#       2. SwapScreenBuffer()
#       3. Frame time control: WaitTime()
#       4. PollInputEvents()
#
#   To avoid steps 2, 3 and 4, flag SUPPORT_CUSTOM_FRAME_CONTROL can be enabled in
#   config.h (it requires recompiling raylib). This way those steps are up to the user.
#
#   Note that enabling this flag invalidates some functions:
#       - GetFrameTime()
#       - SetTargetFPS()
#       - GetFPS()
#
#   This example has been created using raylib 3.8 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2021 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib, std/[lenientops, strformat, monotimes, os]

{.passC: "-DSUPPORT_CUSTOM_FRAME_CONTROL=1".}

const
  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight, "raylib [core] example - custom frame control")
  # Custom timming variables
  var previousTime = getMonoTime().ticks # Previous time measure
  var currentTime: int64 = 0 # Current time measure
  var updateDrawTime: int64 = 0 # Update + Draw time
  var waitTime = 0.0 # Wait time (if target fps required)
  var deltaTime: float32 = 0 # Frame time (Update + Draw + Wait time)
  var timeCounter: float32 = 0 # Accumulative time counter (seconds)
  var position: float32 = 0 # Circle position
  var pause = false # Pause control flag
  var targetFPS: int32 = 60 # Our initial target fps
  # -------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ---------------------------------------------------------------------------------
    pollInputEvents() # Poll input events (SUPPORT_CUSTOM_FRAME_CONTROL)
    if isKeyPressed(Space):
      pause = not pause
    if isKeyPressed(Up):
      inc(targetFPS, 20)
    elif isKeyPressed(Down):
      dec(targetFPS, 20)
    if targetFPS < 0:
      targetFPS = 0
    if not pause:
      position += 200 * deltaTime # We move at 200 pixels per second
      if position >= getScreenWidth():
        position = 0
      timeCounter += deltaTime # We count time (seconds)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    for i in 0 ..< getScreenWidth() div 200:
      drawRectangle(200 * i, 0, 1, getScreenHeight(), SkyBlue)
    drawCircle(position.int32, getScreenHeight() div 2 - 25, 50, Red)
    drawText(&"{timeCounter * 1000'f32:03.0f} ms", position.int32 - 40,
             getScreenHeight() div 2 - 100, 20, Maroon)
    drawText(&"PosX: {position:03.0f}", position.int32 - 50,
             getScreenHeight() div 2 + 40, 20, Black)
    drawText("Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.",
             10, 10, 20, DarkGray)
    drawText("PRESS SPACE to PAUSE MOVEMENT", 10, getScreenHeight() - 60, 20, Gray)
    drawText("PRESS UP | DOWN to CHANGE TARGET FPS", 10, getScreenHeight() - 30, 20, Gray)
    drawText(&"TARGET FPS: {targetFPS}", getScreenWidth() - 220, 10, 20, Lime)
    drawText(&"CURRENT FPS: {int32(1'f32 / deltaTime)}", getScreenWidth() - 220, 40, 20, Green)
    endDrawing()
    # NOTE: In case raylib is configured to SUPPORT_CUSTOM_FRAME_CONTROL,
    # Events polling, screen buffer swap and frame time control must be managed by the user
    swapScreenBuffer()
    # Flip the back buffer to screen (front buffer)
    currentTime = getMonoTime().ticks
    updateDrawTime = currentTime - previousTime
    if targetFPS > 0:
      waitTime = (1000_000_000'f32/targetFPS) - updateDrawTime
      if waitTime > 0:
        sleep(int(waitTime / 1000_000))
        currentTime = getMonoTime().ticks
        deltaTime = float32(currentTime - previousTime) / 1000_000_000
    else:
      deltaTime = updateDrawTime.float32 / 1000_000_000
    # Framerate could be variable
    previousTime = currentTime
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
