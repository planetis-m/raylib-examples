# ****************************************************************************************
#
# raylib [models] example - Plane rotations (yaw, pitch, roll)
#
# This example has been created using raylib 1.8 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Berni (@Berni8k) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2017-2021 Berni (@Berni8k) and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, raymath, std/math

const
  screenWidth = 800
  screenHeight = 450

proc main =
  #setConfigFlags(flags(FlagMsaa4xHint, FlagWindowHighdpi))
  initWindow(screenWidth, screenHeight,
      "raylib [models] example - plane rotations (yaw, pitch, roll)")
  defer: closeWindow() # Close window and OpenGL context

  let camera = Camera(
    position: Vector3(x: 0, y: 50, z: -120), # Camera position perspective
    target: Vector3(x: 0, y: 0, z: 0),       # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),           # Camera up vector (rotation towards target)
    fovy: 30,                                # Camera field-of-view Y
    projection: CameraPerspective            # Camera type
  )

  var model = loadModel("resources/models/plane.obj") # Load model
  let texture = loadTexture("resources/models/plane_diffuse.png") # Load model texture
  model.materials[0].maps[MaterialMapDiffuse].texture = texture # Set map diffuse texture

  var
    pitch: float32 = 0
    roll: float32 = 0
    yaw: float32 = 0

  setTargetFPS(60)
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Plane pitch (x-axis) controls
    if isKeyDown(KeyDown): pitch += 0.6'f32
    elif isKeyDown(KeyUp): pitch -= 0.6'f32
    else:
      if pitch > 0.3'f32: pitch -= 0.3'f32
      elif pitch < -0.3'f32: pitch += 0.3'f32

    # Plane yaw (y-axis) controls
    if isKeyDown(KeyS): yaw -= 1'f32
    elif isKeyDown(KeyA): yaw += 1'f32
    else:
      if yaw > 0'f32: yaw -= 0.5'f32
      elif yaw < 0'f32: yaw += 0.5'f32

    # Plane roll (z-axis) controls
    if isKeyDown(KeyLeft): roll -= 1'f32
    elif isKeyDown(KeyRight): roll += 1'f32
    else:
      if roll > 0'f32: roll -= 0.5'f32
      elif roll < 0'f32: roll += 0.5'f32

    # Tranformation matrix for rotations
    model.transform = rotateXYZ(Vector3(x: pitch.degToRad, y: yaw.degToRad, z: roll.degToRad))
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # Draw 3D model (recomended to draw 3D always before 2D)
    beginMode3D(camera)
    drawModel(model, Vector3(x: 0, y: -8, z: 0), 1, White) # Draw 3d model with texture
    drawGrid(10, 10)
    endMode3D()

    # Draw controls info
    drawRectangle(30, 370, 260, 70, fade(Green, 0.5))
    drawRectangleLines(30, 370, 260, 70, fade(DarkGreen, 0.5))
    drawText("Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, DarkGray)
    drawText("Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, DarkGray)
    drawText("Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, DarkGray)

    drawText("(c) WWI Plane Model created by GiaHanLam", screenWidth - 240, screenHeight - 20, 10, DarkGray)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
