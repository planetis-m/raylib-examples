# ****************************************************************************************
#
#   raylib [textures] example - particles blending
#
#   Example complexity rating: [★☆☆☆] 1/4
#
#   Example originally created with raylib 1.7, last time updated with raylib 3.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2017-2025 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, std/[random, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450

  MaxParticles = 200

# Particle structure with basic data
type
  Particle = object
    position: Vector2
    color: Color
    alpha: float32
    size: float32
    rotation: float32
    active: bool # NOTE: Use it to activate/deactive particle

proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [textures] example - particles blending")
  defer: closeWindow() # Important pattern in naylib

  randomize() # Initialize random number generator

  # Particles pool, reuse them!
  var mouseTail = default array[MaxParticles, Particle]

  # Initialize particles
  for i in 0..<MaxParticles:
    mouseTail[i] = Particle(
      position: Vector2(x: 0, y: 0),
      color: Color(
        r: uint8(rand(0..255)),
        g: uint8(rand(0..255)),
        b: uint8(rand(0..255)),
        a: 255
      ),
      alpha: 1,
      size: float32(rand(1..30))/20,
      rotation: float32(rand(0..360)),
      active: false
    )

  let gravity: float32 = 3
  let smoke = loadTexture("resources/spark_flame.png")

  var blending = Alpha

  setTargetFPS(60)

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # Activate one particle every frame and Update active particles
    # NOTE: Particles initial position should be mouse position when activated
    # NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
    # NOTE: When a particle disappears, active = false and it can be reused
    for i in 0..<MaxParticles:
      if not mouseTail[i].active:
        mouseTail[i].active = true
        mouseTail[i].alpha = 1
        mouseTail[i].position = getMousePosition()
        break

    for i in 0..<MaxParticles:
      if mouseTail[i].active:
        mouseTail[i].position.y += gravity/2
        mouseTail[i].alpha -= 0.005'f32

        if mouseTail[i].alpha <= 0:
          mouseTail[i].active = false

        mouseTail[i].rotation += 2

    if isKeyPressed(Space):
      if blending == Alpha:
        blending = Additive
      else:
        blending = Alpha

    # Draw
    drawing():
      clearBackground(DarkGray)

      blendMode(blending):
        # Draw active particles
        for i in 0..<MaxParticles:
          if mouseTail[i].active:
            drawTexture(
              smoke,
              Rectangle(x: 0, y: 0, width: float32(smoke.width), height: float32(smoke.height)),
              Rectangle(
                x: mouseTail[i].position.x,
                y: mouseTail[i].position.y,
                width: smoke.width * mouseTail[i].size,
                height: smoke.height * mouseTail[i].size
              ),
              Vector2(
                x: smoke.width * mouseTail[i].size/2,
                y: smoke.height * mouseTail[i].size/2
              ),
              mouseTail[i].rotation,
              fade(mouseTail[i].color, mouseTail[i].alpha)
            )

      drawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, Black)

      if blending == Alpha:
        drawText("ALPHA BLENDING", 290, ScreenHeight - 40, 20, Black)
      else:
        drawText("ADDITIVE BLENDING", 280, ScreenHeight - 40, 20, RayWhite)

main()
