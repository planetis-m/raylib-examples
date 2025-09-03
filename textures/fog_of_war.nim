# ****************************************************************************************
#
#   raylib [textures] example - fog of war
#
#   Example complexity rating: [★★★☆] 3/4
#
#   Example originally created with raylib 4.2, last time updated with raylib 4.2
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2018-2025 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, std/[random, strformat]

const
  MapTileSize = 32           # Tiles size 32x32 pixels
  PlayerSize = 16            # Player size
  PlayerTileVisibility = 2   # Player can see 2 tiles around its position

  ScreenWidth = 800
  ScreenHeight = 450

# Map data type
type
  Map = object
    tilesX: int32            # Number of tiles in X axis
    tilesY: int32            # Number of tiles in Y axis
    tileIds: seq[uint8]      # Tile ids (tilesX*tilesY), defines type of tile to draw
    tileFog: seq[uint8]      # Tile fog state (tilesX*tilesY), defines if a tile has fog or half-fog

proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [textures] example - fog of war")
  defer: closeWindow()

  var map = Map(tilesX: 25, tilesY: 15)

  # NOTE: We can have up to 256 values for tile ids and for tile fog state,
  # probably we don't need that many values for fog state, it can be optimized
  # to use only 2 bits per fog state (reducing size by 4) but logic will be a bit more complex
  map.tileIds = newSeq[uint8](map.tilesX * map.tilesY)
  map.tileFog = newSeq[uint8](map.tilesX * map.tilesY)

  # Load map tiles (generating 2 random tile ids for testing)
  # NOTE: Map tile ids should be probably loaded from an external map file
  for i in 0..<map.tilesY*map.tilesX:
    map.tileIds[i] = uint8(rand(0..1))

  # Player position on the screen (pixel coordinates, not tile coordinates)
  var playerPosition = Vector2(x: 180, y: 130)
  var playerTileX: int32 = 0
  var playerTileY: int32 = 0

  # Render texture to render fog of war
  # NOTE: To get an automatic smooth-fog effect we use a render texture to render fog
  # at a smaller size (one pixel per tile) and scale it on drawing with bilinear filtering
  var fogOfWar = loadRenderTexture(map.tilesX, map.tilesY)
  setTextureFilter(fogOfWar.texture, Bilinear)

  setTargetFPS(60)               # Set our game to run at 60 frames-per-second

  # Main game loop
  while not windowShouldClose():    # Detect window close button or ESC key
    # Update
    # Move player around
    if isKeyDown(Right): playerPosition.x += 5
    if isKeyDown(Left): playerPosition.x -= 5
    if isKeyDown(Down): playerPosition.y += 5
    if isKeyDown(Up): playerPosition.y -= 5

    # Check player position to avoid moving outside tilemap limits
    if playerPosition.x < 0: playerPosition.x = 0
    elif (playerPosition.x + PlayerSize) > (float32(map.tilesX)*MapTileSize): 
      playerPosition.x = float32(map.tilesX)*MapTileSize - PlayerSize
    if playerPosition.y < 0: playerPosition.y = 0
    elif (playerPosition.y + PlayerSize) > (float32(map.tilesY)*MapTileSize): 
      playerPosition.y = float32(map.tilesY)*MapTileSize - PlayerSize

    # Previous visited tiles are set to partial fog
    for i in 0..<map.tilesX*map.tilesY:
      if map.tileFog[i] == 1: map.tileFog[i] = 2

    # Get current tile position from player pixel position
    playerTileX = int32((playerPosition.x + MapTileSize/2'f32)/MapTileSize)
    playerTileY = int32((playerPosition.y + MapTileSize/2'f32)/MapTileSize)

    # Check visibility and update fog
    # NOTE: We check tilemap limits to avoid processing tiles out-of-array-bounds (it could crash program)
    for y in (playerTileY - PlayerTileVisibility)..<(playerTileY + PlayerTileVisibility):
      for x in (playerTileX - PlayerTileVisibility)..<(playerTileX + PlayerTileVisibility):
        if (x >= 0) and (x < map.tilesX) and (y >= 0) and (y < map.tilesY):
          map.tileFog[y*map.tilesX + x] = 1

    # Draw
    # Draw fog of war to a small render texture for automatic smoothing on scaling
    textureMode(fogOfWar):
      clearBackground(Blank)
      for y in 0..<map.tilesY:
        for x in 0..<map.tilesX:
          if map.tileFog[y*map.tilesX + x] == 0:
            drawRectangle(x, y, 1, 1, Black)
          elif map.tileFog[y*map.tilesX + x] == 2:
            drawRectangle(x, y, 1, 1, fade(Black, 0.8'f32))

    drawing():
      clearBackground(RayWhite)

      for y in 0..<map.tilesY:
        for x in 0..<map.tilesX:
          # Draw tiles from id (and tile borders)
          let color = if map.tileIds[y*map.tilesX + x] == 0: Blue else: fade(Blue, 0.9'f32)
          drawRectangle(x*MapTileSize, y*MapTileSize, MapTileSize, MapTileSize, color)
          drawRectangleLines(x*MapTileSize, y*MapTileSize, MapTileSize, MapTileSize, fade(DarkBlue, 0.5'f32))

      # Draw player
      drawRectangle(playerPosition, Vector2(x: PlayerSize, y: PlayerSize), Red)

      # Draw fog of war (scaled to full map, bilinear filtering)
      drawTexture(fogOfWar.texture, 
                  Rectangle(x: 0, y: 0, width: float32(fogOfWar.texture.width), height: -float32(fogOfWar.texture.height)),
                  Rectangle(x: 0, y: 0, width: float32(map.tilesX)*MapTileSize, height: float32(map.tilesY)*MapTileSize),
                  Vector2(x: 0, y: 0), 0, White)

      # Draw player current tile
      drawText(&"Current tile: [{playerTileX},{playerTileY}]", 10, 10, 20, RayWhite)
      drawText("ARROW KEYS to move", 10, ScreenHeight - 25, 20, RayWhite)

main()
