# ****************************************************************************************
#
#   raylib [core] example - automation events
#
#   Example originally created with raylib 5.0, last time updated with raylib 5.0
#   Example based on 2d_camera_platformer example by arvyy (@arvyy)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2023 Ramon Santamaria (@raysan5)
#   Converted in 2023 by Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import std/[lenientops, strformat], raylib, raymath
from std/strutils import endsWith

const
  screenWidth = 800
  screenHeight = 450

  G = 400
  PlayerJumpSpd = 350
  PlayerHorSpd = 200

type
  Player = object
    position: Vector2
    speed: float32
    canJump: bool

  EnvItem = object
    rect: Rectangle
    blocking: bool
    color: Color

proc updatePlayer(player: var Player, envItems: openArray[EnvItem],
    delta: float32) =
  if isKeyDown(Left):
    player.position.x -= PlayerHorSpd * delta
  if isKeyDown(Right):
    player.position.x += PlayerJumpSpd * delta
  if isKeyDown(Space) and player.canJump:
    player.speed = -PlayerJumpSpd
    player.canJump = false
  var hitObstacle = false
  for i in 0 ..< envItems.len:
    let ei = envItems[i]
    let p = player.position
    if ei.blocking and ei.rect.x <= p.x and ei.rect.x + ei.rect.width >= p.x and
        ei.rect.y >= p.y and ei.rect.y <= p.y + player.speed * delta:
      hitObstacle = true
      player.speed = 0
      player.position.y = ei.rect.y
  if not hitObstacle:
    player.position.y += player.speed * delta
    player.speed += G * delta
    player.canJump = false
  else:
    player.canJump = true

