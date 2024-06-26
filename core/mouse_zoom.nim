# ****************************************************************************************
#
#   raylib [core] example - 2d camera mouse zoom
#
#   Example originally created with raylib 4.2, last time updated with raylib 4.2
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2022 Jeffery Myers (@JeffM2501)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib, raymath, rlgl

const
  screenWidth = 800
  screenHeight = 450

type
  ZoomMode = enum
    MouseWheel, MouseMove

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera mouse zoom")
  var camera = Camera2D(zoom: 1)
  var zoomMode = MouseWheel

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(One): zoomMode = MouseWheel
    elif isKeyPressed(Two): zoomMode = MouseMove
    # Translate based on mouse right click
    if isMouseButtonDown(Right):
      var delta = getMouseDelta()
      delta /= -camera.zoom
      camera.target += delta

    if zoomMode == MouseWheel:
      let wheel = getMouseWheelMove()
      if wheel != 0:
        # Get the world point that is under the mouse
        let mouseWorldPos = getScreenToWorld2D(getMousePosition(), camera)
        # Set the offset to where the mouse is
        camera.offset = getMousePosition()
        # Set the target to match, so that the camera maps the world space point
        # under the cursor to the screen space point under the cursor at any zoom
        camera.target = mouseWorldPos
        # Zoom increment
        var scaleFactor = 1 + (0.25*abs(wheel))
        if wheel < 0: scaleFactor = 1/scaleFactor
        camera.zoom = clamp(camera.zoom*scaleFactor, 0.125, 64)
    else:
      # Zoom based on mouse left click
      if isMouseButtonPressed(Left):
        # Get the world point that is under the mouse
        let mouseWorldPos = getScreenToWorld2D(getMousePosition(), camera)

        # Set the offset to where the mouse is
        camera.offset = getMousePosition()

        # Set the target to match, so that the camera maps the world space point
        # under the cursor to the screen space point under the cursor at any zoom
        camera.target = mouseWorldPos

      if isMouseButtonDown(Left):
        # Zoom increment
        let deltaX = getMouseDelta().x
        var scaleFactor = 1 + (0.01*abs(deltaX))
        if deltaX < 0:
          scaleFactor = 1/scaleFactor
        camera.zoom = clamp(camera.zoom*scaleFactor, 0.125, 64)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(RayWhite)
      mode2D(camera):
        # Draw the 3d grid, rotated 90 degrees and centered around 0,0
        # just so we have something in the XY plane
        pushMatrix()
        translatef(0, 25*50, 0)
        rotatef(90, 1, 0, 0)
        drawGrid(100, 50)
        popMatrix()
        # Draw a reference circle
        drawCircle(getScreenWidth() div 2, getScreenHeight() div 2, 50, Maroon)

      if zoomMode == MouseWheel:
        drawText("Mouse right button drag to move, mouse wheel to zoom", 10, 10, 20, DarkGray)
      else:
        drawText("Mouse right button drag to move, mouse press and move to zoom", 10, 10, 20, DarkGray)
      # ----------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
