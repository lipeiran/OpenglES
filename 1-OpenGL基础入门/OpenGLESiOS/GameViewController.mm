//
//  GameViewController.m
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/27.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#include <OpenGLES/EAGL.h>
#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include "Utils.hpp"
#include "Glm/glm.hpp"
#include "Glm/ext.hpp"
#include "stb_image.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

GLuint vbo,gpuProgram,texture,ebo,colorBuffer,fbo,fsqProgram,fsqVBO,lprGpuProgram,lprYellowGpuProgram,lprVBO,lprTwoVBO,lprEBO;
GLint posLocation,colorLocation,textureLocation,normalLocation,MLocation,VLocation,PLocation,NMLocation,fsqPosLocation,fsqTextureLocation,lprPosLocation,lprYellowPosLocation,lprHorFLocation,lprColorLocation,lprTexLocation,lprTextureLocation,lprSecondTextureLocation,lprAlphaLocation,lprModelLocation,lprViewLocation,lprProjectionLocation;
float horf = 0.5;
float lprSmileAlpha = 0.2;
float color[]={0.1,0.3,0.5,1.0};
int indexCount=0;
float rotateF = 0.1f;
unsigned int my_texture,my_secondTexture;
float identity[]=
{
    1.0f,0.0f,0.0f,0.0f,
    0.0f,1.0f,0.0f,0.0f,
    0.0f,0.0f,1.0f,0.0f,
    0.0f,0.0f,0.0f,1.0f
};
CGFloat yaw = -90.0f,pitch;
CGFloat fov = 45.0f;

glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);

