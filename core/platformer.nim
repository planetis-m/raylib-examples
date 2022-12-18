# ***************************************************************************************
#
# raylib [core] example - 2d camera platformer
#
# This example has been created using raylib 2.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2019 arvyy (@arvyy)
# Converted in 2021 by greenfork
#
# ***************************************************************************************

import std/lenientops, raylib, raymath

const
  screenWidth = 800
  screenHeight = 450

const
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
  if isKeyDown(KeyLeft):
    player.position.x -= PlayerHorSpd * delta
  if isKeyDown(KeyRight):
    player.position.x += PlayerJumpSpd * delta
  if isKeyDown(KeySpace) and player.canJump:
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

proc updateCameraCenter(camera: var Camera2D, player: Player,
                        envItems: openArray[EnvItem], delta: float32,
                        width: int32, height: int32) =
  camera.offset = Vector2(x: width / 2'f32, y: height / 2'f32)
  camera.target = player.position

proc updateCameraCenterInsideMap(camera: var Camera2D, player: Player,
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

proc updateCameraCenterSmoothFollow(camera: var Camera2D, player: Player,
                                    envItems: openArray[EnvItem],
                                    delta: float32, width: int32, height: int32) =
  let minSpeed: float32 = 30
  let minEffectLength: float32 = 10
  let fractionSpeed: float32 = 0.8
  camera.offset = Vector2(x: width / 2'f32, y: height / 2'f32)
  let diff = player.position - camera.target
  let length = length(diff)
  if length > minEffectLength:
    let speed = max(fractionSpeed * length, minSpeed)
    camera.target = camera.target + diff * (speed * delta / length)

var eveningOut = false
var evenOutTarget: float32 = 0
proc updateCameraEvenOutOnLanding(camera: var Camera2D, player: Player,
                                  envItems: openArray[EnvItem],
                                  delta: float32, width: int32, height: int32) =
  let evenOutSpeed: float32 = 700
  camera.offset = Vector2(x: width / 2'f32, y: height / 2'f32)
  camera.target.x = player.position.x
  if eveningOut:
    if evenOutTarget > camera.target.y:
      camera.target.y += evenOutSpeed * delta
      if camera.target.y > evenOutTarget:
        camera.target.y = evenOutTarget
        eveningOut = false
    else:
      camera.target.y -= evenOutSpeed * delta
      if camera.target.y < evenOutTarget:
        camera.target.y = evenOutTarget
        eveningOut = false
  else:
    if player.canJump and player.speed == 0 and
        player.position.y != camera.target.y:
      eveningOut = true
      evenOutTarget = player.position.y

proc updateCameraPlayerBoundsPush(camera: var Camera2D, player: Player,
                                  envItems: openArray[EnvItem],
                                  delta: float32, width: int32, height: int32) =
  let
    bbox = Vector2(x: 0.2, y: 0.2)
    bboxWorldMin = getScreenToWorld2D(
      Vector2(x: (1 - bbox.x) * 0.5'f32 * width, y: (1 - bbox.y) * 0.5'f32 * height),
      camera
    )
    bboxWorldMax = getScreenToWorld2D(
      Vector2(x: (1 + bbox.x) * 0.5'f32 * width, y: (1 + bbox.y) * 0.5'f32 * height),
      camera
    )
  camera.offset = Vector2(x: (1 - bbox.x) * 0.5'f32 * width, y: (1 -
      bbox.y) * 0.5'f32 * height)
  if player.position.x < bboxWorldMin.x:
    camera.target.x = player.position.x
  if player.position.y < bboxWorldMin.y:
    camera.target.y = player.position.y
  if player.position.x > bboxWorldMax.x:
    camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x)
  if player.position.y > bboxWorldMax.y:
    camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y)

proc main =
  initWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")
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
  # Store pointers to the multiple update camera functions
  let cameraUpdaters = [
    updateCameraCenter,
    updateCameraCenterInsideMap,
    updateCameraCenterSmoothFollow,
    updateCameraEvenOutOnLanding,
    updateCameraPlayerBoundsPush
  ]
  var cameraOption = 0
  let cameraDescriptions = [
    "Follow player center",
    "Follow player center, but clamp to map edges",
    "Follow player center; smoothed",
    "Follow player center horizontally; updateplayer center vertically after landing",
    "Player push camera on getting too close to screen edge"
  ]
  setTargetFPS(60)
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # -----------------------------------------------------------------------------------
    let deltaTime = getFrameTime()
    updatePlayer(player, envItems, deltaTime)
    camera.zoom += getMouseWheelMove() * 0.05'f32
    if camera.zoom > 3:
      camera.zoom = 3.0
    elif camera.zoom < 0.25'f32:
      camera.zoom = 0.25
    if isKeyPressed(KeyR):
      camera.zoom = 1.0
      player.position = Vector2(x: 400, y: 280)
    if isKeyPressed(KeyC):
      cameraOption = (cameraOption + 1) mod cameraUpdaters.len
    # Call update camera function by its pointer
    cameraUpdaters[cameraOption](camera, player, envItems,
        deltaTime, screenWidth, screenHeight)
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(LightGray)
    beginMode2D(camera)
    for i in 0 ..< envItems.len:
      drawRectangle(envItems[i].rect, envItems[i].color)
    let playerRect = Rectangle(
      x: player.position.x - 20,
      y: player.position.y - 40,
      width: 40,
      height: 40
    )
    drawRectangle(playerRect, Red)
    endMode2D()
    drawText("Controls:", 20, 20, 10, Black)
    drawText("- Right/Left to move", 40, 40, 10, DarkGray)
    drawText("- Space to jump", 40, 60, 10, DarkGray)
    drawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, DarkGray)
    drawText("- C to change camera mode", 40, 100, 10, DarkGray)
    drawText("Current camera mode:", 20, 120, 10, Black)
    drawText(cameraDescriptions[cameraOption], 40, 140, 10, DarkGray)
    endDrawing()
  # De-Initialization
  # -------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
