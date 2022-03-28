# ***************************************************************************************
#
# raylib [core] example - quat conversions
#
# Generally you should really stick to eulers OR quats...
# This tests that various conversions are equivalent.
#
# This example has been created using raylib 3.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2020-2021 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, raymath, std/[math, strformat]

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - quat conversions")
  defer: closeWindow() # Close window and OpenGL context
  let camera = Camera3D(
    position: Vector3(x: 0, y: 10, z: 10), # Camera position
    target: Vector3(x: 0, y: 0, z: 0),     # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),         # Camera up vector (rotation towards target)
    fovy: 45,                              # Camera field-of-view Y
    projection: CameraPerspective          # Camera mode type
  )
  # Load a cylinder model for testing
  var model = loadModelFromMesh(genMeshCylinder(0.2, 1, 32))
  # Generic quaternion for operations
  var q1: Quaternion
  # Transform matrices required to draw 4 cylinders
  var
    m1: Matrix
    m2: Matrix
    m3: Matrix
    m4: Matrix
  # Generic vectors for rotations
  var
    v1: Vector3
    v2: Vector3

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    if v2.x < 0: v2.x += PI*2
    if v2.y < 0: v2.y += PI*2
    if v2.z < 0: v2.z += PI*2

    if not isKeyDown(KeySpace):
      v1.x += 0.01'f32
      v1.y += 0.03'f32
      v1.z += 0.05'f32

    if v1.x > PI*2: v1.x -= PI*2
    if v1.y > PI*2: v1.y -= PI*2
    if v1.z > PI*2: v1.z -= PI*2

    q1 = fromEuler(v1.x, v1.y, v1.z)
    m1 = rotateZYX(v1)
    m2 = toMatrix(q1)

    q1 = fromMatrix(m1)
    m3 = toMatrix(q1)

    v2 = toEuler(q1) # Angles returned in radians

    m4 = rotateZYX(v2)
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    beginMode3D(camera)
    model.transform = m1
    drawModel(model, Vector3(x: -1, y: 0, z: 0), 1, Red)

    model.transform = m2
    drawModel(model, Vector3(x: 1, y: 0, z: 0), 1, Red)

    model.transform = m3
    drawModel(model, Vector3(x: 0, y: 0, z: 0), 1, Red)

    model.transform = m4
    drawModel(model, Vector3(x: 0, y: 0, z: -1), 1, Red)

    drawGrid(10, 1)
    endMode3D()

    drawText(&"{v1.x:2.3f}", 20, 20, 20, if v1.x == v2.x: Green else: Black)
    drawText(&"{v1.y:2.3f}", 20, 40, 20, if v1.y == v2.y: Green else: Black)
    drawText(&"{v1.z:2.3f}", 20, 60, 20, if v1.z == v2.z: Green else: Black)

    drawText(&"{v2.x:2.3f}", 200, 20, 20, if v1.x == v2.x: Green else: Black)
    drawText(&"{v2.y:2.3f}", 200, 40, 20, if v1.y == v2.y: Green else: Black)
    drawText(&"{v2.z:2.3f}", 200, 60, 20, if v1.z == v2.z: Green else: Black)
    endDrawing()

main()
