#ifdef GL_ES
  precision mediump float;
precision mediump int;
#endif

  //#define PROCESSING_TEXTURE_SHADER

  uniform sampler2D texture;
uniform vec2 texOffset;
uniform int pass;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main(void) {
  // Grouping texcoord variables in order to make it work in the GMA 950. See post #13
  // in this thread:
  // http://www.idevgames.com/forums/thread-3467.html
  vec2 tc0 = vertTexCoord.st + vec2(-texOffset.s, -texOffset.t) * pass;
  vec2 tc1 = vertTexCoord.st + vec2(         0.0, -texOffset.t) * pass;
  vec2 tc2 = vertTexCoord.st + vec2(+texOffset.s, -texOffset.t) * pass;
  vec2 tc3 = vertTexCoord.st + vec2(-texOffset.s, 0.0) * pass;
  vec2 tc4 = vertTexCoord.st + vec2(         0.0, 0.0) * pass;
  vec2 tc5 = vertTexCoord.st + vec2(+texOffset.s, 0.0) * pass;
  vec2 tc6 = vertTexCoord.st + vec2(-texOffset.s, +texOffset.t) * pass;
  vec2 tc7 = vertTexCoord.st + vec2(         0.0, +texOffset.t) * pass;
  vec2 tc8 = vertTexCoord.st + vec2(+texOffset.s, +texOffset.t) * pass  ;

  vec4 col0 = texture2D(texture, tc0);
  vec4 col1 = texture2D(texture, tc1);
  vec4 col2 = texture2D(texture, tc2);
  vec4 col3 = texture2D(texture, tc3);
  vec4 col4 = texture2D(texture, tc4);
  vec4 col5 = texture2D(texture, tc5);
  vec4 col6 = texture2D(texture, tc6);
  vec4 col7 = texture2D(texture, tc7);
  vec4 col8 = texture2D(texture, tc8);

  vec4 sum = (1.0 * col0 + 1.0 * col1 + 1.0 * col2 +
    1.0 * col3 + 1.0 * col4 + 1.0 * col5 +
    1.0 * col6 + 1.0 * col7 + 1.0 * col8) / 9.0;
  gl_FragColor = vec4(sum.rgb, 1.0) * vertColor;
  //gl_FragColor = vec4(sum.rgb, 1.0) * vertColor * .5 + texture2D(texture, vertTexCoord.st);
  //gl_FragColor = texture2D(texture, vertTexCoord.st);
}
