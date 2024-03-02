# ****************************************************************************************
#
#   raylib example - Retro CRT Shader
#   https://babylonjs.medium.com/retro-crt-shader-a-post-processing-effect-study-1cb3f783afbc
#
#   Example originally created with naylib 5.2
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

const
  shaderCode = """
#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec2 size;
uniform float seconds;

// Output fragment color
out vec4 finalColor;

// NOTE: values should be passed from code
const float vignetteOpacity = 1;
const float scanLineOpacity = 0.5;
const float curvature = 10;
const float distortion = 0.1;
const float gammaInput = 2.4;
const float gammaOutput = 2.2;
const float brightness = 1.5;

vec2 curveRemapUV() {
  vec2 uv = fragTexCoord*2.0-1.0;
  vec2 offset = abs(uv.yx)/curvature;
  uv = uv + uv*offset*offset;
  uv = uv*0.5 + 0.5;
  return uv;
}

vec4 vignetteIntensity(vec2 uv, vec2 resolution, float opacity) {
  float intensity = uv.x*uv.y*(1.0 - uv.x)*(1.0 - uv.y);
  return vec4(vec3(clamp(pow(resolution.x*intensity, opacity), 0.0, 1.0)), 1.0);
}

vec4 scanLineIntensity(float uv, float resolution, float opacity) {
  float intensity = sin(uv*resolution*2.0);
  intensity = ((0.5*intensity) + 0.5)*0.9 + 0.1;
  return vec4(vec3(pow(intensity, opacity)), 1.0);
}

vec4 distortIntensity(vec2 uv, float time) {
  vec2 rg = sin(uv*10.0 + time)*distortion + 1.0;
  float b = sin((uv.x + uv.y)*10.0 + time)*distortion + 1.0;
  return vec4(rg, b, 1.0);
}

vec4 gammaInputCorrection(vec4 color) {
  return vec4(pow(color.rgb, vec3(gammaInput)), 1.0);
}

vec4 gammaOutputCorrection(vec4 color) {
  return vec4(pow(color.rgb, vec3(1.0/gammaOutput)), 1.0);
}

void main() {
  vec2 uv = curveRemapUV();
  vec4 baseColor = texture(texture0, uv);
  baseColor *= vignetteIntensity(uv, size, vignetteOpacity);
  baseColor = gammaInputCorrection(baseColor);
  baseColor *= scanLineIntensity(uv.x, size.x, scanLineOpacity);
  baseColor *= scanLineIntensity(uv.y, size.y, scanLineOpacity);
  baseColor = gammaOutputCorrection(baseColor);
  baseColor *= vec4(vec3(brightness), 1.0);
  baseColor *= distortIntensity(uv, seconds);

  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
    finalColor = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    finalColor = baseColor;
  }
}
"""

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - Retro CRT Shader")
  defer: closeWindow() # Close window and OpenGL context

  # Load texture to apply shaders
  let texture = loadTexture("resources/super_mario_bros.png")
  # Load the CRT shader
  let shader = loadShaderFromMemory("", shaderCode)
  # Set shader uniforms
  let screenSize = [getScreenWidth().float32, getScreenHeight().float32]
  setShaderValue(shader, getShaderLocation(shader, "size"), screenSize)
  let secondsLoc = getShaderLocation(shader, "seconds")

  var seconds: float32 = 0
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    seconds += getFrameTime()
    setShaderValue(shader, secondsLoc, seconds)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    # Begin shader mode
    beginShaderMode(shader)
    drawTexture(texture, 0, 0, White)
    endShaderMode()
    endDrawing()
    # ------------------------------------------------------------------------------------

main()