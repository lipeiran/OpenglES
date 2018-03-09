
precision mediump float;

varying vec2 f_texcoord;

uniform sampler2D f_texture;

void main()
{
    gl_FragColor=texture2D(f_texture,f_texcoord);
}
