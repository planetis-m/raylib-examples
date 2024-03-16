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
const float vignetteOpacity = 1.0;
const float scanLineOpacity = 0.5;
const float curvature = 10.0;
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

vec3 vignetteIntensity(vec2 uv, vec2 resolution, float opacity) {
  float intensity = uv.x*uv.y*(1.0 - uv.x)*(1.0 - uv.y);
  return vec3(clamp(pow(resolution.x*intensity, opacity), 0.0, 1.0));
}

vec3 scanLineIntensity(float uv, float resolution, float opacity) {
  float intensity = sin(uv*resolution*2.0);
  intensity = ((0.5*intensity) + 0.5)*0.9 + 0.1;
  return vec3(pow(intensity, opacity));
}

vec3 distortIntensity(vec2 uv, float time) {
  vec2 rg = sin(uv*10.0 + time)*distortion + 1.0;
  float b = sin((uv.x + uv.y)*10.0 + time)*distortion + 1.0;
  return vec3(rg, b);
}

void main() {
  vec2 uv = curveRemapUV();
  vec3 baseColor = texture(texture0, uv).rgb;
  baseColor *= vignetteIntensity(uv, size, vignetteOpacity);
//   baseColor *= distortIntensity(uv, seconds);
  baseColor = pow(baseColor, vec3(gammaInput)); // gamma correction
  baseColor *= scanLineIntensity(uv.x, size.x, scanLineOpacity);
  baseColor *= scanLineIntensity(uv.y, size.y, scanLineOpacity);
  baseColor = pow(baseColor, vec3(1.0/gammaOutput)); // gamma correction
  baseColor *= vec3(brightness);

  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
    finalColor = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    finalColor = vec4(baseColor, 1.0);
  }
}
