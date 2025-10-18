# ****************************************************************************************
#
#   raylib example - An introduction to Shader Art Coding (https://youtu.be/f4s1h2YETNY)
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
  screenWidth = 600
  screenHeight = 600

  shaderCode = """
#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

// Custom variables
uniform float seconds;
uniform vec2 size;

// NOTE: Render size values should be passed from code
const float renderWidth = 600;
const float renderHeight = 600;

vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.263, 0.416, 0.557);
  return a + b*cos(6.28318*(c*t + d));
}

void main() {
  vec2 uv = fragTexCoord*2.0 - 1.0;
  uv.x *= renderWidth/renderHeight;
  vec2 uv0 = uv;
  vec3 tmpColor = vec3(0.0);
  for (float i = 0.0; i < 4.0; i++) {
    uv = fract(uv*1.5) - 0.5;
    float d = length(uv)*exp(-length(uv0));
    vec3 col = palette(length(uv0) + i*0.4 + seconds*0.4);
    d = sin(d*8.0 + seconds)/8.0;
    d = abs(d);
    d = pow(0.01/d, 1.2);
    tmpColor += col*d;
  }
  finalColor = vec4(tmpColor, 1.0);
}
"""

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - Shader Art Coding")
  defer: closeWindow() # Close window and OpenGL context
  # Create a RenderTexture2D to be used for render to texture
  let target = loadRenderTexture(getScreenWidth(), getScreenHeight())
  # Load shader and setup location points and values
  let shader = loadShaderFromMemory("", shaderCode)
  let secondsLoc = getShaderLocation(shader, "seconds")

  var seconds: float32 = 0
  setShaderValue(shader, secondsLoc, seconds)
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
    # Using a render texture to draw
    beginTextureMode(target) # Enable drawing to texture
    # Draw a rectangle in shader mode to be used as shader canvas
    drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Black)
    endTextureMode()

    beginDrawing()
    # Begin shader mode
    beginShaderMode(shader)
    let src = Rectangle(x: 0, y: 0, width: target.texture.width.float32,
        height: -target.texture.height.float32)
    drawTexture(target.texture, src, Vector2(x: 0, y: 0), White)
    endShaderMode()
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
