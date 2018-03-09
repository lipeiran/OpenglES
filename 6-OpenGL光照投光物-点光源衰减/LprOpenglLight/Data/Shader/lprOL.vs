attribute vec3 aPos;
attribute vec3 aNormal;
attribute vec2 aTexCoords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying vec3 Normal;
varying vec3 FragPos;
varying vec2 TexCoords;

void main()
{
    FragPos = vec3(model*vec4(aPos,1.0));
    Normal = mat3(model) * aNormal;
    TexCoords = aTexCoords;
    gl_Position = projection*view*vec4(FragPos,1.0);
}
