when defined(windows):
  --wasm32.linux.clang.exe:emcc.bat
  --wasm32.linux.clang.linkerexe:emcc.bat
  --wasm32.linux.clang.cpp.exe:emcc.bat
  --wasm32.linux.clang.cpp.linkerexe:emcc.bat
else:
  --wasm32.linux.clang.exe:emcc
  --wasm32.linux.clang.linkerexe:emcc
  --wasm32.linux.clang.cpp.exe:emcc
  --wasm32.linux.clang.cpp.linkerexe:emcc

when defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  --define:NaylibWebResources
  --os:linux
  --cpu:wasm32
  --cc:clang
  --mm:orc
  --threads:off
  --panics:on
  --define:noSignalHandler
  --passL:"-o public/index.html"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  # --passL:"--shell-file minshell.html"
