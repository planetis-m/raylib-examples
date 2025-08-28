# *******************************************************************************************
#
#  raylib [models] example - Load 3d model with animations and play them
#
#  Example complexity rating: [★★☆☆] 2/4
#
#  Example originally created with raylib 2.5, last time updated with raylib 3.5
#
#  Example contributed by Culacant (@culacant) and reviewed by Ramon Santamaria (@raysan5)
#
#  Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#  BSD-like license that allows static linking with closed source software
#
#  Copyright (c) 2019-2025 Culacant (@culacant) and Ramon Santamaria (@raysan5)
#
# ********************************************************************************************
#
#  NOTE: To export a model from blender, make sure it is not posed, the vertices need to be
#        in the same position as they would be in edit mode and the scale of your models is
#        set to 0. Scaling can be done from the export menu
#
# ********************************************************************************************

import raylib, raymath, std/math

const
  ScreenWidth = 800
  ScreenHeight = 450

proc main() =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [models] example - model animation")
  defer: closeWindow()

  # Define the camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 10.0, y: 10.0, z: 10.0),   # Camera position
    target: Vector3(x: 0.0, y: 0.0, z: 0.0),        # Camera looking at point
    up: Vector3(x: 0.0, y: 1.0, z: 0.0),            # Camera up vector (rotation towards target)
    fovy: 45.0,                                     # Camera field-of-view Y
    projection: Perspective                         # Camera mode type
  )

  # Load the animated model mesh and basic data
  var model = loadModel("resources/models/iqm/guy.iqm")
  # Load model texture and set material
  let texture = loadTexture("resources/models/iqm/guytex.png")
  # Set model material map texture
  model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture

  let position = Vector3(x: 0.0, y: 0.0, z: 0.0)  # Set model position

  # Load animation data
  var anims = loadModelAnimations("resources/models/iqm/guyanim.iqm")
  var animFrameCounter: int32 = 0

  disableCursor()     # Catch cursor
  setTargetFPS(60)    # Set our game to run at 60 frames-per-second

  # Main game loop
  while not windowShouldClose():  # Detect window close button or ESC key
    # Update
    updateCamera(camera, FirstPerson)

    # Play animation when spacebar is held down
    if isKeyDown(Space):
      animFrameCounter.inc()
      updateModelAnimation(model, anims[0], animFrameCounter)
      if animFrameCounter >= anims[0].frameCount:
        animFrameCounter = 0

    # Draw
    drawing():
      clearBackground(RayWhite)

      mode3D(camera):
        # Apply rotation transformation to the model
        model.transform = rotateXYZ(Vector3(x: degToRad(-90.0), y: 0.0, z: 0.0))
        drawModel(model, position, 1.0, White)

        for i in 0..<model.boneCount:
          drawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2, 0.2, 0.2, Red)

        drawGrid(10, 1.0)  # Draw a grid

      drawText("PRESS SPACE to PLAY MODEL ANIMATION", 10, 10, 20, Maroon)
      drawText("(c) Guy IQM 3D model by @culacant", ScreenWidth - 200, ScreenHeight - 20, 10, Gray)

main()
