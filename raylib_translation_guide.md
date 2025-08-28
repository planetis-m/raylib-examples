# Raylib C to Nim (naylib) Translation Guide

This document serves as a comprehensive guide for translating raylib C examples to Nim using the naylib wrapper. It details the patterns, idioms, and conventions used in the existing codebase to ensure consistency and maintainability.

## 1. File Structure and Organization

### Basic File Template
Every example follows a consistent structure:
```nim
# ****************************************************************************************
#
#   raylib [core] example - Basic window
#
#   Example complexity rating: [★☆☆☆] 1/4
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, std/[math, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450
 
proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [core] example - basic window")
  defer: closeWindow()  # Important pattern in naylib
  setTargetFPS(60)
  let font = loadFont("fonts/roboto.ttf")
  # Main game loop
  while not windowShouldClose():
    # Update
    # TODO: Update variables here

    # Draw
    drawing():  # Using template for safer begin-end pairs
      clearBackground(RayWhite)
      drawText(font, "Congrats! You created your first window!", Vector2(x: 190, y: 200), 20, 2.0, LightGray)

main()
```

### Key Structural Elements
1. **Standard Header Comment**: Always include the **full original raylib header**, adapted to Nim's comment syntax
2. **Import Section**: Include only the necessary naylib (`raylib`, `raymath`, etc.) and nim standard library modules used in the code
3. **Constants Section**: Screen dimensions and other constants at the top
4. **Main Procedure**: All logic encapsulated in a `main()` procedure
5. **Initialization Block**: Window initialization with `defer` for cleanup
6. **Game Loop**: Standard while loop with update/draw sections
7. **Resource Management**: Rely on automatic destructors for naylib objects like `Texture` or `Font`
8. **Function Overloading**: Use the base function names without suffixes like `V`, `Ex`, `Rec`, `Pro`, etc.

## 2. Naming Conventions

### Variables and Procedures
- Use `camelCase` for variables and procedure names:
  ```nim
  var framesCounter: int32 = 0
  proc updateCamera() = ...
  ```

### Constants
- Use `PascalCase` for constants:
  ```nim
  const
    MaxFrameSpeed = 15
    MinFrameSpeed = 1
    ScreenWidth = 800
  ```

### Types
- Use `PascalCase` for type names:
  ```nim
  type
    LightKind = enum
      Directional, Point, Spot
  ```

## 3. Type Translations

### Basic Types

C types are mapped to Nim types following these patterns:

```nim
# C: float -> Nim: float32
let posX: float32 = 100.0 # Preferred format for declarations

# C: int -> Nim: int32
let counter: int32 = 0

# C: unsigned int -> Nim: uint32
let flags: uint32 = 0

# C: boolean -> Nim: bool
let isVisible = true

# C: char* -> Nim: string
let title = "Window Title"
```

**Note:**

* Give explicit types (e.g., `float32`, `int32`) in declarations.
* In **expressions**, Nim applies its convertible relation:
  – Float literals like `2.0` are `float` (64-bit); ints are polymorphic.
  – `float64` and `float32` are implicitly convertible both ways; int literals convert to many numeric types.
  To **keep evaluation in the target type**, suffix the literal (`'f32`, `'i32`, `'u32`, …) or convert as needed.
* Avoid C-style suffixes (e.g., `0.0f`).

### Examples

```nim
# Float: avoid promotion to float (64-bit) and implicit narrowing back to float32
let scleraLeftPosition = Vector2(
  x: getScreenWidth() / 2'f32,
  y: getScreenHeight() / 2'f32
)

# Ints: literals are polymorphic
camera.zoom += getMouseWheelMove()*0.05'f32
if camera.zoom > 3: camera.zoom = 3
elif camera.zoom < 0.1'f32: camera.zoom = 0.1'f32
```

### Mapping C Types to Nim Types

