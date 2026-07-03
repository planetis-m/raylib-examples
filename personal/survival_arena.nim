# ****************************************************************************************
#
#   raylib [shapes] example - survival arena
#
#   Example complexity rating: [★★★☆] 3/4
#
#   A top-down survival shooter with hundreds of active entities, demonstrating
#   a hybrid data architecture for games:
#     - Agents (player + enemies) as fat structs in a seq (AoS)
#     - Particles as parallel SoA arrays for tight batch updates
#     - Spatial hash grid for O(1) collision queries
#
#   Controls:
#     WASD / Arrows  - Move player
#     Auto-fire      - Player shoots the nearest enemy automatically
#     Mouse wheel    - Zoom camera
#     P              - Pause
#     R              - Restart
#     F1             - Toggle debug info
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2025 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, raymath, rlgl, std/[math, random, setutils, strformat]

const
  ScreenWidth = 800
  ScreenHeight = 450

  # Arena is larger than the screen — camera follows the player
  WorldWidth = 4000
  WorldHeight = 3000

  MaxParticles = 4000
  MaxProjectiles = 800

  # Player
  PlayerSpeed = 200
  PlayerHp = 300
  PlayerRadius = 14
  FireRate: float32 = 0.12 # seconds between shots
  ProjSpeed = 450
  ProjDamage = 28
  ProjLife: float32 = 1.5
  ProjRadius = 6

  # Enemies
  EnemyRadius = 10
  EnemyHp = 50
  EnemySpeed = 55
  EnemyDamage = 8
  EnemyTouchRate: float32 = 0.5
  SpawnInterval: float32 = 0.5 # seconds between spawn waves
  InitialSpawn = 60
  MaxEnemies = 500

  # Spatial grid
  CellSize = 48
  GridCols = WorldWidth div CellSize + 2
  GridRows = WorldHeight div CellSize + 2

# ----------------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------------

type
  AgentKind = enum
    agPlayer, agEnemy

  GameFlag = enum
    gfGameOver, gfPaused, gfShowDebug

  Agent = object
    pos: Vector2
    vel: Vector2
    radius: float32
    hp: float32
    maxHp: float32
    cooldown: float32
    kind: AgentKind
    alive: bool

  Projectile = object
    pos: Vector2
    vel: Vector2
    life: float32
    active: bool

  # SoA particle system - split by access group, not by field
  ParticleBody = object
    pos: Vector2
    vel: Vector2

  ParticleSystem = object
    bodies: seq[ParticleBody]
    life: seq[float32]
    color: seq[Color]
    count: int32

  # Spatial hash grid for O(1) neighbor lookups
  SpatialGrid = object
    buckets: array[GridCols*GridRows, seq[int32]]

  Game = object
    agents: seq[Agent]
    projectiles: seq[Projectile]
    particles: ParticleSystem
    grid: SpatialGrid
    queryResult: seq[int32]
    playerIdx: int32
    score: int32
    flags: set[GameFlag]
    spawnTimer: float32
    camera: Camera2D

# ----------------------------------------------------------------------------------------
# Particle System (SoA)
# ----------------------------------------------------------------------------------------

func initParticles(cap: int32): ParticleSystem =
  ParticleSystem(
    bodies: newSeq[ParticleBody](cap),
    life: newSeq[float32](cap),
    color: newSeq[Color](cap))

