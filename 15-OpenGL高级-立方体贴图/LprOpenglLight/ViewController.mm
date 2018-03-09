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
#include "Model.hpp"
#include "Glm/glm.hpp"
#include "Glm/ext.hpp"
#include "stb_image.h"

// utility function for loading a 2D texture from file
// ---------------------------------------------------
unsigned int loadTexture(char const *path)
{
    unsigned int textureID;
    glGenTextures(1, &textureID);
    
    int width, height, nrComponents;
    stbi_set_flip_vertically_on_load(true);
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
        
        if (nrComponents == 4)
        {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        else
        {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }

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

unsigned int loadCubeTextures(vector<std::string> faces)
{
    unsigned int textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);
    
    int width, height, nrChannels;
    for (unsigned int i = 0; i < faces.size(); i++)
    {
        stbi_set_flip_vertically_on_load(false);
        unsigned char *data = stbi_load(faces[i].c_str(), &width, &height, &nrChannels, 0);
        if (data)
        {
            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
            stbi_image_free(data);
        }
        else
        {
            std::cout << "Cubemap texture failed to load at path: " << faces[i] << std::endl;
            stbi_image_free(data);
        }
    }
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    return textureID;
    
    return 0;
}

const float SCR_WIDTH = [UIScreen mainScreen].bounds.size.width;
const float SCR_HEIGHT = [UIScreen mainScreen].bounds.size.height;

double _initAngle = 45.0f;
double _initRadius = 8.0f;
glm::vec3 viewPos(_initRadius*cos(_initAngle),1.0f,_initRadius*sin(_initAngle));

GLint pos_Location,texCoord_Location,sb_Pos_Location;
GLuint cube_Texture,sky_Box_Texture,cubeVAO,cubeVBO,sbVAO,sbVBO;

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

float skyboxVertices[] = {
    // positions
    -1.0f,  1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,
    
    -1.0f, -1.0f,  1.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,
    
    1.0f, -1.0f, -1.0f,
    1.0f, -1.0f,  1.0f,
    1.0f,  1.0f,  1.0f,
    1.0f,  1.0f,  1.0f,
    1.0f,  1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    
    -1.0f, -1.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,
    1.0f,  1.0f,  1.0f,
    1.0f,  1.0f,  1.0f,
    1.0f, -1.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,
    
    -1.0f,  1.0f, -1.0f,
    1.0f,  1.0f, -1.0f,
    1.0f,  1.0f,  1.0f,
    1.0f,  1.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,
    -1.0f,  1.0f, -1.0f,
    
    -1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f,  1.0f,
    1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f,  1.0f,
    1.0f, -1.0f,  1.0f
};

vector<std::string> faces
{
    [[[NSBundle mainBundle]pathForResource:@"right" ofType:@"jpg"] UTF8String],
    [[[NSBundle mainBundle]pathForResource:@"left" ofType:@"jpg"] UTF8String],
    [[[NSBundle mainBundle]pathForResource:@"top" ofType:@"jpg"] UTF8String],
    [[[NSBundle mainBundle]pathForResource:@"bottom" ofType:@"jpg"] UTF8String],
    [[[NSBundle mainBundle]pathForResource:@"front" ofType:@"jpg"] UTF8String],
    [[[NSBundle mainBundle]pathForResource:@"back" ofType:@"jpg"] UTF8String]
};

@interface ViewController ()
{
  
}

@property (strong, nonatomic) EAGLContext *context;
@property Shader *ourShader;
@property Shader *sbShader;
@property Model *ourModel;
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
    glDepthFunc(GL_LESS);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    [self _initShader];
    [self _initVAO];
    [self _initTextures];
    [self _initConfigure];
}

- (void)_initShader
{
    NSString *vsP = [[NSBundle mainBundle]pathForResource:@"model_loading.vs" ofType:nil];
    NSString *fsP = [[NSBundle mainBundle]pathForResource:@"model_loading.fs" ofType:nil];
    NSString *sb_vsP = [[NSBundle mainBundle]pathForResource:@"sky_box.vs" ofType:nil];
    NSString *sb_fsP = [[NSBundle mainBundle]pathForResource:@"sky_box.fs" ofType:nil];
    
    self.ourShader = new Shader([vsP UTF8String], [fsP UTF8String]);
    self.sbShader = new Shader([sb_vsP UTF8String], [sb_fsP UTF8String]);
    
    pos_Location = glGetAttribLocation(self.ourShader->ID, "aPos");
    texCoord_Location = glGetAttribLocation(self.ourShader->ID, "aTexCoords");
    
    sb_Pos_Location = glGetAttribLocation(self.sbShader->ID, "aPos");
}

- (void)_initVAO
{
    // cube VAO
    glGenVertexArraysOES(1, &cubeVAO);
    glGenBuffers(1, &cubeVBO);
    glBindVertexArrayOES(cubeVAO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), &cubeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(pos_Location);
    glVertexAttribPointer(pos_Location, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    glEnableVertexAttribArray(texCoord_Location);
    glVertexAttribPointer(texCoord_Location, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)(3*sizeof(float)));
    glBindVertexArrayOES(0);
    // sky box VAO
    glGenVertexArraysOES(1, &sbVAO);
    glGenBuffers(1, &sbVBO);
    glBindVertexArrayOES(sbVAO);
    glBindBuffer(GL_ARRAY_BUFFER, sbVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(skyboxVertices), &skyboxVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(sb_Pos_Location);
    glVertexAttribPointer(sb_Pos_Location, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), (void*)0);
    glBindVertexArrayOES(0);
}

- (void)_initTextures
{
    NSString *cube_path = [[NSBundle mainBundle]pathForResource:@"box" ofType:@"jpg"];
    cube_Texture = loadTexture([cube_path UTF8String]);
    sky_Box_Texture = loadCubeTextures(faces);
}

- (void)_initConfigure
{
    self.ourShader->use();
    self.ourShader->setInt("texture1", 0);
    self.sbShader->use();
    self.sbShader->setInt("skybox", 0);
}

#pragma  mark - GLKDelegate

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    viewPos = glm::vec3(_initRadius*cos(_initAngle),1.0f,_initRadius*sin(_initAngle));
    _initAngle += 0.01f;
    // render
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    self.ourShader->use();
    glm::mat4 modelT;
    glm::mat4 viewT;
    glm::mat4 projectionT;
    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    projectionT = glm::perspective(45.0f, (float)SCR_WIDTH/(float)SCR_HEIGHT, 0.1f, 100.0f);
    self.ourShader->setMat4("model", modelT);
    self.ourShader->setMat4("view", viewT);
    self.ourShader->setMat4("projection", projectionT);
    // cubes
    glBindVertexArrayOES(cubeVAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, cube_Texture);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
    
//    glDepthMask(GL_FALSE);
    glDepthFunc(GL_LEQUAL);  // change depth function so depth test passes when values are equal to depth buffer's content
    // sbshader
    self.sbShader->use();
    viewT = glm::mat4(glm::mat3(viewT));
    self.sbShader->setMat4("view", viewT);
    self.sbShader->setMat4("projection", projectionT);
    // skybox
    glBindVertexArrayOES(sbVAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, sky_Box_Texture);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
//    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LESS); // set depth function back to default

}

@end
