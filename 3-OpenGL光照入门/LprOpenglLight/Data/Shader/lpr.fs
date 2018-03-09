
precision mediump float;

varying vec2 f_texcoord;

uniform sampler2D f_texture;
uniform sampler2D f_secondTexture;

uniform float f_second_alpha;

void main()
{
    gl_FragColor=mix(texture2D(f_texture,f_texcoord),texture2D(f_secondTexture,f_texcoord),f_second_alpha);
}
