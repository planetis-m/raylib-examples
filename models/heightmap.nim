# ****************************************************************************************
#
#   raylib [models] example - Heightmap loading and drawing
#
#   Example originally created with raylib 1.8, last time updated with raylib 3.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2015-2022 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [models] example - heightmap loading and drawing")
  defer: closeWindow() # Close window and OpenGL context

  # Define our custom camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 18, y: 18, z: 18), # Camera position
    target: Vector3(x: 0, y: 0, z: 0),      # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),          # Camera up vector (rotation towards target)
    fovy: 45,                               # Camera field-of-view Y
    projection: Perspective                 # Camera projection type
  )

  var image = loadImage("resources/heightmap.png") # Load heightmap image (RAM)
  let texture = loadTextureFromImage(image) # Convert image to texture (VRAM)
  let mesh = genMeshHeightmap(image, Vector3(x: 16, y: 8, z: 16)) # Generate heightmap mesh (RAM and VRAM)
  var model = loadModelFromMesh(mesh) # Load model from generated mesh
  Model(model).materials[0].maps[MaterialMapIndex.Diffuse].texture = texture # Set map diffuse texture

  let mapPosition = Vector3(x: -8, y: 0, z: -8) # Define model position
  reset(image) # Unload heightmap image from RAM, already uploaded to VRAM

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateCamera(camera, Orbital) # Set an orbital camera mode
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    beginMode3D(camera)
    drawModel(Model(model), mapPosition, 1, Red)
    drawGrid(20, 1)
    endMode3D()

    drawTexture(texture, screenWidth - texture.width - 20, 20, White)
    drawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, Green)
    drawFPS(10, 10)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
