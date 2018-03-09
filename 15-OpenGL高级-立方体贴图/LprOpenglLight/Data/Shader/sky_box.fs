precision mediump float;

varying vec3 TexCoords;

uniform samplerCube skybox;

void main()
{
    gl_FragColor = textureCube(skybox, TexCoords);//vec4(vec3(1.0-texture2D(texture1, TexCoords)),1.0);
}