proc updateCamera(camera: var Camera2D, player: Player,
                  envItems: openArray[EnvItem],
                  delta: float32, width: int32, height: int32) =
  camera.target = player.position
  camera.offset = Vector2(x: width / 2'f32, y: height / 2'f32)
  var
    minX: float32 = 1000
    minY: float32 = 1000
    maxX: float32 = -1000
    maxY: float32 = -1000
  for i in 0 ..< envItems.len:
    let ei = envItems[i]
    minX = min(ei.rect.x, minX)
    maxX = max(ei.rect.x + ei.rect.width, maxX)
    minY = min(ei.rect.y, minY)
    maxY = max(ei.rect.y + ei.rect.height, maxY)
  let
    maxV = getWorldToScreen2D(Vector2(x: maxX, y: maxY), camera)
    minV = getWorldToScreen2D(Vector2(x: minX, y: minY), camera)
  if maxV.x < width:
    camera.offset.x = width - (maxV.x - width / 2'f32)
  if maxV.y < height:
    camera.offset.y = height - (maxV.y - height / 2'f32)
  if minV.x > 0:
    camera.offset.x = width / 2'f32 - minV.x
  if minV.y > 0:
    camera.offset.y = height / 2'f32 - minV.y

proc main =
  initWindow(screenWidth, screenHeight, "raylib [core] example - automation events")
  var player = Player(
    position: Vector2(x: 400, y: 280),
    speed: 0,
    canJump: false
  )

  let envItems = [
    EnvItem(rect: Rectangle(x: 0, y: 0, width: 1000, height: 400),
      blocking: false,
      color: LightGray
    ),
    EnvItem(rect: Rectangle(x: 0, y: 400, width: 1000, height: 200),
      blocking: true,
      color: Gray
    ),
    EnvItem(rect: Rectangle(x: 300, y: 200, width: 400, height: 10),
      blocking: true,
      color: Gray
    ),
    EnvItem(rect: Rectangle(x: 250, y: 300, width: 100, height: 10),
      blocking: true,
      color: Gray
    ),
    EnvItem(rect: Rectangle(x: 650, y: 300, width: 100, height: 10),
      blocking: true,
      color: Gray
    ),
  ]

  var camera = Camera2D(
    target: player.position,
    offset: Vector2(x: screenWidth / 2'f32, y: screenHeight / 2'f32),
    rotation: 0,
    zoom: 1
  )

  # Automation events
  var aelist = loadAutomationEventList(nil)
  # Initialize list of automation events to record new events
  setAutomationEventList(aelist)
  var eventRecording = false
  var eventPlaying = false

  var frameCounter: uint32 = 0
  var playFrameCounter: uint32 = 0
  var currentPlayFrame = 0

  template resetScene() =
    player.position = Vector2(x: 400, y: 280)
    player.speed = 0
    player.canJump = false

    camera.target = player.position
    camera.offset = Vector2(x: screenWidth/2'f32, y: screenHeight/2'f32)
    camera.rotation = 0
    camera.zoom = 1

  setTargetFPS(60)
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ------------------------------------------------------------------------------------
    let deltaTime = getFrameTime() #: float32 = 0.015

    # Dropped files logic
    # ------------------------------------------------------------------------------------
    if isFileDropped():
      let droppedFiles = getDroppedFiles()
      # Supports loading .rgs style files (text or binary) and .png style palette images
      if droppedFiles[0].endsWith(".txt") or
          droppedFiles[0].endsWith(".rae"):
        aelist = loadAutomationEventList(droppedFiles[0])
        eventRecording = false
        # Reset scene state to play
        eventPlaying = true
        playFrameCounter = 0
        currentPlayFrame = 0
        resetScene()

    updatePlayer(player, envItems, deltaTime)
    camera.zoom += getMouseWheelMove()*0.05'f32
    if camera.zoom > 3:
      camera.zoom = 3.0
    elif camera.zoom < 0.25'f32:
      camera.zoom = 0.25
    if isKeyPressed(R):
      # Reset game tate
      resetScene()

    # Call update camera function
    updateCamera(camera, player, envItems,
        deltaTime, screenWidth, screenHeight)
    # ------------------------------------------------------------------------------------

    # Toggle events recording
    if isKeyPressed(S):
      if not eventPlaying:
        if eventRecording:
          stopAutomationEventRecording()
          eventRecording = false
          discard exportAutomationEventList(aelist, "automation.rae")
          traceLog(Info, &"RECORDED FRAMES: {aelist.len}")
        else:
          setAutomationEventBaseFrame(180)
          startAutomationEventRecording()
          eventRecording = true
    elif isKeyPressed(A):
      if not eventRecording and aelist.len > 0:
        # Reset scene state to play
        eventPlaying = true
        playFrameCounter = 0
        currentPlayFrame = 0
        resetScene()

    if eventPlaying:
      # NOTE: Multiple events could be executed in a single frame
      while playFrameCounter == aelist[currentPlayFrame].frame:
        traceLog(Info, "PLAYING: PlayFrameCount: %i | currentPlayFrame: %i | Event Frame: %i, param: %i",
                 playFrameCounter, currentPlayFrame,
                 aelist[currentPlayFrame].frame,
                 aelist[currentPlayFrame].params[0])
        playAutomationEvent(aelist[currentPlayFrame])
        inc(currentPlayFrame)
        if currentPlayFrame == aelist.len:
          eventPlaying = false
          currentPlayFrame = 0
          playFrameCounter = 0
          traceLog(Info, "FINISH PLAYING!")
          break
      inc(playFrameCounter)
    if eventRecording or eventPlaying:
      inc(frameCounter)
    else:
      frameCounter = 0

    # ------------------------------------------------------------------------------------

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(LightGray)

    beginMode2D(camera)
    for i in 0 ..< envItems.len:
      drawRectangle(envItems[i].rect, envItems[i].color)
    drawRectangle(Rectangle(
        x: player.position.x - 20,
        y: player.position.y - 40,
        width: 40,
        height: 40), Red)
    endMode2D()

    # Draw game controls
    drawRectangle(10, 10, 290, 145, fade(SkyBlue, 0.5))
    drawRectangleLines(10, 10, 290, 145, fade(Blue, 0.8))
    drawText("Controls:", 20, 20, 10, Black)
    drawText("- RIGHT | LEFT: Player movement", 30, 40, 10, DarkGray)
    drawText("- SPACE: Player jump", 30, 60, 10, DarkGray)
    drawText("- R: Reset game state", 30, 80, 10, DarkGray)
    drawText("- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, Black)
    drawText("- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, Black)
    # Draw automation events recording indicator
    if eventRecording:
      drawRectangle(10, 160, 290, 30, fade(Red, 0.3))
      drawRectangleLines(10, 160, 290, 30, fade(Maroon, 0.8))
      drawCircle(30, 175, 10, Maroon)
      if (frameCounter div 15) mod 2 == 1:
        drawText(&"RECORDING EVENTS... [{aelist.len}]", 50, 170, 10, Maroon)
    elif eventPlaying:
      drawRectangle(10, 160, 290, 30, fade(Lime, 0.3))
      drawRectangleLines(10, 160, 290, 30, fade(DarkGreen, 0.8))
      drawTriangle(Vector2(x: 20, y: 155 + 10), Vector2(x: 20, y: 155 + 30),
                   Vector2(x: 40, y: 155 + 20), DarkGreen)
      if (frameCounter div 15) mod 2 == 1:
        drawText(&"PLAYING RECORDED EVENTS... [{currentPlayFrame}]", 50, 170, 10, DarkGreen)
    endDrawing()
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
