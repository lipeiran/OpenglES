precision mediump float;

varying vec3 Normal;
varying vec3 Position;

uniform vec3 cameraPos;
uniform samplerCube texture1;

void main()
{
    vec3 I = normalize(Position-cameraPos);
    vec3 R = reflect(I,normalize(Normal));
//    gl_FragColor = texture2D(texture1, TexCoords);//vec4(vec3(1.0-texture2D(texture1, TexCoords)),1.0);
    gl_FragColor = vec4(textureCube(texture1,R).rgb,1.0);
}
