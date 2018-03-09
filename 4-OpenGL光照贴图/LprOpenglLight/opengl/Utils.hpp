//
//  Utils.hpp
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/28.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#include <stdio.h>
#include <OpenGLES/ES2/glext.h>

struct Vertex
{
    float pos[3];
    float texcoord[2];
    float normal[3];
};

GLuint CompileShader(GLenum shaderType,const char*code);
GLuint CreateGPUProgram(const char*vsCode,const char*fscode);
GLuint CreateBufferObject(GLenum objType,int objSize,void*data,GLenum usage);

char*LoadAssetContent(const char*path);
char*DecodeBMP(char*bmpFileContent,int&width,int&height);

GLuint GenerateAlphaTexture(int size);
float frandom();//0.0f~1.0f
float sfrandom();//-1.0f~1.0f

bool DecodeObjModel(const char*fileContent,unsigned short **indices,int &indiceCount,Vertex **vertices,int &vertexCount);
#endif /* Utils_hpp */
