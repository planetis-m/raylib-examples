# ****************************************************************************************
#
#   raylib [models] example - Show the difference between perspective and orthographic projection
#
#   Example originally created with raylib 2.0, last time updated with raylib 3.7
#
#   Example contributed by Max Danielsson (@autious) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2018-2023 Max Danielsson (@autious) and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  FovyPerspective: float32 = 45.0
  WidthOrthographic: float32 = 10.0

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [models] example - geometric shapes")
  # Define the camera to look into our 3d world
  let camera = Camera(
    position: Vector3(x: 0, y: 10, z: 10),
    target: Vector3(x: 0, y: 0, z: 0),
    up: Vector3(x: 0, y: 1, z: 0),
    fovy: FovyPerspective,
    projection: Perspective
  )
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(Space):
      if camera.projection == Perspective:
        camera.fovy = WidthOrthographic
        camera.projection = Orthographic
      else:
        camera.fovy = FovyPerspective
        camera.projection = Perspective
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(RayWhite)

      mode3D(camera):
        drawCube(Vector3(x: -4, y: 0, z: 2), 2, 5, 2, Red)
        drawCubeWires(Vector3(x: -4, y: 0, z: 2), 2, 5, 2, Gold)
        drawCubeWires(Vector3(x: -4, y: 0, z: -2), 3, 6, 2, Maroon)
        drawSphere(Vector3(x: -1, y: 0, z: -2), 1, Green)
        drawSphereWires(Vector3(x: 1, y: 0, z: 2), 2, 16, 16, Lime)
        drawCylinder(Vector3(x: 4, y: 0, z: -2), 1, 2, 3, 4, SkyBlue)
        drawCylinderWires(Vector3(x: 4, y: 0, z: -2), 1, 2, 3, 4, DarkBlue)
        drawCylinderWires(Vector3(x: 4.5, y: -1, z: 2), 1, 1, 2, 6, Brown)
        drawCylinder(Vector3(x: 1, y: 0, z: -4), 0, 1.5, 3, 8, Gold)
        drawCylinderWires(Vector3(x: 1, y: 0, z: -4), 0, 1.5, 3, 8, Pink)
        drawGrid(10, 1) # Draw a grid

      drawText("Press Spacebar to switch camera type", 10, getScreenHeight() - 30, 20, DarkGray)
      if camera.projection == Orthographic:
        drawText("ORTHOGRAPHIC", 10, 40, 20, Black)
      elif camera.projection == Perspective:
        drawText("PERSPECTIVE", 10, 40, 20, Black)
      drawFPS(10, 10)
      # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
