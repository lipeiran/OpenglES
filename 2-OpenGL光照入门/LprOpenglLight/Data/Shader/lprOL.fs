
precision mediump float;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;
uniform vec3 viewPos;

varying vec3 Normal;
varying vec3 FragPos;

void main()
{
    float ambientStrength = 0.1;
    float specularStrength = 0.5;
    
    //环境光
    vec3 ambient = ambientStrength * lightColor;
    
    //法线和最终的方向向量都进行标准化
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    //norm和lightDir向量进行点乘，计算光源对当前片段实际的漫发射影响。结果值再乘以光的颜色，得到漫反射分量
    float diff = max(dot(norm, lightDir), 0.0);
    //漫反射
    vec3 diffuse = diff * lightColor;
    
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 256.0);
    //镜面反射
    vec3 specular = specularStrength * spec * lightColor;
    
    vec3 result = (ambient+diffuse+specular) * objectColor;
    gl_FragColor=vec4(result,1.0);
}
