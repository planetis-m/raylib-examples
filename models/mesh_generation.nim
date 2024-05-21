# ****************************************************************************************
#
#   raylib example - procedural mesh generation
#
#   Example originally created with raylib 1.8, last time updated with raylib 4.0
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, std/importutils

const
  screenHeight = 450
  screenWidth = 800

  NumModels = 9

proc memAlloc(size: uint32): pointer {.importc: "MemAlloc".}

proc genMeshCustom(): Mesh =
  # Generate a simple triangle mesh from code
  privateAccess(Mesh)
  result = Mesh()
  result.triangleCount = 1
  result.vertexCount = result.triangleCount*3
  result.vertices = cast[typeof(result.vertices)](
      memAlloc(uint32(result.vertexCount*3*sizeof(float32)))) # 3 vertices, 3 coordinates each (x, y, z)
  result.texcoords = cast[typeof(result.texcoords)](
      memAlloc(uint32(result.vertexCount*2*sizeof(float32)))) # 3 vertices, 2 coordinates each (x, y)
  result.normals = cast[typeof(result.normals)](
      memAlloc(uint32(result.vertexCount*3*sizeof(float32)))) # 3 vertices, 3 coordinates each (x, y, z)

  # Vertex at (0, 0, 0)
  result.vertices[0] = 0
  result.vertices[1] = 0
  result.vertices[2] = 0
  result.normals[0] = 0
  result.normals[1] = 1
  result.normals[2] = 0
  result.texcoords[0] = 0
  result.texcoords[1] = 0

  # Vertex at (1, 0, 2)
  result.vertices[3] = 1
  result.vertices[4] = 0
  result.vertices[5] = 2
  result.normals[3] = 0
  result.normals[4] = 1
  result.normals[5] = 0
  result.texcoords[2] = 0.5
  result.texcoords[3] = 1

  # Vertex at (2, 0, 0)
  result.vertices[6] = 2
  result.vertices[7] = 0
  result.vertices[8] = 0
  result.normals[6] = 0
  result.normals[7] = 1
  result.normals[8] = 0
  result.texcoords[4] = 1
  result.texcoords[5] = 0

  # Upload mesh data from CPU (RAM) to GPU (VRAM) memory
  uploadMesh(result, false)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation")
  defer: closeWindow() # Close window and OpenGL context
  # We generate a checked image for texturing
  var checked = genImageChecked(2, 2, 1, 1, Red, Green)
  var texture = loadTextureFromImage(checked)
  reset(checked)
  var models: array[NumModels, Model]
  models[0] = loadModelFromMesh(genMeshPlane(2, 2, 5, 5))
  models[1] = loadModelFromMesh(genMeshCube(2, 1, 2))
  models[2] = loadModelFromMesh(genMeshSphere(2, 32, 32))
  models[3] = loadModelFromMesh(genMeshHemiSphere(2, 16, 16))
  models[4] = loadModelFromMesh(genMeshCylinder(1, 2, 16))
  models[5] = loadModelFromMesh(genMeshTorus(0.25, 4, 16, 32))
  models[6] = loadModelFromMesh(genMeshKnot(1, 2, 16, 128))
  models[7] = loadModelFromMesh(genMeshPoly(5, 2))
  models[8] = loadModelFromMesh(genMeshCustom())
  # Generated meshes could be exported as .obj files
  # discard exportMesh(models[0].meshes[0], "plane.obj")
  # discard exportMesh(models[1].meshes[0], "cube.obj")
  # discard exportMesh(models[2].meshes[0], "sphere.obj")
  # discard exportMesh(models[3].meshes[0], "hemisphere.obj")
  # discard exportMesh(models[4].meshes[0], "cylinder.obj")
  # discard exportMesh(models[5].meshes[0], "torus.obj")
  # discard exportMesh(models[6].meshes[0], "knot.obj")
  # discard exportMesh(models[7].meshes[0], "poly.obj")
  # discard exportMesh(models[8].meshes[0], "custom.obj")
  # Set checked texture as default diffuse component for all models material
  for i in 0..<NumModels:
    models[i].materials[0].maps[MaterialMapIndex.Diffuse].texture = texture
  # Define the camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 5, y: 5, z: 5),  # Camera position
    target: Vector3(x: 0, y: 0, z: 0),    # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),        # Camera up vector (rotation towards target)
    fovy: 45,                             # Camera field-of-view Y
    projection: Perspective               # Camera projection type
  )

  # Model drawing position
  var position = Vector3(x: 0, y: 0, z: 0)
  var currentModel: int32 = 0
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateCamera(camera, Orbital)
    if isMouseButtonPressed(Left):
      currentModel = (currentModel + 1) mod NumModels
      # Cycle between the textures
    if isKeyPressed(Right):
      inc(currentModel)
      if currentModel >= NumModels:
        currentModel = 0
    elif isKeyPressed(Left):
      dec(currentModel)
      if currentModel < 0:
        currentModel = NumModels - 1
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    beginMode3D(camera)
    drawModel(models[currentModel], position, 1, White)
    drawGrid(10, 1)
    endMode3D()
    drawRectangle(30, 400, 310, 30, fade(SkyBlue, 0.5))
    drawRectangleLines(30, 400, 310, 30, fade(DarkBlue, 0.5))
    drawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, Blue)
    case currentModel
    of 0:
      drawText("PLANE", 680, 10, 20, DarkBlue)
    of 1:
      drawText("CUBE", 680, 10, 20, DarkBlue)
    of 2:
      drawText("SPHERE", 680, 10, 20, DarkBlue)
    of 3:
      drawText("HEMISPHERE", 640, 10, 20, DarkBlue)
    of 4:
      drawText("CYLINDER", 680, 10, 20, DarkBlue)
    of 5:
      drawText("TORUS", 680, 10, 20, DarkBlue)
    of 6:
      drawText("KNOT", 680, 10, 20, DarkBlue)
    of 7:
      drawText("POLY", 680, 10, 20, DarkBlue)
    of 8:
      drawText("Custom (triangle)", 580, 10, 20, DarkBlue)
    else:
      discard
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
