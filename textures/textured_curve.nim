# ****************************************************************************************
#
#  raylib [textures] example - Draw a texture along a segmented curve
#
#  Example originally created with raylib 4.5-dev
#
#  Example contributed by Jeffery Myers and reviewed by Ramon Santamaria (@raysan5)
#
#  Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#  BSD-like license that allows static linking with closed source software
#
#  Copyright (c) 2022 Jeffery Myers and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, raymath, rlgl, std/[math, strformat]

# ----------------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

var
  texRoad: Texture
  showCurve = false

  curveWidth: int32 = 50
  curveSegments: int32 = 24

  startPosition: Vector2
  startPositionTangent: Vector2
  endPosition: Vector2
  endPositionTangent: Vector2
  selectedPoint: ptr Vector2

# ----------------------------------------------------------------------------------------
# Module Functions Definition
# ----------------------------------------------------------------------------------------

proc drawCurve =
  if showCurve:
    drawLineBezierCubic(startPosition, endPosition, startPositionTangent, endPositionTangent, 2, Blue)
  drawLine(startPosition, startPositionTangent, SkyBlue)
  drawLine(endPosition, endPositionTangent, Purple)
  let mouse = getMousePosition()
  if checkCollisionPointCircle(mouse, startPosition, 6):
    drawCircle(startPosition, 7, Yellow)
  drawCircle(startPosition, 5, Red)
  if checkCollisionPointCircle(mouse, startPositionTangent, 6):
    drawCircle(startPositionTangent, 7, Yellow)
  drawCircle(startPositionTangent, 5, Maroon)
  if checkCollisionPointCircle(mouse, endPosition, 6):
    drawCircle(endPosition, 7, Yellow)
  drawCircle(endPosition, 5, Green)
  if checkCollisionPointCircle(mouse, endPositionTangent, 6):
    drawCircle(endPositionTangent, 7, Yellow)
  drawCircle(endPositionTangent, 5, DarkGreen)

proc updateCurve =
  # If the mouse is not down, we are not editing the curve so clear the selection
  if not isMouseButtonDown(Left):
    selectedPoint = nil
    return
  if selectedPoint != nil:
    selectedPoint[] += getMouseDelta()
    return
  let mouse = getMousePosition()
  if checkCollisionPointCircle(mouse, startPosition, 6):
    selectedPoint = addr startPosition
  elif checkCollisionPointCircle(mouse, startPositionTangent, 6):
    selectedPoint = addr startPositionTangent
  elif checkCollisionPointCircle(mouse, endPosition, 6):
    selectedPoint = addr endPosition
  elif checkCollisionPointCircle(mouse, endPositionTangent, 6):
    selectedPoint = addr endPositionTangent

proc drawTexturedCurve =
  let step = 1'f32 / curveSegments.float32
  var previous = startPosition
  var previousTangent = Vector2()
  var previousV: float32 = 0
  # We can't compute a tangent for the first point, so we need to reuse the tangent from the first segment
  var tangentSet = false
  var current = Vector2()
  var t: float32 = 0
  for i in 1..curveSegments:
    # Segment the curve
    t = step * i.float32
    let a = pow(1 - t, 3)
    let b = 3 * pow(1 - t, 2) * t
    let c = 3 * (1 - t) * pow(t, 2)
    let d = pow(t, 3)
    # Compute the endpoint for this segment
    current.y = a*startPosition.y + b*startPositionTangent.y + c*endPositionTangent.y + d*endPosition.y
    current.x = a*startPosition.x + b*startPositionTangent.x + c*endPositionTangent.x + d*endPosition.x
    # Vector from previous to current
    let delta = Vector2(x: current.x - previous.x, y: current.y - previous.y)
    # The right hand normal to the delta vector
    let normal = normalize(Vector2(x: -delta.y, y: delta.x))
    # The v texture coordinate of the segment (add up the length of all the segments so far)
    let v = previousV + length(delta)
    # Make sure the start point has a normal
    if not tangentSet:
      previousTangent = normal
      tangentSet = true
    let prevPosNormal = previous + previousTangent * curveWidth.float32
    let prevNegNormal = previous + previousTangent * -curveWidth.float32
    let currentPosNormal = current + normal * curveWidth.float32
    let currentNegNormal = current + normal * -curveWidth.float32
    # Draw the segment as a quad
    setTexture(texRoad.id)
    rlBegin(Quads)
    color4ub(255, 255, 255, 255)
    normal3f(0, 0, 1)
    texCoord2f(0, previousV)
    vertex2f(prevNegNormal.x, prevNegNormal.y)
    texCoord2f(1, previousV)
    vertex2f(prevPosNormal.x, prevPosNormal.y)
    texCoord2f(1, v)
    vertex2f(currentPosNormal.x, currentPosNormal.y)
    texCoord2f(0, v)
    vertex2f(currentNegNormal.x, currentNegNormal.y)
    rlEnd()
    # The current step is the start of the next step
    previous = current
    previousTangent = normal
    previousV = v

proc updateOptions =
  if isKeyPressed(Space):
    showCurve = not showCurve
  # Update width
  if isKeyPressed(Equal):
    inc(curveWidth, 2)
  if isKeyPressed(Minus):
    dec(curveWidth, 2)
  if curveWidth < 2:
    curveWidth = 2
  # Update segments
  if isKeyPressed(Left):
    dec(curveSegments, 2)
  if isKeyPressed(Right):
    inc(curveSegments, 2)
  if curveSegments < 2:
    curveSegments = 2

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  setConfigFlags(flag(VsyncHint, Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib [textures] examples - textured curve")
  # Load the road texture
  texRoad = loadTexture("resources/road.png")
  setTextureFilter(texRoad, Bilinear)
  # Setup the curve
  startPosition = Vector2(x: 80, y: 100)
  startPositionTangent = Vector2(x: 180, y: 340)

  endPosition = Vector2(x: 700, y: 350)
  endPositionTangent = Vector2(x: 600, y: 110)

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateCurve()
    updateOptions()
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawTexturedCurve()
    drawCurve()
    drawText("Drag points to move curve, press SPACE to show/hide base curve", 10, 10, 10, DarkGray)
    drawText(&"Width {curveWidth} (Use + and - to adjust)", 10, 30, 10, DarkGray)
    drawText(&"Segments {curveSegments} (Use LEFT and RIGHT to adjust)", 10, 50, 10, DarkGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  reset(texRoad)
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
