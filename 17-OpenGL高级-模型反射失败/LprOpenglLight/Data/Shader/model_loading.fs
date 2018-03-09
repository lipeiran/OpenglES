precision mediump float;

varying vec3 Normal;
varying vec3 Position;

uniform vec3 cameraPos;
uniform samplerCube texture1;

void main()
{
    float ratio = 1.00 / 1.52;
    vec3 I = normalize(Position - cameraPos);
    vec3 R = refract(I, normalize(Normal), ratio);
//    vec3 I = normalize(Position-cameraPos);
//    vec3 R = reflect(I,normalize(Normal));
    gl_FragColor = vec4(textureCube(texture1,R).rgb,1.0);
}
