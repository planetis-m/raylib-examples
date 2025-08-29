
## 1. Memory Management
### Handling Types Without Copy Hooks
Some types in naylib, like `Texture`, `Shader`, `Mesh`, `Font`, etc don't have `=copy` hooks to prevent accidental copying. To work around this, use references:
```nim
var texture: ref Texture
new(texture)
texture[] = loadTexture("resources/example.png")
let copy = texture # This works, copying the reference
```

## 2. Common Patterns and Idioms

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

## 3. Advanced Usage Patterns

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

