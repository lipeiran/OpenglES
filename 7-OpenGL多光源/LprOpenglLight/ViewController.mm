//
//  ViewController.m
//  LprOpenglLight
//
//  Created by 李沛然 on 2018/2/2.
//  Copyright © 2018年 aranzi-go. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#include "Glm/glm.hpp"
#include "Glm/ext.hpp"
#include "stb_image.h"
#include "Utils.hpp"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

GLuint vbo,lprProgram,lprLightProgram;
GLint objectPosLocation,texCoordLocation,lprModelLocation,lprViewLocation,lprProjectionLocation,lightColorLocation,light_posLocation,light_lprModelLocation,light_lprViewLocation,light_lprProjectionLocation,objectNormalLocation,viewPosLocation,materialDiffuseLocation,materialSpecularLocation,materialShininessLocation,objectTexCoordsLocation,materialEmissionLocation;

unsigned int boxTexture1,boxTexture2,boxTexture3;

float lprPoints[] =
{
    // positions          // normals           // texture coords
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
    
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
    -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
    0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f
};
// positions all containers
glm::vec3 cubePositions[] = {
    glm::vec3( 0.0f,  0.0f,  0.0f),
    glm::vec3( 2.0f,  5.0f, -15.0f),
    glm::vec3(-1.5f, -2.2f, -2.5f),
    glm::vec3(-3.8f, -2.0f, -12.3f),
    glm::vec3( 2.4f, -0.4f, -3.5f),
    glm::vec3(-1.7f,  3.0f, -7.5f),
    glm::vec3( 1.3f, -2.0f, -2.5f),
    glm::vec3( 1.5f,  2.0f, -2.5f),
    glm::vec3( 1.5f,  0.2f, -1.5f),
    glm::vec3(-1.3f,  1.0f, -1.5f)
};
// positions of the point lights
glm::vec3 pointLightPositions[] = {
    glm::vec3( 0.7f,  0.2f,  2.0f),
    glm::vec3( 2.3f, -3.3f, -4.0f),
    glm::vec3(-4.0f,  2.0f, -12.0f),
    glm::vec3( 0.0f,  0.0f, -3.0f)
};
// camera
glm::vec3 viewPos(0.0f,0.0f,0.0f);
float _initRadius = 8.0f;
float _initAngle = 45.0f;

