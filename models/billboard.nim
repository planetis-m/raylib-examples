# ********************************************************************************************
#
#  raylib [models] example - Drawing billboards
#
#  Example complexity rating: [★★★☆] 3/4
#
#  Example originally created with raylib 1.3, last time updated with raylib 3.5
#
#  Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#  BSD-like license that allows static linking with closed source software
#
#  Copyright (c) 2015-2025 Ramon Santamaria (@raysan5)
#
# ********************************************************************************************

import raylib, raymath
import std/lenientops

const
  ScreenWidth = 800
  ScreenHeight = 450

proc main() =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [models] example - drawing billboards")
  defer: closeWindow()  # Close window and OpenGL context

  # Define the camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 5.0, y: 4.0, z: 5.0),    # Camera position
    target: Vector3(x: 0.0, y: 2.0, z: 0.0),      # Camera looking at point
    up: Vector3(x: 0.0, y: 1.0, z: 0.0),          # Camera up vector (rotation towards target)
    fovy: 45.0,                                   # Camera field-of-view Y
    projection: Perspective                       # Camera projection type
  )

  let bill = loadTexture("resources/billboard.png")    # Our billboard texture
  let billPositionStatic = Vector3(x: 0.0, y: 2.0, z: 0.0)          # Position of static billboard
  let billPositionRotating = Vector3(x: 1.0, y: 2.0, z: 1.0)        # Position of rotating billboard

  # Entire billboard texture, source is used to take a segment from a larger texture
  let source = Rectangle(x: 0.0, y: 0.0, width: float32(bill.width), height: float32(bill.height))

  # NOTE: Billboard locked on axis-Y
  let billUp = Vector3(x: 0.0, y: 1.0, z: 0.0)

  # Set the height of the rotating billboard to 1.0 with the aspect ratio fixed
  let size = Vector2(x: source.width/source.height, y: 1.0)

  # Rotate around origin
  # Here we choose to rotate around the image center
  let origin = size*0.5

  # Distance is needed for the correct billboard draw order
  # Larger distance (further away from the camera) should be drawn prior to smaller distance
  var 
    distanceStatic: float32
    distanceRotating: float32
    rotation: float32 = 0.0

  setTargetFPS(60)                   # Set our game to run at 60 frames-per-second

  # Main game loop
  while not windowShouldClose():        # Detect window close button or ESC key
    # Update
    updateCamera(camera, Orbital)
    
    rotation += 0.4
    distanceStatic = distance(camera.position, billPositionStatic)
    distanceRotating = distance(camera.position, billPositionRotating)

    # Draw
    drawing():
      clearBackground(RayWhite)
      
      mode3D(camera):
        drawGrid(10, 1.0)        # Draw a grid
        
        # Draw order matters!
        if distanceStatic > distanceRotating:
          drawBillboard(camera, bill, billPositionStatic, 2.0, White)
          drawBillboard(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, White)
        else:
          drawBillboard(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, White)
          drawBillboard(camera, bill, billPositionStatic, 2.0, White)
      
      drawFPS(10, 10)

main()
