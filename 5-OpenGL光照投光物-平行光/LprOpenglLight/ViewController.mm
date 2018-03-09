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
GLint objectPosLocation,texCoordLocation,lprModelLocation,lprViewLocation,lprProjectionLocation,lightColorLocation,light_posLocation,light_lprModelLocation,light_lprViewLocation,light_lprProjectionLocation,lightPosLocation,objectNormalLocation,viewPosLocation,materialDiffuseLocation,materialSpecularLocation,materialShininessLocation,materialLightAmbientLocation,materialLightDiffuseLocation,materialLightSpecularLocation,materialLightPositionLocation,materialLightDirectionLocation,objectTexCoordsLocation,materialEmissionLocation;

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

// lighting
float _initAngle = 45.0f;
float _radiusLength = 1.6f;
float _lightSpeed = 0.07f;

float lightFactor = 1.0f;

// camera
glm::vec3 viewPos(-2.0f,-2.0f,8.0f);

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
    lightPosLocation = glGetUniformLocation(lprProgram, "lightPos");
    viewPosLocation = glGetUniformLocation(lprProgram, "viewPos");
    materialDiffuseLocation = glGetUniformLocation(lprProgram, "material.diffuse");
    materialSpecularLocation = glGetUniformLocation(lprProgram, "material.specular");
    materialShininessLocation = glGetUniformLocation(lprProgram, "material.shininess");
    materialEmissionLocation = glGetUniformLocation(lprProgram, "material.emission");
    materialLightAmbientLocation = glGetUniformLocation(lprProgram, "light.ambient");
    materialLightDiffuseLocation = glGetUniformLocation(lprProgram, "light.diffuse");
    materialLightSpecularLocation = glGetUniformLocation(lprProgram, "light.specular");
    materialLightPositionLocation = glGetUniformLocation(lprProgram, "light.position");
    materialLightDirectionLocation = glGetUniformLocation(lprProgram, "light.direction");
    
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
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.1f, 0.3f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    _initAngle+=_lightSpeed;
    glm::vec3 lightPosI(_radiusLength*cos(_initAngle), 1.0f, _radiusLength*sin(_initAngle));

    glUseProgram(lprProgram);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glVertexAttribPointer(objectPosLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)0);
    glEnableVertexAttribArray(objectPosLocation);
    glVertexAttribPointer(objectNormalLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)(sizeof(float)*3));
    glEnableVertexAttribArray(objectNormalLocation);
    glVertexAttribPointer(objectTexCoordsLocation, 2, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)(sizeof(float)*6));
    glEnableVertexAttribArray(objectTexCoordsLocation);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glUniform3f(lightColorLocation, 1.0f, 1.0f, 1.0f);
    glUniform3f(materialLightDirectionLocation, -0.2f, -1.0f, -0.3f);
    glUniform3f(viewPosLocation, viewPos.x, viewPos.y,viewPos.z);

    glUniform3f(materialLightAmbientLocation, 0.2f,0.2f,0.2f);
    glUniform3f(materialLightDiffuseLocation, 0.5f,0.5f,0.5f);
    glUniform3f(materialLightSpecularLocation, 1.0f,1.0f,1.0f);
    glUniform1f(materialShininessLocation, 32.0f);

    glm::mat4 model,viewT,projectionT;

    projectionT = glm::perspective(45.0f, (float)ScreenWidth/(float)ScreenHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));
    
    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    glUniformMatrix4fv(lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,boxTexture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,boxTexture2);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, boxTexture3);

    static float nowAngle = 0.0f;
    nowAngle+=0.5f;
    for (unsigned int i = 0; i < 10; i++)
    {
        // calculate the model matrix for each object and pass it to shader before drawing
        glm::mat4 model;
        model = glm::translate(model, cubePositions[i]);
        float angle = nowAngle+20.0f*i;
        model = glm::rotate(model, angle, glm::vec3(1.0f, -0.3f, 0.5f));
//        model = glm::transpose(glm::inverse(model));
        glUniformMatrix4fv(lprModelLocation, 1, GL_FALSE, glm::value_ptr(model));

        glDrawArrays(GL_TRIANGLES, 0, 36);
    }

    glUseProgram(0);
    
//    glUseProgram(lprLightProgram);
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//
//    glVertexAttribPointer(light_posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (void*)0);
//    glEnableVertexAttribArray(light_posLocation);
//
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
//
//    glUniformMatrix4fv(light_lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));
//    glm::mat4 modelT1;
//    modelT1 = glm::translate(modelT1, glm::vec3(-0.2f, -1.0f, -0.3f));
//    modelT1 = glm::scale(modelT1, glm::vec3(0.2f,0.2f,0.2f));
//    glUniformMatrix4fv(light_lprModelLocation, 1, GL_FALSE, glm::value_ptr(modelT1));
//    glUniformMatrix4fv(light_lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));
//
//    glDrawArrays(GL_TRIANGLES, 0, 36);
//
//    glUseProgram(0);

    
}

@end
