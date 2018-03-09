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
#include "Shader.hpp"

#define FBODefine

// utility function for loading a 2D texture from file
// ---------------------------------------------------
unsigned int loadTexture(char const *path)
{
    unsigned int textureID;
    glGenTextures(1, &textureID);
    
    int width, height, nrComponents;
    unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
    if (data)
    {
        GLenum format = GL_RGBA;
        if (nrComponents == 1)
            format = GL_LUMINANCE;
        else if (nrComponents == 3)
            format = GL_RGB;
        else if (nrComponents == 4)
            format = GL_RGBA;
        
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        stbi_image_free(data);
    }
    else
    {
        stbi_image_free(data);
    }
    
    return textureID;
}

const float SCR_WIDTH = [UIScreen mainScreen].bounds.size.width;
const float SCR_HEIGHT = [UIScreen mainScreen].bounds.size.height;
const float SCR_SCALE = [UIScreen mainScreen].scale;

glm::vec3 viewPos(3.0f,3.0f,8.0f);

GLint pos_Location,texCoord_Location,s_pos_Location,s_texCoord_Location,defaultFBO;
GLuint cube_Texture,floor_Texture,quad_Texture,cubeVAO,cubeVBO,planeVAO,planeVBO,quadVAO,quadVBO,framebuffer,rbo;

// set up vertex data (and buffer(s)) and configure vertex attributes
// ------------------------------------------------------------------
float cubeVertices[] = {
    // positions          // texture Coords
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};
float planeVertices[] = {
    // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
    5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
    -5.0f, -0.5f,  5.0f,  0.0f, 0.0f,
    -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
    
    5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
    -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
    5.0f, -0.5f, -5.0f,  2.0f, 2.0f
};

float quadVertices[] = { // vertex attributes for a quad that fills the entire screen in Normalized Device Coordinates.
    // positions   // texCoords
    -1.0f,-1.0f,0.0f,0.0f,0.0f,
    1.0f,-1.0f,0.0f,1.0f,0.0f,
    1.0f,1.0f,0.0f,1.0f,1.0f,
    
    -1.0f,-1.0f,0.0f,0.0f,0.0f,
    1.0f,1.0f,0.0f,1.0f,1.0f,
    -1.0f,1.0f,0.0f,0.0f,1.0f
};

@interface ViewController ()
{
  
}

@property (strong, nonatomic) EAGLContext *context;
@property Shader *ourShader;
@property Shader *screenShader;
@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    [EAGLContext setCurrentContext:self.context];
    [self _initData];
}

#pragma mark - Private methods

- (void)_initData
{
    // configure global opengl state
    glEnable(GL_DEPTH_TEST);

    [self _initShader];
    [self _initVAO];
    [self _initTextures];
    [self _initConfigure];
    
#ifdef FBODefine
    [self _initFrameBufferConfigure];
#endif
}

- (void)_initShader
{
    NSString *vsP = [[NSBundle mainBundle]pathForResource:@"model_loading.vs" ofType:nil];
    NSString *fsP = [[NSBundle mainBundle]pathForResource:@"model_loading.fs" ofType:nil];
    NSString *svsP = [[NSBundle mainBundle]pathForResource:@"framebuffer_screen.vs" ofType:nil];
    NSString *sfsP = [[NSBundle mainBundle]pathForResource:@"framebuffer_screen.fs" ofType:nil];

    self.ourShader = new Shader([vsP UTF8String], [fsP UTF8String]);
    self.screenShader = new Shader([svsP UTF8String], [sfsP UTF8String]);
    
    pos_Location = glGetAttribLocation(self.ourShader->ID, "aPos");
    texCoord_Location = glGetAttribLocation(self.ourShader->ID, "aTexCoords");
    s_pos_Location = glGetAttribLocation(self.screenShader->ID, "aPos");
    s_texCoord_Location = glGetAttribLocation(self.screenShader->ID, "aTexCoords");
    
    NSLog(@"lpr is:%d,%d,%d,%d",pos_Location,texCoord_Location,s_pos_Location,s_texCoord_Location);
}

