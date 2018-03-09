precision mediump float;

uniform sampler2D U_MainTexture;
uniform sampler2D Texturrrre;

void main()
{
    gl_FragColor=texture2D(Texturrrre,vec2(gl_PointCoord.x,-gl_PointCoord.y));
}
