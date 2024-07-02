# ****************************************************************************************
#
#   raylib [textures] example - Texture loading and drawing a part defined by a rectangle
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib, std/[random, strformat]

const
  screenWidth = 800
  screenHeight = 450

  StorageDataFile = "storage.data" # Storage file

type
  StorageData = enum
    # NOTE: Storage positions must start with 0, directly related to file memory layout
    Score = 0, Hiscore

proc saveStorageValue(position: StorageData, value: int32) =
  # Save integer value to storage file (to defined position)
  # NOTE: Storage positions is directly related to file memory layout (4 bytes each integer)
  var fileData = readFile(StorageDataFile)
  if fileData.len <= position.ord*4:
    if fileData.len == 0:
      traceLog(Info, &"FILEIO: [{StorageDataFile}] File created successfully")
    # Increase data size up to position and store value
    fileData.setLen((position.ord + 1)*4)
  let dataPtr = cast[ptr UncheckedArray[int32]](addr fileData[0])
  dataPtr[position.ord] = value
  writeFile(StorageDataFile, fileData)
  traceLog(Info, &"FILEIO: [{StorageDataFile}] Saved storage value: {value}")

proc loadStorageValue(position: StorageData): int32 =
  # Load integer value from storage file (from defined position)
  # NOTE: If requested position could not be found, value 0 is returned
  result = 0
  let fileData = readFile(StorageDataFile)
  if fileData.len < position.ord*4:
    traceLog(Warning, &"FILEIO: [{StorageDataFile}] Failed to find storage position: {position}")
  else:
    let dataPtr = cast[ptr UncheckedArray[int32]](addr fileData[0])
    result = dataPtr[position.ord]
  traceLog(Info, &"FILEIO: [{StorageDataFile}] Loaded storage value: {result}")

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - storage save/load values")

  var score: int32 = 0
  var hiscore: int32 = 0
  var framesCounter = 0

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(R):
      score = rand(1000'i32..2000'i32)
      hiscore = rand(2000'i32..4000'i32)
    if isKeyPressed(Enter):
      saveStorageValue(Score, score)
      saveStorageValue(Hiscore, hiscore)
    elif isKeyPressed(Space):
      # NOTE: If requested position could not be found, value 0 is returned
      score = loadStorageValue(Score)
      hiscore = loadStorageValue(Hiscore)

    inc framesCounter
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText(&"SCORE: {score}", 280, 130, 40, Maroon)
    drawText(&"HI-SCORE: {hiscore}", 210, 200, 50, Black)

    drawText(&"frames: {framesCounter}", 10, 10, 20, Lime)

    drawText("Press R to generate random numbers", 220, 40, 20, LightGray)
    drawText("Press ENTER to SAVE values", 250, 310, 20, LightGray)
    drawText("Press SPACE to LOAD values", 252, 350, 20, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
