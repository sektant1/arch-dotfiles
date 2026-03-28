export const QUAD_VS = `#version 300 es
precision highp float;
layout(location=0) in vec2 a_pos;
layout(location=1) in vec2 a_uv;
layout(location=2) in vec4 a_color;
uniform vec2 u_resolution;
out vec2 v_uv;
out vec4 v_color;
void main() {
  vec2 ndc = (a_pos / u_resolution) * 2.0 - 1.0;
  ndc.y = -ndc.y;
  gl_Position = vec4(ndc, 0.0, 1.0);
  v_uv = a_uv;
  v_color = a_color;
}`;

export const QUAD_FS = `#version 300 es
precision highp float;
in vec2 v_uv;
in vec4 v_color;
uniform sampler2D u_tex;
uniform int u_alphaMode;
out vec4 fragColor;
void main() {
  vec4 c = texture(u_tex, v_uv) * v_color;
  if (u_alphaMode == 1 && c.a < 0.5) discard;
  fragColor = c;
}`;

export const TILED_FS = `#version 300 es
precision highp float;
in vec2 v_uv;
in vec4 v_color;
uniform sampler2D u_tex;
uniform vec2 u_quadSize;
uniform vec2 u_tileSize;
uniform int u_alphaMode;
out vec4 fragColor;
void main() {
  vec2 tiledUV = fract(v_uv * (u_quadSize / u_tileSize));
  vec4 c = texture(u_tex, tiledUV) * v_color;
  if (u_alphaMode == 1 && c.a < 0.5) discard;
  fragColor = c;
}`;

export const ELLIPSE_FS = `#version 300 es
precision highp float;
in vec2 v_uv;
in vec4 v_color;
uniform sampler2D u_tex;
uniform vec2 u_ellipseCenter;
uniform vec2 u_ellipseRadius;
uniform float u_uvOffset;
out vec4 fragColor;
void main() {
  vec2 scrolledUV = vec2(v_uv.x + u_uvOffset, v_uv.y);
  scrolledUV.x = fract(scrolledUV.x);
  vec4 c = texture(u_tex, scrolledUV) * v_color;
  vec2 d = (v_uv - u_ellipseCenter) / u_ellipseRadius;
  if (dot(d, d) > 1.0) discard;
  fragColor = c;
}`;
