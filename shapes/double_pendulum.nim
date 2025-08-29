# ****************************************************************************************
#
#   raylib [shapes] example - Double Pendulum
#
#   Example complexity rating: [★★☆☆] 2/4
#
#   Example originally created with raylib 5.5, last time updated with raylib 5.5
#
#   Example contributed by JoeCheong (@Joecheong2006) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2025 JoeCheong (@Joecheong2006)
#
# ****************************************************************************************

import raylib, std/[math, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450
  SimulationSteps = 30
  G = 9.81'f32

proc calculatePendulumEndPoint(l, theta: float32): Vector2 =
  result = Vector2(x: 10*l*sin(theta), y: 10*l*cos(theta))

proc calculateDoublePendulumEndPoint(l1, theta1, l2, theta2: float32): Vector2 =
  let endpoint1 = calculatePendulumEndPoint(l1, theta1)
  let endpoint2 = calculatePendulumEndPoint(l2, theta2)
  result = Vector2(x: endpoint1.x + endpoint2.x, y: endpoint1.y + endpoint2.y)

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  setConfigFlags(flags(WindowHighdpi))
  initWindow(ScreenWidth, ScreenHeight, "raylib [shapes] example - double pendulum")
  defer: closeWindow() # Important pattern in naylib

  # Simulation Parameters
  var 
    l1 = 15.0'f32
    m1 = 0.2'f32
    theta1 = degToRad(170.0'f32)
    w1 = 0.0'f32
    l2 = 15.0'f32
    m2 = 0.1'f32
    theta2 = degToRad(0.0'f32)
    w2 = 0.0'f32
    lengthScaler = 0.1'f32
    totalM = m1 + m2

  var previousPosition = calculateDoublePendulumEndPoint(l1, theta1, l2, theta2)
  previousPosition.x += ScreenWidth/2'f32
  previousPosition.y += ScreenHeight/2'f32 - 100

  # Scale length
  let L1 = l1*lengthScaler
  let L2 = l2*lengthScaler

  # Draw parameters
  let lineThick: int32 = 20
  let trailThick: int32 = 2
  let fateAlpha = 0.01'f32

  # Create framebuffer
  var target = loadRenderTexture(ScreenWidth, ScreenHeight)
  setTextureFilter(target.texture, Bilinear)

  setTargetFPS(60)
  # --------------------------------------------------------------------------------------

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime()
    let step = dt/SimulationSteps
    let step2 = step*step

    # Update Physics - larger steps = better approximation
    for i in 0..<SimulationSteps:
      let 
        delta = theta1 - theta2
        sinD = sin(delta)
        cosD = cos(delta)
        cos2D = cos(2*delta)
        ww1 = w1*w1
        ww2 = w2*w2

      # Calculate a1
      let a1 = (-G*(2*m1 + m2)*sin(theta1) -
                m2*G*sin(theta1 - 2*theta2) -
                2*sinD*m2*(ww2*L2 + ww1*L1*cosD)) /
               (L1*(2*m1 + m2 - m2*cos2D))

      # Calculate a2
      let a2 = (2*sinD*(ww1*L1*totalM +
                G*totalM*cos(theta1) +
                ww2*L2*m2*cosD)) /
               (L2*(2*m1 + m2 - m2*cos2D))

      # Update thetas
      theta1 += w1*step + 0.5'f32*a1*step2
      theta2 += w2*step + 0.5'f32*a2*step2

      # Update omegas
      w1 += a1*step
      w2 += a2*step

    # Calculate position
    var currentPosition = calculateDoublePendulumEndPoint(l1, theta1, l2, theta2)
    currentPosition.x += ScreenWidth/2'f32
    currentPosition.y += ScreenHeight/2'f32 - 100

    # Draw to render texture
    textureMode(target):
      # Draw a transparent rectangle - smaller alpha = longer trails
      drawRectangle(0, 0, ScreenWidth, ScreenHeight, fade(Black, fateAlpha))

      # Draw trail
      drawCircle(previousPosition, trailThick.float32, Red)
      drawLine(previousPosition, currentPosition, trailThick.float32*2, Red)

    # Update previous position
    previousPosition = currentPosition
    # ----------------------------------------------------------------------------------

    # Draw
    # ----------------------------------------------------------------------------------
    drawing():
      clearBackground(Black)

      # Draw trails texture
      drawTexture(target.texture, Rectangle(x: 0, y: 0, width: target.texture.width.float32, 
                  height: -target.texture.height.float32), Vector2(x: 0, y: 0), White)

      # Draw double pendulum
      drawRectangle(Rectangle(x: ScreenWidth/2'f32, y: ScreenHeight/2'f32 - 100, width: 10*l1, height: lineThick.float32), 
                    Vector2(x: 0, y: lineThick*0.5'f32), 90 - radToDeg(theta1), RayWhite)

      let endpoint1 = calculatePendulumEndPoint(l1, theta1)
      drawRectangle(Rectangle(x: ScreenWidth/2'f32 + endpoint1.x, y: ScreenHeight/2'f32 - 100 + endpoint1.y,
                    width: 10*l2, height: lineThick.float32), Vector2(x: 0, y: lineThick*0.5'f32), 90 - radToDeg(theta2), RayWhite)
    # ----------------------------------------------------------------------------------

main()
