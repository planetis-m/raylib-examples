# ****************************************************************************************
#
#   raylib [shapes] example - fancy clock using basic shapes
#
#   Example complexity rating: [★★☆☆] 2/4
#
#   Example originally created with raylib 5.5, last time updated with raylib 5.5
#
#   Example contributed by Hamza RAHAL (@hmz-rhl) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2025 Hamza RAHAL (@hmz-rhl)
#
# ****************************************************************************************

import raylib, std/[math, times]

const
  DigitSize = 30
  ScreenWidth = 800
  ScreenHeight = 450

# ----------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------
type
  ClockMode = enum
    ModeNormal = 0
    ModeHandsFree

  ClockHand = object
    value: int32
    origin: Vector2
    angle: float32
    length: int32
    thickness: int32
    color: Color

  Clock = object
    mode: ClockMode
    second: ClockHand
    minute: ClockHand
    hour: ClockHand

# ----------------------------------------------------------------------------------
# Module Functions Declaration
# ----------------------------------------------------------------------------------
proc updateClock(clock: var Clock) # Update clock time
proc drawClock(clock: Clock, centerPosition: Vector2) # Draw clock at desired position

# ------------------------------------------------------------------------------------
# Program main entry point
# ------------------------------------------------------------------------------------
proc main() =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(ScreenWidth, ScreenHeight, "raylib [shapes] example - digital clock")
  defer: closeWindow() # Important pattern in naylib

  # Initialize clock
  var myClock = Clock(
    mode: ModeNormal,

    second: ClockHand(
      angle: 45,
      length: 140,
      thickness: 3,
      color: Beige,
      value: 0,
      origin: Vector2(x: 0, y: 0)
    ),

    minute: ClockHand(
      angle: 10,
      length: 130,
      thickness: 7,
      color: DarkGray,
      value: 0,
      origin: Vector2(x: 0, y: 0)
    ),

    hour: ClockHand(
      angle: 0,
      length: 100,
      thickness: 7,
      color: Black,
      value: 0,
      origin: Vector2(x: 0, y: 0)
    )
  )

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(Space):
      if myClock.mode == ModeHandsFree:
        myClock.mode = ModeNormal
      elif myClock.mode == ModeNormal:
        myClock.mode = ModeHandsFree

    updateClock(myClock)
    # ----------------------------------------------------------------------------------

    # Draw
    # ----------------------------------------------------------------------------------
    drawing():
      clearBackground(RayWhite)
      drawCircle(400, 225, 5, Black) # Clock center dot
      drawClock(myClock, Vector2(x: 400, y: 225)) # Clock in selected mode
      drawText("Press [SPACE] to switch clock mode", 10, 10, 20, DarkGray)
    # ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# Module Functions Definition
# ----------------------------------------------------------------------------------

# Update clock time
proc updateClock(clock: var Clock) =
  let timeInfo = now()

  # Updating time data
  clock.second.value = int32(timeInfo.second)
  clock.minute.value = int32(timeInfo.minute)
  clock.hour.value = int32(timeInfo.hour)

  clock.hour.angle = float32((timeInfo.hour mod 12) * 180 div 6)
  clock.hour.angle += float32((timeInfo.minute mod 60) * 30 div 60)
  clock.hour.angle -= 90

  clock.minute.angle = float32((timeInfo.minute mod 60) * 6)
  clock.minute.angle += float32((timeInfo.second mod 60) * 6 div 60)
  clock.minute.angle -= 90

  clock.second.angle = float32((timeInfo.second mod 60) * 6)
  clock.second.angle -= 90

# Draw clock
proc drawClock(clock: Clock, centerPosition: Vector2) =
  if clock.mode == ModeHandsFree:
    drawCircleLines(centerPosition, float32(clock.minute.length), LightGray)

    drawText($clock.second.value, 
             int32(centerPosition.x + float32(clock.second.length - 10) * cos(clock.second.angle.degToRad) - DigitSize/2'f32), 
             int32(centerPosition.y + float32(clock.second.length) * sin(clock.second.angle.degToRad) - DigitSize/2'f32),
             DigitSize, Gray)

    drawText($clock.minute.value, 
             int32(centerPosition.x + float32(clock.minute.length) * cos(clock.minute.angle.degToRad) - DigitSize/2'f32), 
             int32(centerPosition.y + float32(clock.minute.length) * sin(clock.minute.angle.degToRad) - DigitSize/2'f32),
             DigitSize, Red)

    drawText($clock.hour.value, 
             int32(centerPosition.x + float32(clock.hour.length) * cos(clock.hour.angle.degToRad) - DigitSize/2'f32), 
             int32(centerPosition.y + float32(clock.hour.length) * sin(clock.hour.angle.degToRad) - DigitSize/2'f32), 
             DigitSize, Gold)
  elif clock.mode == ModeNormal:
    # Draw hand seconds
    drawRectangle(
      Rectangle(x: centerPosition.x, y: centerPosition.y, 
                width: float32(clock.second.length), height: float32(clock.second.thickness)),
      Vector2(x: 0, y: float32(clock.second.thickness)/2), 
      clock.second.angle, 
      clock.second.color)

    # Draw hand minutes
    drawRectangle(
      Rectangle(x: centerPosition.x, y: centerPosition.y, 
                width: float32(clock.minute.length), height: float32(clock.minute.thickness)),
      Vector2(x: 0, y: float32(clock.minute.thickness)/2), 
      clock.minute.angle, 
      clock.minute.color)

    # Draw hand hours
    drawRectangle(
      Rectangle(x: centerPosition.x, y: centerPosition.y, 
                width: float32(clock.hour.length), height: float32(clock.hour.thickness)),
      Vector2(x: 0, y: float32(clock.hour.thickness)/2), 
      clock.hour.angle, 
      clock.hour.color)

main()
