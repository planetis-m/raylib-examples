# ****************************************************************************************
#
#   raylib [shaders] example - Basic PBR
#
#   Example originally created with raylib 5.0, last time updated with raylib 5.1-dev
#
#   Example contributed by Afan OLOVCIC (@_DevDad) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2023-2024 Afan OLOVCIC (@_DevDad)
#
#   Model: "Old Rusty Car" (https://skfb.ly/LxRy) by Renafox,
#   licensed under Creative Commons Attribution-NonCommercial
#   (http://creativecommons.org/licenses/by-nc/4.0/)
#
# ****************************************************************************************

import raylib, std/[strformat, lenientops]

const
  screenWidth = 800
  screenHeight = 450

when defined(GraphicsApiOpenGl33):
  const
    glslVersion = 330
else:
  const
    glslVersion = 120

const
  MaxLights = 4

# ----------------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------------

type
  LightKind = enum # Light type
    Directional, Point, Spot

  Light = object # Light data
    enabled: int32
    kind: int32
    position: Vector3
    target: Vector3
    color: array[4, float32]
    intensity: float32

    enabledLoc: ShaderLocation
    typeLoc: ShaderLocation
    positionLoc: ShaderLocation
    targetLoc: ShaderLocation
    colorLoc: ShaderLocation
    intensityLoc: ShaderLocation

# ----------------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------------

var lightCount: int32 = 0 # Current number of dynamic lights that have been created

# ----------------------------------------------------------------------------------------
# Module specific Functions Definition
# ----------------------------------------------------------------------------------------

proc updateLight(shader: Shader; light: Light) =
  # Send light properties to shader
  # NOTE: Light shader locations should be available
  setShaderValue(shader, light.enabledLoc, light.enabled)
  setShaderValue(shader, light.typeLoc, light.kind)
  # Send to shader light position values
  var position: array[3, float32] = [
    light.position.x, light.position.y, light.position.z
  ]
  setShaderValue(shader, light.positionLoc, position)
  # Send to shader light target position values
  var target: array[3, float32] = [
    light.target.x, light.target.y, light.target.z
  ]
  setShaderValue(shader, light.targetLoc, target)
  setShaderValue(shader, light.colorLoc, light.color)
  setShaderValue(shader, light.intensityLoc, light.intensity)

proc createLight(kind: LightKind; position, target: Vector3;
    color: Color; intensity: float32; shader: Shader): Light =
  # Create light with provided data
  # NOTE: It updated the global lightCount and it's limited to MAX_LIGHTS
  result = Light(enabled: 0)
  if lightCount < MaxLights:
    result = Light(
      enabled: 1,
      kind: int32(kind),
      position: position,
      target: target,
      color: [color.r/255'f32, color.g/255'f32, color.b/255'f32, color.a/255'f32],
      intensity: intensity,
      # NOTE: Lighting shader naming must be the provided ones
      enabledLoc: getShaderLocation(shader, &"lights[{lightCount}].enabled"),
      typeLoc: getShaderLocation(shader, &"lights[{lightCount}].type"),
      positionLoc: getShaderLocation(shader, &"lights[{lightCount}].position"),
      targetLoc: getShaderLocation(shader, &"lights[{lightCount}].target"),
      colorLoc: getShaderLocation(shader, &"lights[{lightCount}].color"),
      intensityLoc: getShaderLocation(shader, &"lights[{lightCount}].intensity")
    )
    updateLight(shader, result)
    inc(lightCount)