proc spawn(ps: var ParticleSystem, pos: Vector2, count: int32, color: Color) =
  for i in 0..<count:
    if ps.count >= ps.bodies.len: return
    let idx = ps.count
    inc ps.count
    let angle = rand(0'f32 .. TAU.float32)
    let speed = rand(40'f32 .. 120'f32)
    ps.bodies[idx] = ParticleBody(
      pos: pos,
      vel: Vector2(x: cos(angle)*speed, y: sin(angle)*speed))
    ps.life[idx] = rand(0.3'f32 .. 0.7'f32)
    ps.color[idx] = color

proc update(ps: var ParticleSystem, dt: float32) =
  var w: int32 = 0
  for i in 0..<ps.count:
    ps.life[i] -= dt
    if ps.life[i] > 0:
      if w != i:
        ps.bodies[w] = ps.bodies[i]
        ps.life[w] = ps.life[i]
        ps.color[w] = ps.color[i]
      ps.bodies[w].pos.x += ps.bodies[w].vel.x*dt
      ps.bodies[w].pos.y += ps.bodies[w].vel.y*dt
      ps.bodies[w].vel.x *= 0.94
      ps.bodies[w].vel.y *= 0.94
      inc w
  ps.count = w

proc draw(ps: ParticleSystem) =
  for i in 0..<ps.count:
    drawCircle(ps.bodies[i].pos, 4, fade(ps.color[i], ps.life[i]))

# ----------------------------------------------------------------------------------------
# Spatial Hash Grid
# ----------------------------------------------------------------------------------------

proc clear(grid: var SpatialGrid) =
  for bucket in mitems(grid.buckets):
    bucket.setLen(0)

proc insert(grid: var SpatialGrid, idx: int32, pos: Vector2, radius: float32) =
  let minX = max(0'i32, int32((pos.x - radius)/CellSize))
  let maxX = min(GridCols - 1, int32((pos.x + radius)/CellSize))
  let minY = max(0'i32, int32((pos.y - radius)/CellSize))
  let maxY = min(GridRows - 1, int32((pos.y + radius)/CellSize))
  for cy in minY..maxY:
    for cx in minX..maxX:
      grid.buckets[cy*GridCols + cx].add(idx)

proc queryNearby(grid: SpatialGrid, pos: Vector2, radius: float32, result: var seq[int32]) =
  result.setLen(0)
  let minX = max(0'i32, int32((pos.x - radius)/CellSize))
  let maxX = min(GridCols - 1, int32((pos.x + radius)/CellSize))
  let minY = max(0'i32, int32((pos.y - radius)/CellSize))
  let maxY = min(GridRows - 1, int32((pos.y + radius)/CellSize))
  for cy in minY..maxY:
    for cx in minX..maxX:
      for agentIdx in grid.buckets[cy*GridCols + cx]:
        if result.len == 0 or result[result.high] != agentIdx:
          result.add(agentIdx)

# ----------------------------------------------------------------------------------------
# Game Logic
# ----------------------------------------------------------------------------------------

func countEnemies(g: Game): int32 =
  result = 0
  for a in g.agents:
    if a.alive and a.kind == agEnemy: inc(result)

func newGame(): Game =
  result = Game(
    particles: initParticles(MaxParticles),
    camera: Camera2D(zoom: 1),
    playerIdx: 0)
  result.agents.add(Agent(
    pos: Vector2(x: WorldWidth/2'f32, y: WorldHeight/2'f32),
    radius: PlayerRadius,
    hp: PlayerHp, maxHp: PlayerHp,
    kind: agPlayer, alive: true))

proc reset(g: var Game) =
  g.agents.setLen(0)
  g.projectiles.setLen(0)
  g.particles.count = 0
  g.score = 0
  g.flags = {}
  g.spawnTimer = 0
  g.agents.add(Agent(
    pos: Vector2(x: WorldWidth/2'f32, y: WorldHeight/2'f32),
    radius: PlayerRadius,
    hp: PlayerHp, maxHp: PlayerHp,
    kind: agPlayer, alive: true))
  g.playerIdx = 0

proc spawnEnemy(g: var Game) =
  if g.countEnemies() >= MaxEnemies: return
  template p: Agent = g.agents[g.playerIdx]
  let angle = rand(0'f32 .. TAU.float32)
  let dist = 350'f32 + rand(0'f32 .. 150'f32)
  g.agents.add(Agent(
    pos: Vector2(
      x: clamp(p.pos.x + cos(angle)*dist, 0'f32, WorldWidth.float32),
      y: clamp(p.pos.y + sin(angle)*dist, 0'f32, WorldHeight.float32)),
    radius: EnemyRadius,
    hp: EnemyHp, maxHp: EnemyHp,
    cooldown: 0,
    kind: agEnemy, alive: true))

func findNearestEnemy(g: Game, pos: Vector2): int32 =
  result = -1
  var bestDist = high(float32)
  for i in 0..<g.agents.len:
    template a: Agent = g.agents[i]
    if a.alive and a.kind == agEnemy:
      let dx = a.pos.x - pos.x
      let dy = a.pos.y - pos.y
      let d = dx*dx + dy*dy
      if d < bestDist:
        bestDist = d
        result = int32(i)

proc fireAt(g: var Game, origin: Vector2, targetIdx: int32) =
  let dir = normalize(g.agents[targetIdx].pos - origin)
  if g.projectiles.len < MaxProjectiles:
    g.projectiles.add(Projectile(
      pos: Vector2(x: origin.x + dir.x*PlayerRadius, y: origin.y + dir.y*PlayerRadius),
      vel: Vector2(x: dir.x*ProjSpeed, y: dir.y*ProjSpeed),
      life: ProjLife,
      active: true))

proc updatePlayer(g: var Game, dt: float32) =
  template p: Agent = g.agents[g.playerIdx]
  var dir = Vector2()
  if isKeyDown(Right) or isKeyDown(D): dir.x += 1
  if isKeyDown(Left) or isKeyDown(A): dir.x -= 1
  if isKeyDown(Down) or isKeyDown(S): dir.y += 1
  if isKeyDown(Up) or isKeyDown(W): dir.y -= 1
  if dir.x != 0 or dir.y != 0:
    dir = normalize(dir)
  p.pos.x = clamp(p.pos.x + dir.x*PlayerSpeed*dt, p.radius, WorldWidth - p.radius)
  p.pos.y = clamp(p.pos.y + dir.y*PlayerSpeed*dt, p.radius, WorldHeight - p.radius)
  # Auto-fire at nearest enemy
  p.cooldown -= dt
  if p.cooldown <= 0:
    let target = g.findNearestEnemy(p.pos)
    if target >= 0:
      g.fireAt(p.pos, target)
      p.cooldown = FireRate

proc updateEnemies(g: var Game, dt: float32) =
  template p: Agent = g.agents[g.playerIdx]
  for i in 0..<g.agents.len:
    template a: Agent = g.agents[i]
    if a.alive and a.kind == agEnemy:
      # Seek the player
      let toPlayer = p.pos - a.pos
      let dist = length(toPlayer)
      if dist > 0.01'f32:
        a.vel.x = toPlayer.x/dist*EnemySpeed
        a.vel.y = toPlayer.y/dist*EnemySpeed
      a.pos.x += a.vel.x*dt
      a.pos.y += a.vel.y*dt
      # Touch damage
      a.cooldown -= dt
      if a.cooldown <= 0:
        let dx = a.pos.x - p.pos.x
        let dy = a.pos.y - p.pos.y
        if dx*dx + dy*dy < (a.radius + p.radius)*(a.radius + p.radius):
          p.hp -= EnemyDamage
          a.cooldown = EnemyTouchRate
          if p.hp <= 0:
            p.hp = 0
            p.alive = false
            g.flags.incl gfGameOver
            g.particles.spawn(p.pos, 40, Blue)

proc updateProjectiles(g: var Game, dt: float32) =
  for i in 0..<g.projectiles.len:
    template pr: Projectile = g.projectiles[i]
    pr.life -= dt
    if pr.life > 0:
      pr.pos.x += pr.vel.x*dt
      pr.pos.y += pr.vel.y*dt
      if pr.pos.x >= 0 and pr.pos.x <= WorldWidth and
         pr.pos.y >= 0 and pr.pos.y <= WorldHeight:
        for j in 0..<g.agents.len:
          template a: Agent = g.agents[j]
          if a.alive and a.kind == agEnemy:
            let dx = pr.pos.x - a.pos.x
            let dy = pr.pos.y - a.pos.y
            if dx*dx + dy*dy < a.radius*a.radius:
              a.hp -= ProjDamage
              pr.active = false
              g.particles.spawn(pr.pos, 5, Gold)
              if a.hp <= 0:
                a.alive = false
                g.particles.spawn(a.pos, 15, Red)
                inc(g.score)
              break
      else:
        pr.active = false
    else:
      pr.active = false
  # Compact active projectiles
  var w = 0
  for i in 0..<g.projectiles.len:
    if g.projectiles[i].active:
      if w != i: g.projectiles[w] = g.projectiles[i]
      inc w
  g.projectiles.setLen(w)

proc resolveCollisions(g: var Game) =
  g.grid.clear()
  for i in 0..<g.agents.len:
    template a: Agent = g.agents[i]
    if a.alive:
      g.grid.insert(int32(i), a.pos, a.radius)
  for i in 0..<g.agents.len:
    template a: Agent = g.agents[i]
    if a.alive:
      g.grid.queryNearby(a.pos, a.radius*2, g.queryResult)
      for j in g.queryResult:
        if j > int32(i):
          template b: Agent = g.agents[j]
          if b.alive:
            let dx = b.pos.x - a.pos.x
            let dy = b.pos.y - a.pos.y
            let distSq = dx*dx + dy*dy
            let minDist = a.radius + b.radius
            if distSq < minDist*minDist and distSq > 0.01'f32:
              let dist = sqrt(distSq)
              let overlap = (minDist - dist)*0.5'f32
              let nx = dx/dist
              let ny = dy/dist
              a.pos.x -= nx*overlap
              a.pos.y -= ny*overlap
              b.pos.x += nx*overlap
              b.pos.y += ny*overlap
  # Compact dead enemies
  var w = 0
  for i in 0..<g.agents.len:
    if g.agents[i].alive:
      if w != i: g.agents[w] = g.agents[i]
      inc w
  g.agents.setLen(w)
  g.playerIdx = 0

proc updateSpawn(g: var Game, dt: float32) =
  g.spawnTimer += dt
  if g.spawnTimer >= SpawnInterval:
    g.spawnTimer = 0
    let wave = 2 + g.score div 25
    for _ in 0..<wave:
      g.spawnEnemy()

proc updateCamera(g: var Game) =
  template p: Agent = g.agents[g.playerIdx]
  g.camera.target = p.pos
  g.camera.offset = Vector2(x: ScreenWidth/2'f32, y: ScreenHeight/2'f32)
  let wheel = getMouseWheelMove()
  if wheel != 0:
    g.camera.zoom = clamp(g.camera.zoom + wheel*0.05'f32, 0.5, 2)

# ----------------------------------------------------------------------------------------
# Drawing
# ----------------------------------------------------------------------------------------

proc drawAgent(a: Agent) =
  if a.kind == agPlayer:
    drawCircleGradient(a.pos.x.int32, a.pos.y.int32, a.radius, Blue, DarkBlue)
  else:
    drawCircle(a.pos, a.radius, Red)

proc drawWorld(g: Game) =
  mode2D(g.camera):
    clearBackground(RayWhite)
    # Background grid
    pushMatrix()
    translatef(WorldWidth/2'f32, WorldHeight, 0)
    rotatef(90, 1, 0, 0)
    drawGrid(80, 80)
    popMatrix()
    # Agents
    for a in g.agents:
      if a.alive: drawAgent(a)
    # Projectiles
    for pr in g.projectiles:
      drawCircle(pr.pos, ProjRadius, Gold)
    # Particles
    g.particles.draw()

proc drawHUD(g: Game) =
  template p: Agent = g.agents[g.playerIdx]
  # HP bar
  drawRectangle(10, 10, 200, 28, Gray)
  let hpW = 198*(p.hp/p.maxHp)
  drawRectangle(Rectangle(x: 11, y: 11, width: hpW, height: 26),
    if p.hp > p.maxHp*0.3'f32: Green else: Red)
  drawText(&"HP: {int32(p.hp)}/{int32(p.maxHp)}", 15, 13, 20, White)
  # Score
  drawText(&"SCORE: {g.score:04d}", 10, 46, 20, DarkGray)
  drawText(&"ENEMIES: {g.countEnemies()}", 10, 72, 20, DarkGray)
  drawFPS(ScreenWidth - 80, 10)
  # Debug
  if gfShowDebug in g.flags:
    drawText(&"Agents: {g.agents.len}  Proj: {g.projectiles.len}  Parts: {g.particles.count}",
             10, 98, 14, DarkGray)
  # Paused overlay
  if gfPaused in g.flags:
    let text = "PAUSED"
    let w = measureText(text, 40)
    drawText(text, ScreenWidth div 2 - w div 2, ScreenHeight div 2 - 20, 40, DarkGray)
  # Game over overlay
  if gfGameOver in g.flags:
    drawRectangle(0, 0, ScreenWidth, ScreenHeight, fade(White, 0.7))
    let t1 = "GAME OVER"
    let t2 = &"SCORE: {g.score}"
    let t3 = "PRESS [R] TO RESTART"
    let w1 = measureText(t1, 40)
    let w2 = measureText(t2, 20)
    let w3 = measureText(t3, 20)
    drawText(t1, ScreenWidth div 2 - w1 div 2, ScreenHeight div 2 - 60, 40, Red)
    drawText(t2, ScreenWidth div 2 - w2 div 2, ScreenHeight div 2 - 10, 20, DarkGray)
    drawText(t3, ScreenWidth div 2 - w3 div 2, ScreenHeight div 2 + 20, 20, Gray)

proc updateDrawFrame(g: var Game) =
  let dt = getFrameTime()
  if isKeyPressed(P):
    g.flags = symmetricDifference(g.flags, {gfPaused})
  if isKeyPressed(R): g.reset()
  if isKeyPressed(F1):
    g.flags = symmetricDifference(g.flags, {gfShowDebug})
  if gfPaused notin g.flags and gfGameOver notin g.flags:
    g.updatePlayer(dt)
    g.updateEnemies(dt)
    g.resolveCollisions()
    g.updateProjectiles(dt)
    g.updateSpawn(dt)
    g.particles.update(dt)
    g.updateCamera()
  drawing():
    g.drawWorld()
    g.drawHUD()

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  initWindow(ScreenWidth, ScreenHeight, "raylib [shapes] example - survival arena")
  defer: closeWindow()
  setTargetFPS(60)
  randomize()

  var game = newGame()
  # Initial spawn wave
  for _ in 0..<InitialSpawn:
    game.spawnEnemy()
  while not windowShouldClose():
    updateDrawFrame(game)

main()
