const AndroidApi = 29
const AndroidNdk = "/opt/android-ndk"
when defined(windows):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/windows-x86_64"
elif defined(linux):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/linux-x86_64"
elif defined(macosx):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/darwin-x86_64"
const AndroidSysroot = AndroidToolchain & "/sysroot"

switch("arm.linux.clang.exe", AndroidToolchain & "/bin/armv7a-linux-androideabi" & $AndroidApi & "-clang")
switch("arm.linux.clang.cpp.exe", AndroidToolchain & "/bin/armv7a-linux-androideabi" & $AndroidApi & "-clang++")

switch("arm64.linux.clang.exe", AndroidToolchain & "/bin/aarch64-linux-android" & $AndroidApi & "-clang")
switch("arm64.linux.clang.cpp.exe", AndroidToolchain & "/bin/aarch64-linux-android" & $AndroidApi & "-clang++")

switch("i386.linux.clang.exe", AndroidToolchain & "/bin/i686-linux-android" & $AndroidApi & "-clang")
switch("i386.linux.clang.cpp.exe", AndroidToolchain & "/bin/i686-linux-android" & $AndroidApi & "-clang++")

switch("amd64.linux.clang.exe", AndroidToolchain & "/bin/x86_64-linux-android" & $AndroidApi & "-clang")
switch("amd64.linux.clang.cpp.exe", AndroidToolchain & "/bin/x86_64-linux-android" & $AndroidApi & "-clang++")

switch("clang.linkerexe", AndroidToolchain & "/bin/llvm-ar")

switch("arm.linux.clang.options.always", "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -I" &
    AndroidSysroot & "/usr/include/arm-linux-androideabi")
switch("arm64.linux.clang.options.always", "-target aarch64 -mfix-cortex-a53-835769 -I" &
    AndroidSysroot & "/usr/include/aarch64-linux-android")
switch("i386.linux.clang.options.always", "-march=i686 -I" & AndroidSysroot & "/usr/include/i686-linux-android")
switch("amd64.linux.clang.options.always", "-march=x86-64 -I" & AndroidSysroot & "/usr/include/x86_64-linux-android")

when defined(android):
  --define:GraphicsApiOpenGlEs2

  switch("define", "AndroidApi=" & $AndroidApi)
  switch("define", "AndroidNdk=" & AndroidNdk)

  --cpu:arm64
  --cc:clang

  switch("passC", "-I" & AndroidSysroot & "/usr/include")
  # --define:androidNDK
  --mm:orc
  # --threads:off
  --panics:on
  --define:noSignalHandler
