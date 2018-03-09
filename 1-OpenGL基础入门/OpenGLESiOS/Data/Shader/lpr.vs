attribute vec3 lprpos;
attribute vec2 texcoord;

varying vec2 f_texcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    f_texcoord = texcoord;
    gl_Position = projection*view*model*vec4(lprpos,1.0);//*vec4(1.0,-1.0,1.0,1.0)+vec4(horF,0.0,0.0,0.0);
}
