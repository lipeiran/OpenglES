precision mediump float;

varying vec2 TexCoords;

uniform sampler2D texture1;

void main()
{
    gl_FragColor = texture2D(texture1, TexCoords);//vec4(vec3(1.0-texture2D(texture1, TexCoords)),1.0);
}