# ----------------------------------------------------------------------------------------
# Main Entry Point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - basic pbr")
  defer: closeWindow() # Close window and OpenGL context
  # Define the camera to look into our 3d world
  var camera = Camera(
    position: Vector3(x: 2, y: 2, z: 6), # Camera position perspective
    target: Vector3(x: 0, y: 0.5, z: 0), # Camera looking at point
    up: Vector3(x: 0, y: 1, z: 0),       # Camera up vector (rotation towards target)
    fovy: 45,                            # Camera field-of-view Y
    projection: Perspective              # Camera projection type
  )
  # Load PBR shader and setup all required locations
  var shader = loadShader(&"resources/shaders/glsl{glslVersion}/pbr.vs",
      &"resources/shaders/glsl{glslVersion}/pbr.fs")
  shader.locs[MapAlbedo] = getShaderLocation(shader, "albedoMap")
  # WARNING: Metalness, roughness, and ambient occlusion are all packed into a MRA texture
  # They are passed as to the SHADER_LOC_MAP_METALNESS location for convenience,
  # shader already takes care of it accordingly
  shader.locs[MapMetalness] = getShaderLocation(shader, "mraMap")
  shader.locs[MapNormal] = getShaderLocation(shader, "normalMap")
  # WARNING: Similar to the MRA map, the emissive map packs different information
  # into a single texture: it stores height and emission data
  # It is binded to SHADER_LOC_MAP_EMISSION location an properly processed on shader
  shader.locs[MapEmission] = getShaderLocation(shader, "emissiveMap")
  shader.locs[ColorDiffuse] = getShaderLocation(shader, "albedoColor")
  # Setup additional required shader locations, including lights data
  shader.locs[VectorView] = getShaderLocation(shader, "viewPos")
  let lightCountLoc = getShaderLocation(shader, "numOfLights")
  let maxLightCount: int32 = MaxLights
  setShaderValue(shader, lightCountLoc, maxLightCount)
  # Setup ambient color and intensity parameters
  let ambientColor = Color(r: 26, g: 32, b: 135, a: 255)
  let ambientColorNormalized = Vector3(
    x: ambientColor.r / 255'f32,
    y: ambientColor.g / 255'f32,
    z: ambientColor.b / 255'f32
  )
  let ambientIntensity: float32 = 0.02
  let albedoLoc = getShaderLocation(shader, "albedo")
  let ambientColorLoc = getShaderLocation(shader, "ambientColor")
  let ambientLoc = getShaderLocation(shader, "ambient")
  setShaderValue(shader, ambientColorLoc, ambientColorNormalized)
  setShaderValue(shader, ambientLoc, ambientIntensity)
  let emissiveIntensityLoc = getShaderLocation(shader, "emissivePower")
  let emissiveColorLoc = getShaderLocation(shader, "emissiveColor")
  let textureTilingLoc = getShaderLocation(shader, "tiling")
  # Load old car model using PBR maps and shader
  # WARNING: We know this model consists of a single model.meshes[0] and
  # that model.materials[0] is by default assigned to that mesh
  # There could be more complex models consisting of multiple meshes and
  # multiple materials defined for those meshes... but always 1 mesh = 1 material
  var car = loadModel("resources/models/old_car_new.glb")
  let carAlbedoTex = loadTexture("resources/old_car_d.png")
  let carMetalnessTex = loadTexture("resources/old_car_mra.png")
  let carNormalTex = loadTexture("resources/old_car_n.png")
  let carEmissionTex = loadTexture("resources/old_car_e.png")
  # Assign already setup PBR shader to model.materials[0], used by models.meshes[0]
  car.materials[0].shader = shader
  # Setup materials[0].maps default parameters
  car.materials[0].maps[Albedo].color = White
  car.materials[0].maps[Metalness].value = 0
  car.materials[0].maps[Roughness].value = 0
  car.materials[0].maps[Occlusion].value = 1
  car.materials[0].maps[Emission].color = Color(r: 255, g: 162, b: 0, a: 255)
  # Setup materials[0].maps default textures
  car.materials[0].maps[Albedo].texture = carAlbedoTex
  car.materials[0].maps[Metalness].texture = carMetalnessTex
  car.materials[0].maps[Normal].texture = carNormalTex
  car.materials[0].maps[Emission].texture = carEmissionTex
  # Old car model texture tiling parameter can be stored in the Material struct if required (CURRENTLY NOT USED)
  # NOTE: Material.params[4] are available for generic parameters storage (float)
  let carTextureTiling = Vector2(x: 0.5, y: 0.5)
  # Load floor model mesh and assign material parameters
  var floor = loadModel("resources/models/plane.glb")
  let floorAlbedoTex = loadTexture("resources/road_a.png")
  let floorMetalnessTex = loadTexture("resources/road_mra.png")
  let floorNormalTex = loadTexture("resources/road_n.png")
  # Assign material shader for our floor model, same PBR shader
  floor.materials[0].shader = shader
  floor.materials[0].maps[Albedo].color = White
  floor.materials[0].maps[Metalness].value = 0
  floor.materials[0].maps[Roughness].value = 0
  floor.materials[0].maps[Occlusion].value = 1
  floor.materials[0].maps[Emission].color = Black
  floor.materials[0].maps[Albedo].texture = floorAlbedoTex
  floor.materials[0].maps[Metalness].texture = floorMetalnessTex
  floor.materials[0].maps[Normal].texture = floorNormalTex
  # Floor texture tiling parameter
  let floorTextureTiling = Vector2(x: 0.5, y: 0.5)
  # Create some lights
  var lights: array[MaxLights, Light]
  lights[0] = createLight(Point, Vector3(x: -1, y: 1, z: -2), Vector3(), Yellow, 4, shader)
  lights[1] = createLight(Point, Vector3(x: 2, y: 1, z: 1), Vector3(), Green, 3.3, shader)
  lights[2] = createLight(Point, Vector3(x: -2, y: 1, z: 1), Vector3(), Red, 8.3, shader)
  lights[3] = createLight(Point, Vector3(x: 1, y: 1, z: -2), Vector3(), Blue, 2, shader)
  # Setup material texture maps usage in shader
  # NOTE: By default, the texture maps are always used
  let usage: int32 = 1
  setShaderValue(shader, getShaderLocation(shader, "useTexAlbedo"), usage)
  setShaderValue(shader, getShaderLocation(shader, "useTexNormal"), usage)
  setShaderValue(shader, getShaderLocation(shader, "useTexMRA"), usage)
  setShaderValue(shader, getShaderLocation(shader, "useTexEmissive"), usage)
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateCamera(camera, Orbital)
    # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    let cameraPos: array[3, float32] = [
      camera.position.x, camera.position.y, camera.position.z
    ]
    setShaderValue(shader, shader.locs[VectorView], cameraPos)
    # Check key inputs to enable/disable lights
    if isKeyPressed(Y):
      lights[0].enabled = not lights[0].enabled
    if isKeyPressed(G):
      lights[1].enabled = not lights[1].enabled
    if isKeyPressed(R):
      lights[2].enabled = not lights[2].enabled
    if isKeyPressed(B):
      lights[3].enabled = not lights[3].enabled
    for i in 0 ..< MaxLights:
      updateLight(shader, lights[i])
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)
    beginMode3D(camera)
    # Set floor model texture tiling and emissive color parameters on shader
    setShaderValue(shader, textureTilingLoc, floorTextureTiling)
    let floorEmissiveColor = colorNormalize(floor.materials[0].maps[Emission].color)
    setShaderValue(shader, emissiveColorLoc, floorEmissiveColor)
    drawModel(floor, Vector3(), 5, White)
    # Draw floor model
    # Set old car model texture tiling, emissive color and emissive intensity parameters on shader
    setShaderValue(shader, textureTilingLoc, carTextureTiling)
    let carEmissiveColor = colorNormalize(car.materials[0].maps[Emission].color)
    setShaderValue(shader, emissiveColorLoc, carEmissiveColor)
    let emissiveIntensity: float32 = 0.01
    setShaderValue(shader, emissiveIntensityLoc, emissiveIntensity)
    drawModel(car, Vector3(), 0.25, White)
    # Draw car model
    # Draw spheres to show the lights positions
    for i in 0..<MaxLights:
      let lightColor = Color(
        r: uint8(lights[i].color[0]*255),
        g: uint8(lights[i].color[1]*255),
        b: uint8(lights[i].color[2]*255),
        a: uint8(lights[i].color[3]*255)
      )
      if lights[i].enabled == 1:
        drawSphere(lights[i].position, 0.2, 8, 8, lightColor)
      else:
        drawSphereWires(lights[i].position, 0.2, 8, 8, colorAlpha(lightColor, 0.3))
    endMode3D()
    drawText("Toggle lights: [Y][R][G][B]", 10, 40, 20, LightGray)
    drawText("(c) Old Rusty Car model by Renafox (https://skfb.ly/LxRy)",
        screenWidth - 320, screenHeight - 20, 10, LightGray)
    drawFPS(10, 10)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
