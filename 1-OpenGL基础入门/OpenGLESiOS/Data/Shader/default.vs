attribute vec3 pos;
attribute vec3 normal;

uniform mat4 M;
uniform mat4 V;
uniform mat4 P;
uniform mat4 NM;

varying vec3 V_Normal;
varying vec4 V_WorldPos;

void main()
{
    V_Normal=mat3(NM)*normal;
    V_WorldPos=M*vec4(pos,1.0);
    gl_Position=P*V*M*vec4(pos,1.0);
}