char* LoadAssetContent(const char*path)
{
    char*assetContent=nullptr;
    NSString*nsPath=[[[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil]retain];
    NSData *data=[[NSData dataWithContentsOfFile:nsPath]retain];
    assetContent=new char[[data length]+1];
    memcpy(assetContent, [data bytes], [data length]);
    assetContent[[data length]]='\0';
    [nsPath release];
    [data release];
    return assetContent;
}

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //init opengl begin
    //init opengl render context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];//3.0
    if(!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//2.0
    }
    if (!self.context)
    {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//24 bit depth buffer
    [EAGLContext setCurrentContext:self.context];//wglMakeCurrent
    
    [self initProgrameAndVBO];
    [self initTexture];
}

- (void)dealloc
{
    [super dealloc];
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context)
        {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Private methods

- (void)initProgrameAndVBO
{
    char *vsCode = LoadAssetContent("Data/Shader/lprOL.vs");
    char *fsCode = LoadAssetContent("Data/Shader/lprOL.fs");
    lprProgram = CreateGPUProgram(vsCode, fsCode);
    
    objectPosLocation = glGetAttribLocation(lprProgram, "aPos");
    objectNormalLocation = glGetAttribLocation(lprProgram, "aNormal");
    objectTexCoordsLocation = glGetAttribLocation(lprProgram, "aTexCoords");
    lprModelLocation = glGetUniformLocation(lprProgram, "model");
    lprViewLocation = glGetUniformLocation(lprProgram, "view");
    lprProjectionLocation = glGetUniformLocation(lprProgram, "projection");
    lightColorLocation = glGetUniformLocation(lprProgram, "lightColor");
    viewPosLocation = glGetUniformLocation(lprProgram, "viewPos");
    materialDiffuseLocation = glGetUniformLocation(lprProgram, "material.diffuse");
    materialSpecularLocation = glGetUniformLocation(lprProgram, "material.specular");
    materialShininessLocation = glGetUniformLocation(lprProgram, "material.shininess");
    materialEmissionLocation = glGetUniformLocation(lprProgram, "material.emission");
    
    char *lightVsCode = LoadAssetContent("Data/Shader/lprOLLight.vs");
    char *lightFsCode = LoadAssetContent("Data/Shader/lprOLLight.fs");
    lprLightProgram = CreateGPUProgram(lightVsCode, lightFsCode);
    
    light_posLocation = glGetAttribLocation(lprLightProgram, "aPos");
    light_lprModelLocation = glGetUniformLocation(lprLightProgram, "model");
    light_lprViewLocation = glGetUniformLocation(lprLightProgram, "view");
    light_lprProjectionLocation = glGetUniformLocation(lprLightProgram, "projection");

    vbo = CreateBufferObject(GL_ARRAY_BUFFER, sizeof(lprPoints), lprPoints, GL_STATIC_DRAW);
    
    delete vsCode;
    delete fsCode;
    delete lightVsCode;
    delete lightFsCode;
}

- (void)initTexture
{
    glGenTextures(1,&boxTexture1);
    glBindTexture(GL_TEXTURE_2D,boxTexture1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    int width, height, nrChannels;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"box" ofType:@"jpg"];
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data = stbi_load([path UTF8String], &width, &height, &nrChannels, 0);
    if (data)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"fail to load texture1");
    }
    stbi_image_free(data);
    
    glGenTextures(1,&boxTexture2);
    glBindTexture(GL_TEXTURE_2D,boxTexture2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    int width2, height2, nrChannels2;
    NSString *path2 = [[NSBundle mainBundle]pathForResource:@"container_specular" ofType:@"jpg"];
//    NSString *path2 = [[NSBundle mainBundle]pathForResource:@"container_specular_color" ofType:@"jpg"];//彩色边界
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data2 = stbi_load([path2 UTF8String], &width2, &height2, &nrChannels2, 0);
    if (data2)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width2, height2, 0, GL_RGB, GL_UNSIGNED_BYTE, data2);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"fail to load texture1");
    }
    stbi_image_free(data2);
    
    glGenTextures(1,&boxTexture3);
    glBindTexture(GL_TEXTURE_2D,boxTexture3);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    int width3, height3, nrChannels3;
    NSString *path3 = [[NSBundle mainBundle]pathForResource:@"matrix" ofType:@"jpg"];
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data3 = stbi_load([path3 UTF8String], &width3, &height3, &nrChannels3, 0);
    if (data3)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width3, height3, 0, GL_RGB, GL_UNSIGNED_BYTE, data3);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"fail to load texture1");
    }
    stbi_image_free(data3);
    
    glUseProgram(lprProgram);
    glUniform1i(materialDiffuseLocation,0);
    glUniform1i(materialSpecularLocation,1);
    glUniform1i(materialEmissionLocation, 2);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    //update : update drawable data
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    viewPos = glm::vec3(_initRadius * cos(_initAngle),viewPos.y,_initRadius * sin(_initAngle));
    _initAngle += 0.05f;
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.1f, 0.3f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glm::vec3 lightPosI(0.0f,0.0f,3.0f);

    glUseProgram(lprProgram);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glVertexAttribPointer(objectPosLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)0);
    glEnableVertexAttribArray(objectPosLocation);
    glVertexAttribPointer(objectNormalLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)(sizeof(float)*3));
    glEnableVertexAttribArray(objectNormalLocation);
    glVertexAttribPointer(objectTexCoordsLocation, 2, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)(sizeof(float)*6));
    glEnableVertexAttribArray(objectTexCoordsLocation);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glm::mat4 modelT,viewT,projectionT;

    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    glUniformMatrix4fv(lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));

    projectionT = glm::perspective(45.0f, (float)ScreenWidth/(float)ScreenHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));

    glUniform3f(lightColorLocation, 1.0f, 1.0f, 1.0f);
    glUniform3f(viewPosLocation, viewPos.x, viewPos.y,viewPos.z);
    glUniform1f(materialShininessLocation, 32.0f);
    // directional light
    glUniform3f(glGetUniformLocation(lprProgram, "dirLight.direction"), -0.2f, -1.0f, -0.3f);
    glUniform3f(glGetUniformLocation(lprProgram, "dirLight.ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f(glGetUniformLocation(lprProgram, "dirLight.diffuse"), 0.4f, 0.4f, 0.4f);
    glUniform3f(glGetUniformLocation(lprProgram, "dirLight.specular"), 0.5f, 0.5f, 0.5f);
    // point light 1
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[0].position"), pointLightPositions[0].x, pointLightPositions[0].y, pointLightPositions[0].z);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[0].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[0].diffuse"), 0.8f, 0.8f, 0.8f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[0].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[0].constant"), 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[0].linear"), 0.09);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[0].quadratic"), 0.032);
    // point light 2
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[1].position"), pointLightPositions[1].x, pointLightPositions[1].y, pointLightPositions[1].z);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[1].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[1].diffuse"), 0.8f, 0.8f, 0.8f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[1].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[1].constant"), 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[1].linear"), 0.09);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[1].quadratic"), 0.032);
    // point light 3
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[2].position"), pointLightPositions[2].x, pointLightPositions[2].y, pointLightPositions[2].z);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[2].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[2].diffuse"), 0.8f, 0.8f, 0.8f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[2].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[2].constant"), 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[2].linear"), 0.09);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[2].quadratic"), 0.032);
    // point light 4
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[3].position"), pointLightPositions[3].x, pointLightPositions[3].y, pointLightPositions[3].z);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[3].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[3].diffuse"), 0.8f, 0.8f, 0.8f);
    glUniform3f(glGetUniformLocation(lprProgram, "pointLights[3].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[3].constant"), 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[3].linear"), 0.09);
    glUniform1f(glGetUniformLocation(lprProgram, "pointLights[3].quadratic"), 0.032);
    // spotLight
    glUniform3f(glGetUniformLocation(lprProgram, "spotLight.position"), viewPos.x, viewPos.y, viewPos.z);
    glUniform3f(glGetUniformLocation(lprProgram, "spotLight.direction"), -viewPos.x, -viewPos.y, -viewPos.z);
    glUniform3f(glGetUniformLocation(lprProgram, "spotLight.ambient"), 0.0f, 0.0f, 0.0f);
    glUniform3f(glGetUniformLocation(lprProgram, "spotLight.diffuse"), 1.0f, 1.0f, 1.0f);
    glUniform3f(glGetUniformLocation(lprProgram, "spotLight.specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "spotLight.constant"), 1.0f);
    glUniform1f(glGetUniformLocation(lprProgram, "spotLight.linear"), 0.09);
    glUniform1f(glGetUniformLocation(lprProgram, "spotLight.quadratic"), 0.032);
    glUniform1f(glGetUniformLocation(lprProgram, "spotLight.cutOff"), glm::cos(12.5f));
    glUniform1f(glGetUniformLocation(lprProgram, "spotLight.outerCutOff"), glm::cos(15.0f));

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,boxTexture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,boxTexture2);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, boxTexture3);
    
    float nowAngle = 0.0f;
//    nowAngle+=0.5f;
    for (int i = 0; i < 10; i++)
    {
        // calculate the model matrix for each object and pass it to shader before drawing
        glm::mat4 model;
        model = glm::translate(model, cubePositions[i]);
        float angle = nowAngle+20.0f*i;
        model = glm::rotate(model, angle, glm::vec3(1.0f, -0.3f, 0.5f));
        glUniformMatrix4fv(lprModelLocation, 1, GL_FALSE, glm::value_ptr(model));
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    glUseProgram(0);
    
    glUseProgram(lprLightProgram);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glVertexAttribPointer(light_posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)0);
    glEnableVertexAttribArray(light_posLocation);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glUniformMatrix4fv(light_lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));
    glUniformMatrix4fv(light_lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));

    for (int i = 0; i < 4; i++)
    {
        glm::mat4 modelT1;
        modelT1 = glm::translate(modelT1, pointLightPositions[i]);
        modelT1 = glm::scale(modelT1, glm::vec3(0.2f));
        glUniformMatrix4fv(light_lprModelLocation, 1, GL_FALSE, glm::value_ptr(modelT1));
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    glUseProgram(0);

    
}

@end
