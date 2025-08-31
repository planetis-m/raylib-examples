import mimalloc/config

when not defined(emscripten):
  --define:GraphicsApiOpenGl33
--experimental:overloadableEnums

--define:useMimalloc
--define:wayland
