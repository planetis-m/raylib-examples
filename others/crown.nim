# Developed in 2021 by greenfork
# Reviewed in 2023 by planetis-m

import std/math, raylib

const
  nimFg = getColor(0xffc200ff'u32)
  nimBg = getColor(0x17181fff'u32)

# Let's draw a Nim crown!
const
  crownSides = 8                                # Low-polygon version
  centerAngle: float32 = Tau/crownSides         # Angle from the center of a circle
  lowerRadius: float32 = 2                      # Lower crown circle
  upperRadius: float32 = lowerRadius*1.4        # Upper crown circle
  mainHeight: float32 = lowerRadius*0.8         # Height without teeth
  toothHeight: float32 = mainHeight*1.3         # Height with teeth
  toothSkew: float32 = 1.2                      # Little angle for teeth

proc main =
  var
    lowerPoints, upperPoints: array[crownSides, Vector2]

  # Get evenly spaced points on the lower and upper circles,
  # use Nim's math module for that
  for i in 0..<crownSides:
    # Formulas are for 2D space, good enough for 3D since height is always same
    lowerPoints[i] = Vector2(
      x: lowerRadius*cos(centerAngle*i.float32),
      y: lowerRadius*sin(centerAngle*i.float32)
    )
    upperPoints[i] = Vector2(
      x: upperRadius*cos(centerAngle*i.float32),
      y: upperRadius*sin(centerAngle*i.float32)
    )

  initWindow(800, 450, "Nim Crown")  # Open window

  var camera = Camera(
    position: Vector3(x: 5, y: 5, z: 10),  # Camera position
    target: Vector3(x: 0, y: 0, z: 0),     # Camera target it looks-at
    up: Vector3(x: 0, y: 1, z: 0),         # Camera up vector (rotation over its axis)
    fovy: 45,                              # Camera field-of-view apperture in Y (degrees)
    projection: Perspective                # Defines projection type, see CameraProjection
  )
  var pause = false                 # Pausing the game will stop animation

  setTargetFPS(60)                  # Set the game to run at 60 frames per second

  # Wait for Esc key press or when the window is closed
  while not windowShouldClose():
    if not pause:
      updateCamera(camera, Orbital) # Set an orbital camera mode

    if isKeyPressed(Space) or
        isGestureDetected(Tap):     # Pressing Space will stop/resume animation
      pause = not pause

    drawing():                      # Use drawing functions inside this block
      clearBackground(RayWhite)     # Set background color

      mode3D(camera):               # Use 3D drawing functions inside this block
        drawGrid(10, 1)

        for i in 0..<crownSides:
          # Define 5 points:
          # - Current lower circle point
          # - Current upper circle point
          # - Next lower circle point
          # - Next upper circle point
          # - Point for peak of crown tooth
          let
            nexti = if i == crownSides - 1: 0 else: i + 1
            lowerCur = Vector3(x: lowerPoints[i].x, y: 0, z: lowerPoints[i].y)
            upperCur = Vector3(x: upperPoints[i].x, y: mainHeight, z: upperPoints[i].y)
            lowerNext = Vector3(x: lowerPoints[nexti].x, y: 0, z: lowerPoints[nexti].y)
            upperNext = Vector3(x: upperPoints[nexti].x, y: mainHeight, z: upperPoints[nexti].y)
            tooth = Vector3(
              x: (upperCur.x + upperNext.x)/2*toothSkew,
              y: toothHeight,
              z: (upperCur.z + upperNext.z)/2*toothSkew
            )

          # Front polygon (clockwise order)
          drawTriangle3D(lowerCur, upperCur, upperNext, nimFg)
          drawTriangle3D(lowerCur, upperNext, lowerNext, nimFg)

          # Back polygon (counter-clockwise order)
          drawTriangle3D(lowerCur, upperNext, upperCur, nimBg)
          drawTriangle3D(lowerCur, lowerNext, upperNext, nimBg)

          # Wire line for polygons
          drawLine3D(lowerCur, upperCur, Gray)

          # Crown tooth front triangle (clockwise order)
          drawTriangle3D(upperCur, tooth, upperNext, nimFg)

          # Crown tooth back triangle (counter-clockwise order)
          drawTriangle3D(upperNext, tooth, upperCur, nimBg)

      let
        text = "I AM NIM"
        fontSize: int32 = 60
        textWidth = measureText(text, fontSize)
        verticalPos = int32(getScreenHeight().float32*0.4'f32)
      drawText(text, (getScreenWidth() - textWidth) div 2,  # center
          (getScreenHeight() + verticalPos) div 2, fontSize, Black)
      drawText(if pause: "Press Space or tap to continue"
          else: "Press Space or tap to pause", 10, 10, 20, Black)

  closeWindow()

main()
