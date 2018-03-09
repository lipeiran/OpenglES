precision mediump float;

varying vec3 V_Normal;
varying vec4 V_WorldPos;

void main()
{
    //ambient color
    vec4 ambientLight=vec4(0.4,0.4,0.4,1.0);//ambient light
    vec4 ambientMaterial=vec4(0.4,0.4,0.4,1.0);//ambient material
    vec4 diffuseLight=vec4(1.0,1.0,1.0,1.0);//diffuse light
    vec4 diffuseMaterial=vec4(0.4,0.4,0.4,1.0);//diffuse material
    vec4 specularLight=vec4(1.0);//specular light color
    vec4 specularLightMaterial=vec4(1.0);
    vec4 ambientColor=ambientLight*ambientMaterial;
    //diffuse color
    vec3 L=vec3(0.0,1.0,0.0);
    vec3 n=normalize(V_Normal);
    float diffuseIntensity=max(0.0,dot(L,n));
    
    vec4 diffuseColor=diffuseLight*diffuseMaterial*diffuseIntensity;
    //specular color
    vec3 reflectDir=reflect(-L,n);
    reflectDir=normalize(reflectDir);
    //object -> eye
    vec3 viewDir=vec3(0.0,0.0,0.0)-V_WorldPos.xyz;
    viewDir=normalize(viewDir);
    float shiness=128.0;
    vec4 specularColor=specularLight*specularLightMaterial*pow(max(0.0,dot(viewDir,reflectDir)),shiness);
    
    gl_FragColor=ambientColor+diffuseColor+specularColor;
}
