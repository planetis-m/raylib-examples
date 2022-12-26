# ****************************************************************************************
#
#   raylib - classic game: floppy
#
#   Sample game developed by Ian Eito, Albert Martos and Ramon Santamaria
#
#   This game has been created using raylib v1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************
import raylib, std/[lenientops, random, strformat]

# ----------------------------------------------------------------------------------------
# Some Defines
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

  MaxTubes = 100
  FloppyRadius = 24
  TubeWidth = 80

# ----------------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------------

type
  Floppy = object
    position: Vector2
    radius: int32
    color: Color

  Tube = object
    rec: Rectangle
    color: Color
    active: bool

# ----------------------------------------------------------------------------------------
#  Global Variables Declaration
# ----------------------------------------------------------------------------------------

var
  gameOver = false
  pause = false
  score: int32 = 0
  hiScore: int32 = 0
  floppy: Floppy
  tubes: array[MaxTubes*2, Tube]
  tubesPos: array[MaxTubes, Vector2]
  tubesSpeedX: int32 = 0
  superfx = false

# ----------------------------------------------------------------------------------------
#  Module Functions Definitions (local)
# ----------------------------------------------------------------------------------------

proc initGame =
  # Initialize game variables
  floppy.radius = FloppyRadius
  floppy.position = Vector2(x: 80, y: screenHeight/2'f32 - floppy.radius)
  tubesSpeedX = 2
  for i in 0..<MaxTubes:
    tubesPos[i] = Vector2(x: float32(400 + 280*i), y: -rand(0..120).float32)
  for i in countup(0, MaxTubes*2 - 1, 2):
    tubes[i] = Tube(
      rec: Rectangle(x: tubesPos[i div 2].x, y: tubesPos[i div 2].y, width: TubeWidth, height: 255)
    )
    tubes[i + 1] = Tube(
      rec: Rectangle(x: tubesPos[i div 2].x, y: 600 + tubesPos[i div 2].y - 255, width: TubeWidth, height: 255)
    )
    tubes[i div 2].active = true
  score = 0
  gameOver = false
  superfx = false
  pause = false

proc updateGame =
  # Update game (one frame)
  if not gameOver:
    if isKeyPressed(P):
      pause = not pause
    if not pause:
      for i in 0..<MaxTubes:
        tubesPos[i].x -= tubesSpeedX.float32
      for i in countup(0, MaxTubes*2 - 1, 2):
        tubes[i].rec.x = tubesPos[i div 2].x
        tubes[i + 1].rec.x = tubesPos[i div 2].x
      if isKeyDown(Space) and not gameOver:
        floppy.position.y -= 3
      else:
        floppy.position.y += 1
      # Check Collisions
      for i in 0..<MaxTubes*2:
        if checkCollisionCircleRec(floppy.position, floppy.radius.float32, tubes[i].rec):
          gameOver = true
          pause = false
        elif tubesPos[i div 2].x < floppy.position.x and tubes[i div 2].active and
            not gameOver:
          inc(score, 100)
          tubes[i div 2].active = false
          superfx = true
          if score > hiScore:
            hiScore = score
  else:
    if isKeyPressed(Enter):
      initGame()
      gameOver = false

proc drawGame =
  # Draw game (one frame)
  beginDrawing()
  clearBackground(RayWhite)
  if not gameOver:
    drawCircle(floppy.position, floppy.radius.float32, DarkGray)
    ##  Draw tubes
    for i in 0..<MaxTubes:
      drawRectangle(tubes[i*2].rec, Gray)
      drawRectangle(tubes[i*2 + 1].rec, Gray)
    # Draw flashing fx (one frame only)
    if superfx:
      drawRectangle(0, 0, screenWidth, screenHeight, White)
      superfx = false
    drawText(&"{score:04d}", 20, 20, 40, Gray)
    drawText(&"HI-SCORE: {hiScore:04d}", 20, 70, 20, LightGray)
    if pause:
      drawText("GAME PAUSED", screenWidth div 2 - measureText("GAME PAUSED", 40) div 2,
          screenHeight div 2 - 40, 40, Gray)
  else:
    drawText("PRESS [ENTER] TO PLAY AGAIN", getScreenWidth() div 2 -
        measureText("PRESS [ENTER] TO PLAY AGAIN", 20) div 2,
        getScreenHeight() div 2 - 50, 20, Gray)
  endDrawing()

proc unloadGame =
  # Unload game variables
  # TODO: Unload all dynamic loaded data (textures, sounds, models...)
  discard

proc updateDrawFrame {.cdecl.} =
  # Update and Draw (one frame)
  updateGame()
  drawGame()

# ----------------------------------------------------------------------------------------
#  Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "classic game: floppy")
  try:
    initGame()
    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 60, 1)
    else:
      setTargetFPS(60)
      # ----------------------------------------------------------------------------------
      # Main game loop
      while not windowShouldClose(): # Detect window close button or ESC key
        # Update and Draw
        # --------------------------------------------------------------------------------
        updateDrawFrame()
        # --------------------------------------------------------------------------------
    # De-Initialization
    # ------------------------------------------------------------------------------------
    unloadGame() # Unload loaded data (textures, sounds, models...)
  finally:
    closeWindow() # Close window and OpenGL context

main()
