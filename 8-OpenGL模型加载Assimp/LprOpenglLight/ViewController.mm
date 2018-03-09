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

const float SCR_WIDTH = [UIScreen mainScreen].bounds.size.width;
const float SCR_HEIGHT = [UIScreen mainScreen].bounds.size.height;

glm::vec3 viewPos(3.0f,3.0f,5.0f);

@interface ViewController ()
{
  
}

@property (strong, nonatomic) EAGLContext *context;
@property Shader *ourShader;
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
    NSString *vsP = [[NSBundle mainBundle]pathForResource:@"model_loading.vs" ofType:nil];
    NSString *fsP = [[NSBundle mainBundle]pathForResource:@"model_loading.fs" ofType:nil];
    NSString *objP = [[NSBundle mainBundle]pathForResource:@"nanosuit.obj" ofType:nil];
    NSLog(@"vsP is:%@,fsP is:%@,objP is:%@.",vsP,fsP,objP);
    self.ourShader = new Shader([vsP UTF8String], [fsP UTF8String]);
    self.ourModel = new Model([objP UTF8String]);
}

#pragma  mark - GLKDelegate

- (void)update
{

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.5, 0.3, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    self.ourShader->use();
    
    glm::mat4 modelT,viewT,projectionT;
    
    viewT = glm::lookAt(viewPos, glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    projectionT = glm::perspective(45.0f, (float)SCR_WIDTH/(float)SCR_HEIGHT, 0.1f, 100.0f);
    self.ourShader->setMat4("view", viewT);
    self.ourShader->setMat4("projection", projectionT);
    
    modelT = glm::translate(modelT, glm::vec3(0.0f,-1.75f,0.0f));
    modelT = glm::scale(modelT, glm::vec3(0.02f,0.02f,0.02f));
    self.ourShader->setMat4("model", modelT);

    self.ourModel->Draw(*self.ourShader);
}

@end
