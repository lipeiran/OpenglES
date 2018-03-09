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
GLint objectPosLocation,texCoordLocation,lprModelLocation,lprViewLocation,lprProjectionLocation,lightColorLocation,objectColorLocation,light_posLocation,light_lprModelLocation,light_lprViewLocation,light_lprProjectionLocation,lightPosLocation,objectNormalLocation,viewPosLocation,materialAmbientLocation,materialDiffuseLocation,materialSpecularLocation,materialShininessLocation,materialLightAmbientLocation,materialLightDiffuseLocation,materialLightSpecularLocation,materialLightPositionLocation;

float lprPoints[] =
{
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
    
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
};

// lighting
float _initAngle = 45.0f;
float _radiusLength = 1.6f;
float _lightSpeed = 0.00f;

float lightFactor = 1.0f;

// camera
glm::vec3 viewPos(-2.0f,-4.0f,4.0f);

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
    lprModelLocation = glGetUniformLocation(lprProgram, "model");
    lprViewLocation = glGetUniformLocation(lprProgram, "view");
    lprProjectionLocation = glGetUniformLocation(lprProgram, "projection");
    lightColorLocation = glGetUniformLocation(lprProgram, "lightColor");
    objectColorLocation = glGetUniformLocation(lprProgram, "objectColor");
    lightPosLocation = glGetUniformLocation(lprProgram, "lightPos");
    viewPosLocation = glGetUniformLocation(lprProgram, "viewPos");
    materialAmbientLocation = glGetUniformLocation(lprProgram, "material.ambient");
    materialDiffuseLocation = glGetUniformLocation(lprProgram, "material.diffuse");
    materialSpecularLocation = glGetUniformLocation(lprProgram, "material.specular");
    materialShininessLocation = glGetUniformLocation(lprProgram, "material.shininess");
    materialLightAmbientLocation = glGetUniformLocation(lprProgram, "light.ambient");
    materialLightDiffuseLocation = glGetUniformLocation(lprProgram, "light.diffuse");
    materialLightSpecularLocation = glGetUniformLocation(lprProgram, "light.specular");
    materialLightPositionLocation = glGetUniformLocation(lprProgram, "light.position");
    
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

    glVertexAttribPointer(objectPosLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, (void*)0);
    glEnableVertexAttribArray(objectPosLocation);
    glVertexAttribPointer(objectNormalLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, (void*)(sizeof(float)*3));
    glEnableVertexAttribArray(objectNormalLocation);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glm::mat4 modelT,viewT,projectionT;

    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    glUniformMatrix4fv(lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));

    glUniformMatrix4fv(lprModelLocation, 1, GL_FALSE, glm::value_ptr(modelT));

    projectionT = glm::perspective(45.0f, (float)ScreenWidth/(float)ScreenHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));

    glUniform3f(lightColorLocation, 1.0f, 1.0f, 1.0f);
    glUniform3f(objectColorLocation, 1.0f, 0.5f, 0.31f);
    glUniform3f(lightPosLocation, lightPosI.x, lightPosI.y,lightPosI.z);
    glUniform3f(viewPosLocation, viewPos.x, viewPos.y,viewPos.z);
    glUniform3f(materialAmbientLocation, 1.0f,0.5f,0.31f);
    glUniform3f(materialDiffuseLocation, 1.0f,0.5f,0.31f);
    glUniform3f(materialSpecularLocation, 0.5f,0.5f,0.5f);
    glUniform1f(materialShininessLocation, 32.0f);
    
    glm::vec3 lightColor;
    lightFactor+=0.1f;
    lightColor.x = sin(lightFactor * 2.0f);
    lightColor.y = sin(lightFactor * 0.7f);
    lightColor.z = sin(lightFactor * 1.3f);
    
    glm::vec3 diffuseColor = lightColor * glm::vec3(0.5f);
    glm::vec3 ambientColor = diffuseColor * glm::vec3(0.2f);
    glUniform3f(materialLightAmbientLocation, ambientColor.x,ambientColor.y,ambientColor.z);
    glUniform3f(materialLightDiffuseLocation, diffuseColor.x,diffuseColor.y,diffuseColor.z);
    glUniform3f(materialLightSpecularLocation, 1.0f,1.0f,1.0f);

    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glUseProgram(0);
    
    glUseProgram(lprLightProgram);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glVertexAttribPointer(light_posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, (void*)0);
    glEnableVertexAttribArray(light_posLocation);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glUniformMatrix4fv(light_lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));
    glm::mat4 modelT1;
    modelT1 = glm::translate(modelT1, lightPosI);
    modelT1 = glm::scale(modelT1, glm::vec3(0.2f,0.2f,0.2f));
    glUniformMatrix4fv(light_lprModelLocation, 1, GL_FALSE, glm::value_ptr(modelT1));
    glUniformMatrix4fv(light_lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));

    glDrawArrays(GL_TRIANGLES, 0, 36);

    glUseProgram(0);

    
}

@end
