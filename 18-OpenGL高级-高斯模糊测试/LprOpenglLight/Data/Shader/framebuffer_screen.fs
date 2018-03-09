#version 300 es

precision mediump float;

out vec4 fragColor;

in vec2 TexCoords;

uniform sampler2D screenTexture;

uniform bool horizontal;

void main()
{
    float weight[5];
    weight[0] = 0.2270270270;
    weight[1] = 0.1945945946;
    weight[2] = 0.1216216216;
    weight[3] = 0.0540540541;
    weight[4] = 0.0162162162;
    ivec2 tmp_vec = textureSize(screenTexture, 0);
    float tmp_x = float(tmp_vec.x);
    float tmp_y = float(tmp_vec.y);
    vec2 tmp_T = vec2(tmp_x,tmp_y);
    vec2 tex_offset = 1.0 / tmp_T;//textureSize(screenTexture, 0); // gets size of single texel
    vec3 result = texture(screenTexture, TexCoords).rgb * weight[0];
    if(horizontal)
    {
        for(int i = 1; i < 5; ++i)
        {
            result += texture(screenTexture, TexCoords + vec2(tex_offset.x * float(i), 0.0)).rgb *weight[i];
            result += texture(screenTexture, TexCoords - vec2(tex_offset.x * float(i), 0.0)).rgb * weight[i];
        }
    }
    else
    {
        for(int i = 1; i < 5; ++i)
        {
            result += texture(screenTexture, TexCoords + vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
            result += texture(screenTexture, TexCoords - vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
        }
    }
    fragColor = vec4(result, 1.0);
}
