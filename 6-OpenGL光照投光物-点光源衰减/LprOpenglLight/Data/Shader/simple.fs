
precision mediump float;

uniform vec4 U_Color;
uniform sampler2D U_MainTexture;

varying vec3 V_Color;

void main()
{
    gl_FragColor=vec4(U_Color.rgb+V_Color,1.0);
}