| C Type | Nim Type | Notes |
|--------|----------|-------|
| `int` | `int32` | Explicitly use 32-bit integers |
| `short` | `int16` | The standard for 16-bit integers |
| `long long` | `int64` | The standard for 64-bit integers |
| `unsigned int` | `uint32` | For non-negative 32-bit integers |
| `float` | `float32` | Explicitly use 32-bit floats |
| `double` | `float` or `float64` | Nim's default `float` is a 64-bit double |
| `bool` | `bool` | Direct translation |
| `char*`, `const char*` | `string` | Replace C strings with Nim's safe, managed strings. |
| `void*` (generic data) | `generics` | Use type-safe generics instead of raw pointers. |
| `struct T` | `type T = object` | Direct translation to Nim's object type. |
| `enum E` | `type E = enum` | Direct translation to Nim's safer enum type. |
| `T*` (heap object) | `ref T` | For pointers to shared, managed objects. |
| `T*` (out-parameter) | `var T` | For modifying values in-place (pass-by-reference). |
| `T*` (array) | `seq[T]` | Replace C-style arrays with Nim's dynamic sequences. |
| `T arr[N]` (fixed array) | `array[N, T]` | Use for fixed-size, stack-allocated arrays. |

### Creating Struct Instances

```nim
# Good: This is the standard, clear way to create objects in Nim.
var camera = Camera(
  position: Vector3(x: 5.0, y: 5.0, z: 5.0),
  target: Vector3(x: 0.0, y: 0.0, z: 0.0),
  up: Vector3(x: 0.0, y: 1.0, z: 0.0),
  fovy: 45.0,
  projection: Perspective
)

# Also works, but is less ideal:
var camera: Camera
camera.position = Vector3(x: 5.0, y: 5.0, z: 5.0)
camera.target = Vector3(x: 0.0, y: 0.0, z: 0.0)
camera.up = Vector3(x: 0.0, y: 1.0, z: 0.0)
camera.fovy = 45.0
camera.projection = Perspective
```

## 4. Function Call Patterns

### Simple Function Calls
Direct translation with camelCase:
```c
// C
InitWindow(ScreenWidth, ScreenHeight, "Title");
```
```nim
# Nim
initWindow(ScreenWidth, ScreenHeight, "Title")
```

### Function Overloading
In C, similar functions have different names. In Nim, these are combined into one function name with multiple parameter sets.
```c
// C
DrawTexture(texture, posX, posY, WHITE);
DrawTextureV(texture, position, WHITE);
DrawTextureEx(texture, position, rotation, scale, WHITE);
DrawTextureRec(texture, sourceRec, position, WHITE);
DrawTexturePro(texture, sourceRec, destRec, origin, rotation, WHITE);
```
```nim
# Nim (naylib) - overloaded procedures
drawTexture(texture, posX, posY, White)
drawTexture(texture, position, White)
drawTexture(texture, position, rotation, scale, White)
drawTexture(texture, sourceRec, position, White)
drawTexture(texture, sourceRec, destRec, origin, rotation, White)
```

**Reminder:**

- Remove raylib function suffixes (`V`, `Ex`, `Rec`, `Pro`, etc) in Nim.
- Just call the base name (e.g., `drawCircle`, `drawTexture`, `drawLine`), and the correct overload will be resolved based on the parameters.

## 5. Control Flow Patterns

### Input Handling
Use direct translations of input functions with camelCase naming and Nim's boolean expressions:

```c
// C
if (IsKeyPressed(KEY_SPACE))
    // Handle space key press

if (IsKeyDown(KEY_LEFT))
    // Handle left key being held down

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
    // Handle left mouse button press
```

```nim
# Nim
if isKeyPressed(Space):
  # Handle space key press

if isKeyDown(Left):
  # Handle left key being held down

if isMouseButtonPressed(Left):
  # Handle left mouse button press
```

### Conditional Drawing
Use templates for scoped operations:
```nim
drawing():  # Equivalent to beginDrawing()/endDrawing()
  clearBackground(RayWhite)
  # Drawing code here

mode3D(camera):  # Equivalent to beginMode3D()/endMode3D()
  drawModel(model, position, scale, White)
```

## 6. Memory Management

### Automatic Cleanup with Destructors
Naylib uses destructors for automatic memory management of types like `Image`, `Wave`, `Texture`, etc. This eliminates the need for manual `Unload` calls:
```nim
let texture = loadTexture("image.png")
# No need to manually unload - automatically cleaned up by destructor
```

