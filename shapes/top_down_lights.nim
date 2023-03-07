# ****************************************************************************************
#
#   raylib [shapes] example - top down lights
#
#   Example originally created with raylib 4.2, last time updated with raylib 4.2
#
#   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2022-2023 Jeffery Myers (@JeffM2501)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib, raymath, rlgl, std/random

const
  MaxBoxes = 20
  MaxShadows = MaxBoxes*3 # Each box can cast up to two shadow volumes for the edges it is away from, and one for the box itself
  MaxLights = 16

type
  ShadowGeometry = object # Shadow geometry type
    vertices: array[4, Vector2]

type
  LightInfo = object # Light info type
    active: bool # Is this light slot active?
    dirty: bool # Does this light need to be updated?
    valid: bool # Is this light in a valid position?
    position: Vector2 # Light position
    mask: RenderTexture # Alpha mask for the light
    outerRadius: float32 # The distance the light touches
    bounds: Rectangle # A cached rectangle of the light bounds to help with culling
    shadows: array[MaxShadows, ShadowGeometry]
    shadowCount: int32

var lights: array[MaxLights, LightInfo]

proc moveLight(slot: int32; x, y: float32) =
  # Move a light and mark it as dirty so that we update it's mask next frame
  lights[slot].dirty = true
  lights[slot].position.x = x
  lights[slot].position.y = y
  # update the cached bounds
  lights[slot].bounds.x = x - lights[slot].outerRadius
  lights[slot].bounds.y = y - lights[slot].outerRadius

proc computeShadowVolumeForEdge(slot: int32; sp, ep: Vector2) =
  # Compute a shadow volume for the edge
  # It takes the edge and projects it back by the light radius and turns it into a quad
  if lights[slot].shadowCount >= MaxShadows: return
  let extension = lights[slot].outerRadius*2
  let spVector = normalize(sp - lights[slot].position)
  let spProjection = sp + spVector*extension
  let epVector = normalize(ep - lights[slot].position)
  let epProjection = ep + epVector*extension
  lights[slot].shadows[lights[slot].shadowCount].vertices[0] = sp
  lights[slot].shadows[lights[slot].shadowCount].vertices[1] = ep
  lights[slot].shadows[lights[slot].shadowCount].vertices[2] = epProjection
  lights[slot].shadows[lights[slot].shadowCount].vertices[3] = spProjection
  inc(lights[slot].shadowCount)

proc drawLightMask(slot: int32) =
  # Draw the light and shadows to the mask for a light
  # Use the light mask
  beginTextureMode(lights[slot].mask)
  clearBackground(White)
  # Force the blend mode to only set the alpha of the destination
  setBlendFactors(SrcAlpha, SrcAlpha, Min)
  setBlendMode(Custom)
  # If we are valid, then draw the light radius to the alpha mask
  if lights[slot].valid:
    drawCircleGradient(lights[slot].position.x.int32, lights[slot].position.y.int32,
        lights[slot].outerRadius, colorAlpha(White, 0), White)
  drawRenderBatchActive()
  # Cut out the shadows from the light radius by forcing the alpha to maximum
  setBlendMode(Alpha)
  setBlendFactors(SrcAlpha, SrcAlpha, Max)
  setBlendMode(Custom)
  # Draw the shadows to the alpha mask
  for i in 0..<lights[slot].shadowCount:
    drawTriangleFan(lights[slot].shadows[i].vertices, White)
  drawRenderBatchActive()
  # Go back to normal blend mode
  setBlendMode(Alpha)
  endTextureMode()

proc setupLight(slot: int32; x, y, radius: float32) =
  # Setup a light
  lights[slot].active = true
  lights[slot].valid = false
  # The light must prove it is valid
  lights[slot].mask = loadRenderTexture(getScreenWidth(), getScreenHeight())
  lights[slot].outerRadius = radius
  lights[slot].bounds.width = radius*2
  lights[slot].bounds.height = radius*2
  moveLight(slot, x, y)
  # Force the render texture to have something in it
  drawLightMask(slot)

proc updateLight(slot: int32; boxes: var openArray[Rectangle]): bool =
  # See if a light needs to update it's mask
  if not lights[slot].active or not lights[slot].dirty: return false
  lights[slot].dirty = false
  lights[slot].shadowCount = 0
  lights[slot].valid = false
  for i in 0..boxes.high:
    # Are we in a box? if so we are not valid
    if checkCollisionPointRec(lights[slot].position, boxes[i]): return false
    if not checkCollisionRecs(lights[slot].bounds, boxes[i]): continue
    var sp = Vector2(x: boxes[i].x, y: boxes[i].y)
    var ep = Vector2(x: boxes[i].x + boxes[i].width, y: boxes[i].y)
    if lights[slot].position.y > ep.y:
      computeShadowVolumeForEdge(slot, sp, ep)
    sp = ep
    ep.y += boxes[i].height
    if lights[slot].position.x < ep.x:
      computeShadowVolumeForEdge(slot, sp, ep)
    sp = ep
    ep.x -= boxes[i].width
    if lights[slot].position.y < ep.y:
      computeShadowVolumeForEdge(slot, sp, ep)
    sp = ep
    ep.y -= boxes[i].height
    if lights[slot].position.x > ep.x:
      computeShadowVolumeForEdge(slot, sp, ep)
    lights[slot].shadows[lights[slot].shadowCount].vertices[0] = Vector2(x: boxes[i].x, y: boxes[i].y)
    lights[slot].shadows[lights[slot].shadowCount].vertices[1] = Vector2(x: boxes[i].x, y: boxes[i].y + boxes[i].height)
    lights[slot].shadows[lights[slot].shadowCount].vertices[2] = Vector2(x: boxes[i].x + boxes[i].width, y: boxes[i].y + boxes[i].height)
    lights[slot].shadows[lights[slot].shadowCount].vertices[3] = Vector2(x: boxes[i].x + boxes[i].width, y: boxes[i].y)
    inc(lights[slot].shadowCount)
  lights[slot].valid = true
  drawLightMask(slot)
  result = true

