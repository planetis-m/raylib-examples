# ****************************************************************************************
#
#   raylib.lights - Some useful functions to deal with lights data
#
#   CONFIGURATION:
#
#   #define RLIGHTS_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers 
#       or source files without problems. But only ONE file should hold the implementation.
#
#   LICENSE: zlib/libpng
#
#   Copyright (c) 2017-2024 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
#
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
#
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
#
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
#
#     3. This notice may not be removed or altered from any source distribution.
#
# ****************************************************************************************

import raylib, std/strformat

const
  MaxLights* = 4         # Max dynamic lights supported by shader

type
  LightType* = enum
    Directional = 0,     # LIGHT_DIRECTIONAL
    Point                # LIGHT_POINT
  
  Light* = object
    typ*: LightType      # type is a reserved word in Nim
    enabled*: bool
    position*: Vector3
    target*: Vector3
    color*: Color
    attenuation*: float32
    
    # Shader locations
    enabledLoc*: ShaderLocation
    typeLoc*: ShaderLocation
    positionLoc*: ShaderLocation
    targetLoc*: ShaderLocation
    colorLoc*: ShaderLocation
    attenuationLoc*: ShaderLocation

# Module Functions Declaration
proc createLight*(typ: LightType, position, target: Vector3, color: Color, shader: Shader): Light
proc updateLightValues*(shader: Shader, light: Light)

# Implementation
var lightsCount: int32 = 0    # Current amount of created lights

proc createLight*(typ: LightType, position, target: Vector3, color: Color, shader: Shader): Light =
  if lightsCount < MaxLights:
    result.enabled = true
    result.typ = typ
    result.position = position
    result.target = target
    result.color = color
    result.attenuation = 1
    
    # NOTE: Lighting shader naming must be the provided ones
    result.enabledLoc = getShaderLocation(shader, &"lights[{lightsCount}].enabled")
    result.typeLoc = getShaderLocation(shader, &"lights[{lightsCount}].type")
    result.positionLoc = getShaderLocation(shader, &"lights[{lightsCount}].position")
    result.targetLoc = getShaderLocation(shader, &"lights[{lightsCount}].target")
    result.colorLoc = getShaderLocation(shader, &"lights[{lightsCount}].color")
    result.attenuationLoc = getShaderLocation(shader, &"lights[{lightsCount}].attenuation")
    
    updateLightValues(shader, result)
    inc(lightsCount)

proc updateLightValues*(shader: Shader, light: Light) =
  # Send to shader light enabled state and type
  setShaderValue(shader, light.enabledLoc, int32(light.enabled))
  setShaderValue(shader, light.typeLoc, int32(light.typ))
  
  # Send to shader light position values
  let position: array[3, float32] = [light.position.x, light.position.y, light.position.z]
  setShaderValue(shader, light.positionLoc, position)
  
  # Send to shader light target position values
  let target: array[3, float32] = [light.target.x, light.target.y, light.target.z]
  setShaderValue(shader, light.targetLoc, target)
  
  # Send to shader light color values
  let color: array[4, float32] = [
    float32(light.color.r) / 255,
    float32(light.color.g) / 255,
    float32(light.color.b) / 255,
    float32(light.color.a) / 255
  ]
  setShaderValue(shader, light.colorLoc, color)
  
  # Send to shader light attenuation
  setShaderValue(shader, light.attenuationLoc, light.attenuation)