float lprPoints[] =
{
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

unsigned short lprEBOPoints[] =
{
    0,1,2,1,3,2
};

float lprTwoPoints[] =
{
    0.5,-0.4,0.0,
    0.5,0.5,0.0,
    -0.5,0.5,0.0
};

glm::mat4 projection=glm::perspective(50.0f,640.0f/1136.0f,0.1f,100.0f);
glm::mat4 modelMatrix=glm::translate(0.0f,0.0f,-5.0f)*glm::rotate(-90.0f,0.0f,1.0f,0.0f)*glm::scale(0.01f, 0.01f,0.01f);
glm::mat4 normalMatrix=glm::inverseTranspose(modelMatrix);

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

void InitFBO()
{
    GLint prevFBO;
    glGetIntegerv(0X8CA6, &prevFBO);
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    
    glGenTextures(1,&colorBuffer);
    glBindTexture(GL_TEXTURE_2D, colorBuffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 640, 1136, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glBindTexture(GL_TEXTURE_2D, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorBuffer, 0);
    
    //depth & stencil buffer
    GLuint rbo;
    glGenRenderbuffers(1,&rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, 640, 1136);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo);
    
    int code=glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (GL_FRAMEBUFFER_COMPLETE!=code) {
        printf("create fbo fail!\n");
    }
    glBindFramebuffer(GL_FRAMEBUFFER,prevFBO);
}

@interface GameViewController ()
{
}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //init opengl begin
    //init opengl render context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];//3.0
    if(!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//2.0
    }
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    //
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//24 bit depth buffer
    [EAGLContext setCurrentContext:self.context];//wglMakeCurrent

    [self initLprScene];
    
#pragma mark - 笑脸是否明显
    
    UIButton *tmpUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpUpBtn.frame = CGRectMake(0.0,0.0,100.0,50.0);
    tmpUpBtn.center = CGPointMake(65.0f, ScreenHeight/2.0-50.0f);
    [tmpUpBtn setTitle:@"笑脸浓" forState:UIControlStateNormal];
    tmpUpBtn.layer.cornerRadius = 5.0f;
    [tmpUpBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpUpBtn.tag = 101;
    tmpUpBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:tmpUpBtn];
    
    UIButton *tmpDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpDownBtn.frame = CGRectMake(0.0,70.0,100.0,50.0);
    tmpDownBtn.center = CGPointMake(65.0f, ScreenHeight/2.0+50.0f);
    [tmpDownBtn setTitle:@"笑脸淡" forState:UIControlStateNormal];
    tmpDownBtn.layer.cornerRadius = 5.0f;
    [tmpDownBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpDownBtn.tag = 102;
    tmpDownBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:tmpDownBtn];
    
#pragma mark - 方向键
    UIButton *tmpFrontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpFrontBtn.frame = CGRectMake(0.0,0.0,50.0,50.0);
    tmpFrontBtn.center = CGPointMake(ScreenWidth/2.0, ScreenHeight-100);
    [tmpFrontBtn setTitle:@"前" forState:UIControlStateNormal];
    [tmpFrontBtn addTarget:self action:@selector(clickDirectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpFrontBtn.tag = 101;
    tmpFrontBtn.layer.cornerRadius = 5.0;
    tmpFrontBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:tmpFrontBtn];
    
    UIButton *tmpBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpBackBtn.frame = CGRectMake(0.0,70.0,50.0,50.0);
    tmpBackBtn.center = CGPointMake(ScreenWidth/2.0, ScreenHeight-40);
    [tmpBackBtn setTitle:@"后" forState:UIControlStateNormal];
    [tmpBackBtn addTarget:self action:@selector(clickDirectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpBackBtn.tag = 102;
    tmpBackBtn.layer.cornerRadius = 5.0;
    tmpBackBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:tmpBackBtn];
    
    UIButton *tmpLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpLeftBtn.frame = CGRectMake(0.0,0.0,50.0,50.0);
    tmpLeftBtn.center = CGPointMake(ScreenWidth/2.0 - 100, ScreenHeight-40);
    [tmpLeftBtn setTitle:@"左" forState:UIControlStateNormal];
    [tmpLeftBtn addTarget:self action:@selector(clickDirectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpLeftBtn.tag = 103;
    tmpLeftBtn.layer.cornerRadius = 5.0;
    tmpLeftBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:tmpLeftBtn];
    
    UIButton *tmpRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpRightBtn.frame = CGRectMake(0.0,70.0,50.0,50.0);
    tmpRightBtn.center = CGPointMake(ScreenWidth/2.0 + 100, ScreenHeight-40);
    [tmpRightBtn setTitle:@"右" forState:UIControlStateNormal];
    [tmpRightBtn addTarget:self action:@selector(clickDirectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpRightBtn.tag = 104;
    tmpRightBtn.layer.cornerRadius = 5.0;
    tmpRightBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:tmpRightBtn];
    
    
#pragma mark - 方向键
    UIButton *tmpUpMouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpUpMouseBtn.frame = CGRectMake(0.0,0.0,50.0,50.0);
    tmpUpMouseBtn.center = CGPointMake(ScreenWidth/2.0, 60);
    [tmpUpMouseBtn setTitle:@"上滑" forState:UIControlStateNormal];
    [tmpUpMouseBtn addTarget:self action:@selector(clickDirectionMouseBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpUpMouseBtn.tag = 101;
    tmpUpMouseBtn.layer.cornerRadius = 5.0;
    tmpUpMouseBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tmpUpMouseBtn];
    
    UIButton *tmpDownMouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpDownMouseBtn.frame = CGRectMake(0.0,70.0,50.0,50.0);
    tmpDownMouseBtn.center = CGPointMake(ScreenWidth/2.0, 120);
    [tmpDownMouseBtn setTitle:@"下滑" forState:UIControlStateNormal];
    [tmpDownMouseBtn addTarget:self action:@selector(clickDirectionMouseBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpDownMouseBtn.tag = 102;
    tmpDownMouseBtn.layer.cornerRadius = 5.0;
    tmpDownMouseBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tmpDownMouseBtn];
    
    UIButton *tmpLeftMouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpLeftMouseBtn.frame = CGRectMake(0.0,0.0,50.0,50.0);
    tmpLeftMouseBtn.center = CGPointMake(ScreenWidth/2.0 - 100, 120);
    [tmpLeftMouseBtn setTitle:@"左滑" forState:UIControlStateNormal];
    [tmpLeftMouseBtn addTarget:self action:@selector(clickDirectionMouseBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpLeftMouseBtn.tag = 103;
    tmpLeftMouseBtn.layer.cornerRadius = 5.0;
    tmpLeftMouseBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tmpLeftMouseBtn];
    
    UIButton *tmpRightMouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpRightMouseBtn.frame = CGRectMake(0.0,70.0,50.0,50.0);
    tmpRightMouseBtn.center = CGPointMake(ScreenWidth/2.0 + 100, 120);
    [tmpRightMouseBtn setTitle:@"右滑" forState:UIControlStateNormal];
    [tmpRightMouseBtn addTarget:self action:@selector(clickDirectionMouseBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpRightMouseBtn.tag = 104;
    tmpRightMouseBtn.layer.cornerRadius = 5.0;
    tmpRightMouseBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tmpRightMouseBtn];
    
#pragma mark - 视角放大&缩小
    
    UIButton *tmpZoomInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpZoomInBtn.frame = CGRectMake(0.0,0.0,100.0,50.0);
    tmpZoomInBtn.center = CGPointMake(ScreenWidth - 65.0f, ScreenHeight/2.0-50.0f);
    [tmpZoomInBtn setTitle:@"放大镜" forState:UIControlStateNormal];
    tmpZoomInBtn.layer.cornerRadius = 5.0f;
    [tmpZoomInBtn addTarget:self action:@selector(clickZoomBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpZoomInBtn.tag = 101;
    tmpZoomInBtn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:tmpZoomInBtn];
    
    UIButton *tmpZoomOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpZoomOutBtn.frame = CGRectMake(0.0,70.0,100.0,50.0);
    tmpZoomOutBtn.center = CGPointMake(ScreenWidth - 65.0f, ScreenHeight/2.0+50.0f);
    [tmpZoomOutBtn setTitle:@"缩小镜" forState:UIControlStateNormal];
    tmpZoomOutBtn.layer.cornerRadius = 5.0f;
    [tmpZoomOutBtn addTarget:self action:@selector(clickZoomBtn:) forControlEvents:UIControlEventTouchUpInside];
    tmpZoomOutBtn.tag = 102;
    tmpZoomOutBtn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:tmpZoomOutBtn];
}

- (void)clickZoomBtn:(UIButton *)sender
{
    CGFloat tmpOffset = 1.0f;
    switch (sender.tag)
    {
        case 101://放大
        {
            fov -= tmpOffset;
        }
            break;
        case 102://缩小
        {
            fov += tmpOffset;
        }
            break;
        default:
            break;
    }
    
    if(fov <= 1.0f)
    {
        fov = 1.0f;
    }
    else if(fov >= 45.0f)
    {
        fov = 45.0f;
    }
}

- (void)clickDirectionBtn:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    float cameraSpeed = 0.05f;
    
    //打开注释即为 FPS 行走模式，不能飞行
    //glm::vec3 tmpCameraFront = glm::normalize(glm::vec3(cameraFront.x, cameraPos.y, cameraFront.z));
    //此为飞行模式
    glm::vec3 tmpCameraFront = cameraFront;
    
    switch (sender.tag)
    {
        case 101:
        {
            //前
            cameraPos += cameraSpeed*tmpCameraFront;
        }
            break;
        case 102:
        {
            //后
            cameraPos -= cameraSpeed*tmpCameraFront;
        }
            break;
        case 103:
        {
            //左
            cameraPos -= glm::normalize(glm::cross(tmpCameraFront, cameraUp))*cameraSpeed;
        }
            break;
        case 104:
        {
            //右
            cameraPos += glm::normalize(glm::cross(tmpCameraFront, cameraUp))*cameraSpeed;
        }
            break;
        default:
            break;
    }
}

- (void)clickDirectionMouseBtn:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    CGFloat radiusSpeed = 1.0f;
    switch (sender.tag)
    {
        case 101:
        {
            //上滑
            pitch += radiusSpeed;
        }
            break;
        case 102:
        {
            //下滑
            pitch -= radiusSpeed;
        }
            break;
        case 103:
        {
            //左滑
            yaw -= radiusSpeed;
        }
            break;
        case 104:
        {
            //右滑
            yaw += radiusSpeed;
        }
            break;
        default:
            break;
    }
    
    if(pitch > 89.0f)
    {
        pitch =  89.0f;
    }
    else if(pitch < -89.0f)
    {
        pitch = -89.0f;
    }

    glm::vec3 front;
    front.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw));
    front.y = sin(glm::radians(pitch));
    front.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
    cameraFront = glm::normalize(front);
    NSLog(@"camera front is:%f,%f,%f=======%f,%f,%f",front.x,front.y,front.z,cameraFront.x,cameraFront.y,cameraFront.z);
}

- (void)clickBtn:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    switch (sender.tag)
    {
        case 101:
        {
            lprSmileAlpha+=0.05;
        }
            break;
        case 102:
        {
            lprSmileAlpha-=0.05;
        }
            break;
        default:
            break;
    }
    if (lprSmileAlpha >1)
    {
        lprSmileAlpha = 1.0;
    }
    else if (lprSmileAlpha < 0)
    {
        lprSmileAlpha = 0.0;
    }
}

- (void)initLprScene
{
    char*vsCode=LoadAssetContent("Data/Shader/lpr.vs");
    char*fsCode=LoadAssetContent("Data/Shader/lpr.fs");
    char*fsTwoCode=LoadAssetContent("Data/Shader/lpryellow.fs");
    
    lprGpuProgram = CreateGPUProgram(vsCode, fsCode);
    lprPosLocation = glGetAttribLocation(lprGpuProgram, "lprpos");
    lprTexLocation = glGetAttribLocation(lprGpuProgram, "texcoord");
    lprTextureLocation = glGetUniformLocation(lprGpuProgram, "f_texture");
    lprSecondTextureLocation = glGetUniformLocation(lprGpuProgram, "f_secondTexture");
    lprAlphaLocation = glGetUniformLocation(lprGpuProgram, "f_second_alpha");
    
    lprYellowGpuProgram = CreateGPUProgram(vsCode, fsTwoCode);
    lprYellowPosLocation = glGetAttribLocation(lprYellowGpuProgram, "lprpos");

    lprVBO = CreateBufferObject(GL_ARRAY_BUFFER, sizeof(lprPoints), lprPoints, GL_STATIC_DRAW);
    lprTwoVBO = CreateBufferObject(GL_ARRAY_BUFFER, sizeof(lprTwoPoints), lprTwoPoints, GL_STATIC_DRAW);
    lprEBO = CreateBufferObject(GL_ELEMENT_ARRAY_BUFFER, sizeof(lprEBOPoints), lprEBOPoints, GL_STATIC_DRAW);
    
    delete vsCode;
    delete fsCode;
    
    [self initLprTexture];
}

- (void)initLprTexture
{
    glGenTextures(1, &my_texture);
    glBindTexture(GL_TEXTURE_2D, my_texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    int width, height, nrChannels;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"container" ofType:@"jpg"];
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
    
    glGenTextures(1, &my_secondTexture);
    glBindTexture(GL_TEXTURE_2D, my_secondTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    int width1, height1, nrChannels1;
    NSString *path1 = [[NSBundle mainBundle]pathForResource:@"abc" ofType:@"jpg"];
    unsigned char *data1 = stbi_load([path1 UTF8String], &width1, &height1, &nrChannels1, 0);
    if (data1)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width1, height1, 0, GL_RGB, GL_UNSIGNED_BYTE, data1);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"fail to load texture2");
    }
    stbi_image_free(data1);
    
    glUseProgram(lprGpuProgram);
    glUniform1i(lprTextureLocation, 0);
    glUniform1i(lprSecondTextureLocation, 1);
}

- (unsigned char *)pixelBRGABytesFromImage:(UIImage *)image
{
    return [self pixelBRGABytesFromImageRef:image.CGImage];
}

- (unsigned char *)pixelBRGABytesFromImageRef:(CGImageRef)imageRef
{
    NSUInteger iWidth = CGImageGetWidth(imageRef);
    NSUInteger iHeight = CGImageGetHeight(imageRef);
    NSUInteger iBytesPerPixel = 4;
    NSUInteger iBytesPerRow = iBytesPerPixel * iWidth;
    NSUInteger iBitsPerComponent = 8;
    unsigned char *imageBytes = (unsigned char *)malloc(iWidth * iHeight * iBytesPerPixel);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(imageBytes,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,imageRef);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return imageBytes;
}

- (void)dealloc
{
    [super dealloc];
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
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
    GLint prevFBO;
    glGetIntegerv(GL_ARRAY_BUFFER, &prevFBO);
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.6f, 0.4f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, my_texture);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, my_secondTexture);
    
    glUseProgram(lprGpuProgram);
    
    glBindBuffer(GL_ARRAY_BUFFER, lprVBO);
    glVertexAttribPointer(lprPosLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*5, (void*)0);
    glEnableVertexAttribArray(lprPosLocation);
    glVertexAttribPointer(lprTexLocation, 2, GL_FLOAT, GL_FALSE, sizeof(float)*5, (void*)(sizeof(float)*3));
    glEnableVertexAttribArray(lprTexLocation);
    glUniform1f(lprAlphaLocation, lprSmileAlpha);
    glBindBuffer(GL_ARRAY_BUFFER, prevFBO);

    glm::mat4 viewT;
    viewT = glm::lookAt(cameraPos, cameraPos+cameraFront, cameraUp);
    lprViewLocation = glGetUniformLocation(lprGpuProgram, "view");
    glUniformMatrix4fv(lprViewLocation, 1, GL_FALSE, glm::value_ptr(viewT));

    glm::mat4 projectionT;
    projectionT = glm::perspective((float)fov, (float)ScreenWidth / (float)ScreenHeight, 0.1f, 100.0f);
    lprProjectionLocation = glGetUniformLocation(lprGpuProgram, "projection");
    glUniformMatrix4fv(lprProjectionLocation, 1, GL_FALSE, glm::value_ptr(projectionT));
    
    rotateF += 0.1f;
    if (rotateF >= 9.0f)
    {
        rotateF = 0.0f;
    }
    for(unsigned int i = 0; i < 10; i++)
    {
        lprModelLocation = glGetUniformLocation(lprGpuProgram, "model");
        glm::mat4 model;
        model = glm::translate(model, cubePositions[i]);

        if (i == 0 || (i+1)%3==0)
        {
            float angle = 20.0f * i;
            model = glm::rotate(model, (float)rotateF * 40.0f+(float)angle, glm::vec3(1.0f, 0.3f, 0.5f));
        }
        else
        {
            model = glm::rotate(model, 0.0f, glm::vec3(0.0f, 0.0f, 1.0f));
        }
        glUniformMatrix4fv(lprModelLocation, 1, GL_FALSE, glm::value_ptr(model));

        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    glUseProgram(0);
}
@end
