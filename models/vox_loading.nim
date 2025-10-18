# ****************************************************************************************
#
#   raylib [models] example - Load models vox (MagicaVoxel)
#
#   Example complexity rating: [★☆☆☆] 1/4
#
#   Example originally created with raylib 4.0, last time updated with raylib 4.0
#
#   Example contributed by Johann Nadalutti (@procfxgen) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2021-2025 Johann Nadalutti (@procfxgen) and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, raymath, rlights, std/[os, strformat, lenientops]

const
  MaxVoxFiles = 4
  ScreenWidth = 800
  ScreenHeight = 450

  voxFileNames = [
    "resources/models/vox/chr_knight.vox",
    "resources/models/vox/chr_sword.vox",
    "resources/models/vox/monu9.vox",
    "resources/models/vox/fez.vox"
  ]

when defined(GraphicsApiOpenGl33):
  const GlslVersion = 330
else:
  const GlslVersion = 100

proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [models] example - magicavoxel loading")
  defer: closeWindow() # Automatic cleanup of window resources

  # Define the camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 10, y: 10, z: 10), # Camera position
    target: Vector3(x: 0, y: 0, z: 0),      # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),          # Camera up vector (rotation towards target)
    fovy: 45,                               # Camera field-of-view Y
    projection: Perspective                 # Camera projection type
  )

  # Load MagicaVoxel files
  var models = default array[MaxVoxFiles, Model]

  for i in 0..<MaxVoxFiles:
    # Load VOX file and measure time
    let t0: float64 = getTime()*1000.0
    models[i] = loadModel(voxFileNames[i])
    let t1: float64 = getTime()*1000.0

    traceLog(Warning, &"[{voxFileNames[i]}] File loaded in {t1 - t0:.3f} ms")

    # Compute model translation matrix to center model on draw position (0, 0, 0)
    let bb = getModelBoundingBox(models[i])
    let center = Vector3(
      x: bb.min.x + ((bb.max.x - bb.min.x)/2'f32),
      y: bb.min.y + ((bb.max.y - bb.min.y)/2'f32),
      z: bb.min.z + ((bb.max.z - bb.min.z)/2'f32)
    )

    let matTranslate = translate(-center.x, 0, -center.z)
    models[i].transform = matTranslate

  var currentModel = 0

  # Load voxel shader
  var shader = loadShader(
    &"resources/shaders/glsl{GlslVersion}/voxel_lighting.vs",
    &"resources/shaders/glsl{GlslVersion}/voxel_lighting.fs"
  )

  # Get some required shader locations
  shader.locs[VectorView] = getShaderLocation(shader, "viewPos")
  # NOTE: "matModel" location name is automatically assigned on shader loading,
  # no need to get the location again if using that uniform name
  #shader.locs[MatrixModel] = getShaderLocation(shader, "matModel")

  # Ambient light level (some basic lighting)
  let ambientLoc = getShaderLocation(shader, "ambient")
  setShaderValue(shader, ambientLoc, [0.1'f32, 0.1, 0.1, 1])

  # Assign out lighting shader to model
  for i in 0..<MaxVoxFiles:
    for j in 0..<models[i].materialCount:
      models[i].materials[j].shader = shader

  # Create lights
  var lights = default array[MaxLights, Light]
  lights[0] = createLight(Point, Vector3(x: -20, y: 20, z: -20), Vector3(), Gray, shader)
  lights[1] = createLight(Point, Vector3(x: 20, y: -20, z: 20), Vector3(), Gray, shader)
  lights[2] = createLight(Point, Vector3(x: -20, y: 20, z: 20), Vector3(), Gray, shader)
  lights[3] = createLight(Point, Vector3(x: 20, y: -20, z: -20), Vector3(), Gray, shader)

  setTargetFPS(60) # Set our game to run at 60 frames-per-second

  var modelpos = Vector3()
  var camerarot = Vector3()

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    if isMouseButtonDown(Middle):
      let mouseDelta = getMouseDelta()
      camerarot.x = mouseDelta.x*0.05'f32
      camerarot.y = mouseDelta.y*0.05'f32
    else:
      camerarot.x = 0
      camerarot.y = 0

    updateCamera(camera,
      Vector3(
        x: int32(isKeyDown(W) or isKeyDown(Up))*0.1'f32 -      # Move forward-backward
            int32(isKeyDown(S) or isKeyDown(Down))*0.1'f32,
        y: int32(isKeyDown(D) or isKeyDown(Right))*0.1'f32 -   # Move right-left
            int32(isKeyDown(A) or isKeyDown(Left))*0.1'f32,
        z: 0                                              # Move up-down
      ),
      camerarot,
      getMouseWheelMove()*-2'f32                            # Move to target (zoom)
    )

    # Cycle between models on mouse click
    if isMouseButtonPressed(Left):
      currentModel = (currentModel + 1) mod MaxVoxFiles

    # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    let cameraPos = [camera.position.x, camera.position.y, camera.position.z]
    setShaderValue(shader, shader.locs[VectorView], cameraPos)

    # Update light values (actually, only enable/disable them)
    for i in 0..<MaxLights:
      updateLightValues(shader, lights[i])

    # Draw
    drawing():
      clearBackground(RayWhite)

      # Draw 3D model
      mode3D(camera):
        drawModel(models[currentModel], modelpos, 1, White)
        drawGrid(10, 1)

        # Draw spheres to show where the lights are
        for i in 0..<MaxLights:
          if lights[i].enabled:
            drawSphere(lights[i].position, 0.2, 8, 8, lights[i].color)
          else:
            drawSphereWires(lights[i].position, 0.2, 8, 8, colorAlpha(lights[i].color, 0.3))

      # Display info
      drawRectangle(10, 400, 340, 60, fade(SkyBlue, 0.5))
      drawRectangleLines(10, 400, 340, 60, fade(DarkBlue, 0.5))
      drawText("MOUSE LEFT BUTTON to CYCLE VOX MODELS", 40, 410, 10, Blue)
      drawText("MOUSE MIDDLE BUTTON to ZOOM OR ROTATE CAMERA", 40, 420, 10, Blue)
      drawText("UP-DOWN-LEFT-RIGHT KEYS to MOVE CAMERA", 40, 430, 10, Blue)
      drawText(&"File: {extractFilename(voxFileNames[currentModel])}", 10, 10, 20, Gray)

main()