proc setupBoxes(boxes: var openArray[Rectangle]) =
  # Set up some boxes:
  boxes[0] = Rectangle(x: 150, y: 80, width: 40, height: 40)
  boxes[1] = Rectangle(x: 1200, y: 700, width: 40, height: 40)
  boxes[2] = Rectangle(x: 200, y: 600, width: 40, height: 40)
  boxes[3] = Rectangle(x: 1000, y: 50, width: 40, height: 40)
  boxes[4] = Rectangle(x: 500, y: 350, width: 40, height: 40)
  for i in 5..<MaxBoxes:
    boxes[i] = Rectangle(
      x: rand(0..getScreenWidth().int).float32,
      y: rand(0..getScreenHeight().int).float32,
      width: rand(10..100).float32,
      height: rand(10..100).float32
    )

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shapes] example - top down lights")
  defer: closeWindow() # Close window and OpenGL context
  # Initialize our 'world' of boxes
  var boxes: array[MaxBoxes, Rectangle]
  setupBoxes(boxes)
  # Create a checkerboard ground texture
  var img = genImageChecked(64, 64, 32, 32, DarkBrown, DarkGray)
  var backgroundTexture = loadTextureFromImage(img)
  reset(img)
  # Create a global light mask to hold all the blended lights
  var lightMask = loadRenderTexture(getScreenWidth(), getScreenHeight())
  # Setup initial light
  setupLight(0, 600, 400, 300)
  var nextLight: int32 = 1
  var showLines: bool = false
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Drag light 0
    if isMouseButtonDown(Left):
      moveLight(0, getMousePosition().x, getMousePosition().y)
    if isMouseButtonPressed(Right) and nextLight < MaxLights:
      setupLight(nextLight, getMousePosition().x, getMousePosition().y, 200)
      inc(nextLight)
    if isKeyPressed(F1):
      showLines = not showLines
    var dirtyLights: bool = false
    for i in 0..<MaxLights:
      if updateLight(i.int32, boxes):
        dirtyLights = true
    # Update the light mask
    if dirtyLights:
      # Build up the light mask
      beginTextureMode(lightMask)
      clearBackground(Black)
      # Force the blend mode to only set the alpha of the destination
      setBlendFactors(SrcAlpha, SrcAlpha, Min)
      setBlendMode(Custom)
      # Merge in all the light masks
      for i in 0..<MaxLights:
        if lights[i].active:
          drawTexture(lights[i].mask.texture,
              Rectangle(x: 0, y: 0, width: getScreenWidth().float32, height: -getScreenHeight().float32),
              vector2Zero(), White)
      drawRenderBatchActive()
      # Go back to normal blend
      setBlendMode(Alpha)
      endTextureMode()
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)
    # Draw the tile background
    drawTexture(backgroundTexture,
        Rectangle(x: 0, y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32),
        vector2Zero(), White)
    # Overlay the shadows from all the lights
    drawTexture(lightMask.texture,
        Rectangle(x: 0, y: 0, width: getScreenWidth().float32, height: -getScreenHeight().float32),
        vector2Zero(), colorAlpha(White, if showLines: 0.75'f32 else: 1.0'f32))
    # Draw the lights
    for i in 0..<MaxLights:
      if lights[i].active:
        drawCircle(lights[i].position.x.int32, lights[i].position.y.int32, 10,
            if i == 0: Yellow else: White)
    if showLines:
      for s in 0..<lights[0].shadowCount:
        drawTriangleFan(lights[0].shadows[s].vertices, DarkPurple)
      for b in 0..boxes.high:
        if checkCollisionRecs(boxes[b], lights[0].bounds):
          drawRectangle(boxes[b], Purple)
        drawRectangleLines(boxes[b].x.int32, boxes[b].y.int32, boxes[b].width.int32,
            boxes[b].height.int32, DarkBlue)
      drawText("(F1) Hide Shadow Volumes", 10, 50, 10, Green)
    else:
      drawText("(F1) Show Shadow Volumes", 10, 50, 10, Green)
    drawFPS(screenWidth - 80, 10)
    drawText("Drag to move light #1", 10, 10, 10, DarkGreen)
    drawText("Right click to add new light", 10, 30, 10, DarkGreen)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  for i in 0..<MaxLights:
    if lights[i].active: reset(lights[i].mask)

main()