### Using Explicit Cleanup
For cases where you want explicit control or need to ensure cleanup at a specific point:
```nim
var image = loadImage("resources/heightmap.png") # Load image (RAM)
let texture = loadTextureFromImage(image) # Convert image to texture (VRAM)
reset(image) # Unload image from RAM, already uploaded to VRAM
```

### Handling Types Without Copy Hooks
Some types in naylib, like `Texture`, `Shader`, `Mesh`, `Font`, etc don't have `=copy` hooks to prevent accidental copying. To work around this, use references:
```nim
var texture: ref Texture
new(texture)
texture[] = loadTexture("resources/example.png")
let copy = texture # This works, copying the reference
```

## 7. Mathematical Operations

When translating raymath functions from C to Nim, use operators where available and drop the type prefixes from function names.

```c
// C
Vector3 sum   = Vector3Add(a, b);
Vector3 diff  = Vector3Subtract(a, b);
Vector3 scale = Vector3Scale(a, factor);
Vector3 mul   = Vector3Multiply(a, b);
Vector3 div   = Vector3Divide(a, b);
Vector3 trans = Vector3Transform(a, matrix);
float   dist  = Vector3Distance(a, b);
Vector3 neg   = Vector3Negate(a);
Quaternion q  = QuaternionMultiply(q1, q2);
```

```nim
# Nim
let sum   = a + b
let diff  = a - b
let scale = a * factor
let mul   = a * b
let div   = a / b
let trans = a * matrix
let dist  = distance(a, b)
let neg   = -a
let q     = q1 * q2
if a =~ b: discard  # approximate equality
```

### Using std/lenientops for Mixed-Type Arithmetic

Import `std/lenientops` to allow direct arithmetic between ints and floats avoiding repetitive type conversions.

```nim
import std/lenientops

var
  count: int32 = 10
  scaleFactor: float32 = 3.5
  offset: int32 = 100
  adjustment: float32 = 50.5

# Without lenientops, you'd need explicit casts:
let result1 = float32(count) * scaleFactor
let result2 = offset + int32(adjustment)

# With lenientops, direct operations work:
let result1 = count * scaleFactor    # Works directly
let result2 = offset + adjustment    # Works directly
```

### Raylib Style Arithmetic Spacing

Following raylib's coding style, omit spaces around * and /, but include spaces around + and -.

```nim
# Good raylib style
let centerX = screenWidth/2 - buttonWidth/2
let centerY = screenHeight/2 - buttonHeight/2
let scaledValue = baseValue*1.5

# Less preferred
let centerX = screenWidth / 2 - buttonWidth / 2
let centerY = screenHeight / 2 - buttonHeight / 2
let scaledValue = baseValue * 1.5
```

### Splitting Long Expressions in Nim

In Nim, only break lines after an operator (put operator at end of line), comma, or open parenthesis, and indent the continuation line. Never start the next line with an operator.

```nim
# Incorrect (causes errors):
let a1 = (-G*(2*m1 + m2)*sin(theta1)
          - m2*G*sin(theta1 - 2*theta2)
          - 2*sinD*m2*(ww2*L2 + ww1*L1*cosD))
         / (L1*(2*m1 + m2 - m2*cos2D))

# Correct:
let a1 = (-G*(2*m1 + m2)*sin(theta1) -
          m2*G*sin(theta1 - 2*theta2) -
          2*sinD*m2*(ww2*L2 + ww1*L1*cosD)) /
         (L1*(2*m1 + m2 - m2*cos2D))
```

## 8. Error Handling

### Resource Loading Validation
Naylib's `load*` functions automatically validate asset loading and raise `RaylibError` if they fail:
```nim
# This will automatically raise RaylibError if loading fails
let texture = loadTexture("image.png")

# We skip explicit error handling in the examples for brevity.
```

### Assertions
Use assertions for preconditions:
```nim
import std/assertions
assert(windowIsReady(), "Window should be initialized")
```

## 9. Common Patterns and Idioms

### Texture Ownership in Models

When assigning a texture to a model, the operation only performs a shallow copy of the texture handle. The model does not take ownership of the resource; it simply holds another copy of the handle. The texture must remain valid and in scope for as long as the model uses it.

```nim
var model = loadModel("resources/models/plane.obj") # Load model
let texture = loadTexture("resources/models/plane_diffuse.png") # Load texture
model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture # Assign diffuse texture
```

