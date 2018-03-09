
precision mediump float;

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    sampler2D emission;
    float shininess;
};

struct Light {
    vec3 position;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform vec3 lightColor;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform Material material;
uniform Light light;

varying vec3 Normal;
varying vec3 FragPos;
varying vec2 TexCoords;

void main()
{
    //环境光
    vec3 ambient = texture2D(material.diffuse,TexCoords).rgb * light.ambient;
    
    //法线和最终的方向向量都进行标准化
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    //norm和lightDir向量进行点乘，计算光源对当前片段实际的漫发射影响。结果值再乘以光的颜色，得到漫反射分量
    float diff = max(dot(norm, lightDir), 0.0);
    //漫反射
    vec3 diffuse = (diff * texture2D(material.diffuse,TexCoords).rgb) * light.diffuse;
    
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    //镜面反射
    vec3 tmpSpecularV3 = texture2D(material.specular,TexCoords).rgb;
    vec3 specular = (spec * tmpSpecularV3) * light.specular;
    
    //emission
    vec3 emission = texture2D(material.emission,TexCoords).rgb;
    
    vec3 result = (ambient+diffuse+specular);//+emission;
    gl_FragColor=vec4(result,1.0);
}
