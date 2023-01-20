when defined(android):
  --define:GraphicsApiOpenGlEs2
  # --define:"AndroidApi=29"
  # --define:"AndroidNdk=\"/opt/android-ndk\""

  const AndroidApi = 29
  const AndroidNdk = "/opt/android-ndk"
  when defined(windows):
    const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/windows-x86_64"
  elif defined(linux):
    const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/linux-x86_64"
  elif defined(macosx):
    const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/darwin-x86_64"

  --cpu:arm64
  --cc:clang

  # switch("clang.exe", AndroidToolchain & "/bin/armv7a-linux-androideabi" & $AndroidApi & "-clang")
  # switch("clang.cpp.exe", AndroidToolchain & "/bin/armv7a-linux-androideabi" & $AndroidApi & "-clang++")

  switch("clang.exe", AndroidToolchain & "/bin/aarch64-linux-android" & $AndroidApi & "-clang")
  switch("clang.cpp.exe", AndroidToolchain & "/bin/aarch64-linux-android" & $AndroidApi & "-clang++")

  # switch("clang.exe", AndroidToolchain & "/bin/i686-linux-android" & $AndroidApi & "-clang")
  # switch("clang.cpp.exe", AndroidToolchain & "/bin/i686-linux-android" & $AndroidApi & "-clang++")

  # switch("clang.exe", AndroidToolchain & "/bin/x86_64-linux-android" & $AndroidApi & "-clang")
  # switch("clang.cpp.exe", AndroidToolchain & "/bin/x86_64-linux-android" & $AndroidApi & "-clang++")

  switch("clang.linkerexe", AndroidToolchain & "/bin/llvm-ar")

  const AndroidSysroot = AndroidToolchain & "/sysroot"
  switch("passC", "-I" & AndroidSysroot & "/usr/include")

  # switch("clang.options.always", "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16")
  # switch("passC", "-I" & AndroidSysroot & "/usr/include/arm-linux-androideabi")

  switch("clang.options.always", "-target aarch64 -mfix-cortex-a53-835769")
  switch("passC", "-I" & AndroidSysroot & "/usr/include/aarch64-linux-android")

  # switch("clang.options.always", "-march=i686")
  # switch("passC", "-I" & AndroidSysroot & "/usr/include/i686-linux-android")

  # switch("clang.options.always", "-march=x86-64")
  # switch("passC", "-I" & AndroidSysroot & "/usr/include/x86_64-linux-android")

  # --define:androidNDK
  --mm:orc
  # --threads:off
  --panics:on
  --define:noSignalHandler