When creating a model from a mesh, ownership is moved. The `sink Mesh` parameter consumes the argument, and with copy operations disabled on Mesh, the compiler enforces that the mesh is transferred into the model. The original variable becomes invalid, and the model is now responsible for unloading the mesh.

```nim
let mesh = genMeshHeightmap(image, Vector3(x: 16, y: 8, z: 16)) # Generate heightmap mesh (RAM and VRAM)
var model = loadModelFromMesh(mesh) # Mesh is consumed and owned by the model
```

## 10. String Formatting and Text

### Formatted text drawing

Use Nim string interpolation:

```c
// C
DrawText(TextFormat("TARGET FPS: %i", targetFPS), x, y, fontSize, color);
```

```nim
# Nim
import std/strformat
drawText(&"TARGET FPS: {targetFPS}", x, y, fontSize, color)
```

## 11. Audio Patterns

### Audio Device Management
```nim
initAudioDevice()
defer: closeAudioDevice()  # Still needed as it's a global resource
```

## 12. Shader Patterns

### Shader Loading
```nim
when defined(GraphicsApiOpenGl33):
  const glslVersion = 330
else:
  const glslVersion = 100

let shader = loadShader(&"resources/shaders/glsl{glslVersion}/lighting.vs",
    &"resources/shaders/glsl{glslVersion}/lighting.fs")
# No need for defer - automatically cleaned up by destructor
```

## Shader Value Setting

```c
// C
int colorLoc = GetShaderLocation(shader, "color");
float color[4] = { 1.0f, 0.0f, 0.0f, 1.0f };
SetShaderValue(shader, colorLoc, color, SHADER_UNIFORM_VEC4); // must pass the uniform type explicitly
```

```nim
# Nim
let colorLoc = getShaderLocation(shader, "color")
let color: array[4, float32] = [1.0, 0.0, 0.0, 1.0]
setShaderValue(shader, colorLoc, color) # uniform type inferred as Vec4
```

`setShaderValue` infers the uniform type from the Nim value at compile time (e.g., `float32`, `array[3, float32]`, `array[4, int32]`) and forwards it to the low-level implementation, so you don’t need to pass the uniform type explicitly.

## 13. Configuration and Platform-Specific Features

### Setting Configuration Flags
Use the `flags` procedure to work with bitflags like `ConfigFlags`:
```c
// C
SetConfigFlags(FLAG_MSAA_4X_HINT | FLAG_WINDOW_HIGHDPI)
```
```nim
# Nim
setConfigFlags(flags(Msaa4xHint, WindowHighdpi))
initWindow(screenWidth, screenHeight, "Window title")
```

## 14. Advanced Usage Patterns

### Properly Calling closeWindow
Since Naylib wraps most types with destructors, `closeWindow` should be called at the very end:
```nim
# Recommended approach
initWindow(800, 450, "example")
defer: closeWindow()
let texture = loadTexture("resources/example.png")
# Game logic goes here
```

## Working with Embedded Resources

Wrap embedded byte arrays (exported via `exportImageAsCode`/`exportWaveAsCode`) as non-owning views using `toWeakImage`/`toWeakWave`. Then pass the underlying Image/Wave to the usual loaders.

```nim
# Embedded arrays are part of the binary. Metadata must match the embedded data.
let image = toWeakImage(ImageData, ImageWidth, ImageHeight, ImageFormat)
let texture = loadTextureFromImage(Image(image)) # pass Image (convert from WeakImage)
```

## Custom Pixel Formats

Define how your types map to GPU formats with `pixelKind`. The API infers the format from the element type and validates size/format on upload.

```nim
type RGBAPixel* = distinct byte
template pixelKind*(x: typedesc[RGBAPixel]): PixelFormat = UncompressedR8g8b8a8

# External provider returns interleaved RGBA8 data for the given size
proc loadExternalRGBA8(width, height: int): seq[RGBAPixel]

let rgba = loadExternalRGBA8(width, height) # len must be width*height*4
let tex = loadTextureFromData(rgba, width, height) # inferred RGBA8 from RGBAPixel
updateTexture(tex, rgba) # format and size validated by the API
```