- (void)_initVAO
{
    //cube VAO
    glGenVertexArraysOES(1, &cubeVAO);
    glGenBuffers(1, &cubeVBO);
    glBindVertexArrayOES(cubeVAO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), &cubeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(pos_Location);
    glVertexAttribPointer(pos_Location, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    glEnableVertexAttribArray(texCoord_Location);
    glVertexAttribPointer(texCoord_Location, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)(3*sizeof(float)));
    //plane VAO
    glGenVertexArraysOES(1, &planeVAO);
    glGenBuffers(1, &planeVBO);
    glBindVertexArrayOES(planeVAO);
    glBindBuffer(GL_ARRAY_BUFFER, planeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), &planeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(pos_Location);
    glVertexAttribPointer(pos_Location, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    glEnableVertexAttribArray(texCoord_Location);
    glVertexAttribPointer(texCoord_Location, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)(3*sizeof(float)));
    // screen quad VAO
    glGenVertexArraysOES(1, &quadVAO);
    glGenBuffers(1, &quadVBO);
    glBindVertexArrayOES(quadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(s_pos_Location);
    glVertexAttribPointer(s_pos_Location, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    glEnableVertexAttribArray(s_texCoord_Location);
    glVertexAttribPointer(s_texCoord_Location, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)(3*sizeof(float)));
}

- (void)_initTextures
{
    NSString *cube_path = [[NSBundle mainBundle]pathForResource:@"container" ofType:@"jpg"];
    NSString *floor_path = [[NSBundle mainBundle]pathForResource:@"metal" ofType:@"jpg"];

    cube_Texture = loadTexture([cube_path UTF8String]);
    floor_Texture = loadTexture([floor_path UTF8String]);
}

- (void)_initConfigure
{
    self.ourShader->use();
    self.ourShader->setInt("texture1", 0);
    self.screenShader->use();
    self.screenShader->setInt("screenTexture", 0);
}

- (void)_initFrameBufferConfigure
{
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    // create a color attachment texture
    glGenTextures(1, &quad_Texture);
    glBindTexture(GL_TEXTURE_2D, quad_Texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, SCR_WIDTH*SCR_SCALE, SCR_HEIGHT*SCR_SCALE, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, quad_Texture, 0);
    // create a renderbuffer object for depth & stencil attachment
    glGenRenderbuffers(1, &rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, rbo);
    // use a single renderbuffer object for both a depth & stencil buffer
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, SCR_WIDTH*SCR_SCALE, SCR_HEIGHT*SCR_SCALE);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
    }
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
}

#pragma  mark - GLKDelegate

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
#ifdef FBODefine
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
#endif
    glEnable(GL_DEPTH_TEST);
    // render
    glClearColor(0.6f, 0.6f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
#ifdef FBODefine
//    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT);
#endif

    self.ourShader->use();
    glm::mat4 modelT;
    glm::mat4 viewT;
    glm::mat4 projectionT;
    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    projectionT = glm::perspective(45.0f, (float)SCR_WIDTH/(float)SCR_HEIGHT, 0.1f, 100.0f);
    self.ourShader->setMat4("view", viewT);
    self.ourShader->setMat4("projection", projectionT);
    
    // cubes
    glBindVertexArrayOES(cubeVAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, cube_Texture);
    modelT = glm::translate(modelT, glm::vec3(-1.0f,0.0f,-1.0f));
    self.ourShader->setMat4("model", modelT);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    modelT = glm::translate(modelT, glm::vec3(2.0f,0.0f,0.0f));
    self.ourShader->setMat4("model", modelT);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    // floor
    glBindVertexArrayOES(planeVAO);
    glBindTexture(GL_TEXTURE_2D, floor_Texture);
    self.ourShader->setMat4("modelT", glm::mat4());
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayOES(0);
    
#ifdef FBODefine
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
    glDisable(GL_DEPTH_TEST);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
//    glViewport(0, 0, SCR_WIDTH*2.0, SCR_HEIGHT*2.0);
    
    self.screenShader->use();
    glBindVertexArrayOES(quadVAO);
    glBindTexture(GL_TEXTURE_2D, quad_Texture);
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

-(void)SwapBuffers
{
    glBindRenderbuffer(GL_RENDERBUFFER, quad_Texture);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}






@end
