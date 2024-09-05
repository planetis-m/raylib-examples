import raylib, raymath, rmem, std/[random, math]

const
  screenWidth = 800
  screenHeight = 450

  MaxParticles = 1000
  ParticlesPerClick = 10  # Number of particles to spawn per click

type
  Particle = object
    position: Vector2
    velocity: Vector2
    color: Color
    size: float32

  ParticleSystem = object
    buffer: pointer
    pool: ObjPool[Particle]
    activeParticles: array[MaxParticles, ptr Particle]
    activeCount: int32

proc `=destroy`(x: ParticleSystem) =
  # x.pool.freeAll()
  dealloc(x.buffer)

proc createParticleSystem(): ParticleSystem =
  result = ParticleSystem(activeCount: 0)
  let memSize = sizeof(Particle)*MaxParticles
  result.buffer = alloc(memSize)
  result.pool = createObjPool[Particle](result.buffer, memSize)

proc updateParticle(particle: ptr Particle): bool =
  particle.position += particle.velocity
  particle.size -= 0.1
  result = particle.size > 0

proc drawParticle(particle: ptr Particle) =
  drawCircle(particle.position, particle.size, particle.color)

proc spawnParticles(system: var ParticleSystem, position: Vector2, count: int32) =
  for _ in 0 ..< count:
    if system.activeCount >= MaxParticles:
      break
    let newParticle = system.pool.alloc()
    if newParticle == nil:
      break
    let angle = rand(0.0..2*PI)
    let speed = rand(1.0..3.0)
    newParticle[] = Particle(
      position: position,
      velocity: Vector2(x: cos(angle) * speed, y: sin(angle) * speed),
      color: Color(r: uint8(rand(128..255)), g: uint8(rand(128..255)), b: uint8(rand(128..255)), a: 255),
      size: rand(5.0..20.0)
    )
    system.activeParticles[system.activeCount] = newParticle
    inc system.activeCount

proc updateParticleSystem(system: var ParticleSystem) =
  var i = 0
  while i < system.activeCount:
    if updateParticle(system.activeParticles[i]):
      inc i
    else:
      system.pool.free(system.activeParticles[i])
      system.activeParticles[i] = system.activeParticles[system.activeCount - 1]
      dec system.activeCount

proc drawParticleSystem(system: ParticleSystem) =
  for i in 0 ..< system.activeCount:
    drawParticle(system.activeParticles[i])

proc main() =
  var particleSystem = createParticleSystem()

  initWindow(screenWidth, screenHeight, "Raylib Nim rmem Example")
  setTargetFPS(60)

  while not windowShouldClose():
    if isMouseButtonPressed(Left):
      let clickPosition = getMousePosition()
      spawnParticles(particleSystem, clickPosition, ParticlesPerClick)

    updateParticleSystem(particleSystem)

    drawing():
      clearBackground(RayWhite)
      drawParticleSystem(particleSystem)
      drawText("Active Particles: " & $particleSystem.activeCount, 10, 10, 20, Black)

  closeWindow()

main()
