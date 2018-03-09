//
//  Utils.cpp
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/28.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#include "Utils.hpp"
#include <math.h>
#include <stdlib.h>
#include <string>
#include <sstream>
#include <vector>

float frandom()
{
    return (float)rand()/(float)RAND_MAX;
}

float sfrandom()
{
    return frandom()*2.0f-1.0f;
}

bool DecodeObjModel(const char*fileContent,unsigned short **indices,int &indiceCount,Vertex **vertices,int &vertexCount)
{
    if (fileContent==nullptr)
    {
        printf("decode obj model fail,file content is null\n");
        return false;
    }
    struct FloatData
    {
        float v[3];
    };
    struct VertexDefine
    {
        int posIndex,vtIndex,vnIndex;
    };
    std::vector<FloatData> positions,texcoords,normals;
    std::vector<VertexDefine> vertexDefines;
    std::vector<unsigned short> faces;
    
    std::stringstream ssFile(fileContent);
    char szOneLine[128];
    std::string temp;
    while (!ssFile.eof())
    {
        memset(szOneLine, 0, 128);
        ssFile.getline(szOneLine, 128);
        if(strlen(szOneLine)>0)
        {
            std::stringstream ssOneLine(szOneLine);
            if (szOneLine[0]=='v')
            {
                if(szOneLine[1]=='t')
                {
                    ssOneLine>>temp;//vt
                    FloatData fd;
                    ssOneLine>>fd.v[0];
                    ssOneLine>>fd.v[1];
                    texcoords.push_back(fd);
                }
                else if(szOneLine[1]=='n')
                {
                    ssOneLine>>temp;//vn
                    FloatData fd;
                    ssOneLine>>fd.v[0];
                    ssOneLine>>fd.v[1];
                    ssOneLine>>fd.v[2];
                    normals.push_back(fd);
                }
                else
                {
                    ssOneLine>>temp;//v
                    FloatData fd;
                    ssOneLine>>fd.v[0];
                    ssOneLine>>fd.v[1];
                    ssOneLine>>fd.v[2];
                    positions.push_back(fd);
                }
            }
            else if(szOneLine[0]=='f')
            {
                ssOneLine>>temp;//f
                std::string vertexStr;
                for (int i=0; i<3;++i)
                {
                    ssOneLine>>vertexStr;
                    size_t pos=vertexStr.find_first_of('/');
                    std::string posIndexStr=vertexStr.substr(0,pos);
                    size_t pos2=vertexStr.find_first_of('/',pos+1);
                    std::string vtIndexStr=vertexStr.substr(pos+1,pos2-pos-1);
                    std::string vnIndexStr=vertexStr.substr(pos2+1,vertexStr.length()-pos2-1);
                    VertexDefine vd;
                    vd.posIndex=atoi(posIndexStr.c_str())-1;
                    vd.vtIndex=atoi(vtIndexStr.c_str())-1;
                    vd.vnIndex=atoi(vnIndexStr.c_str())-1;
                    int nCurrentVertexIndex=-1;
                    int nCurrentVertexCount=vertexDefines.size();
                    for (int j=0; j<nCurrentVertexCount; ++j)
                    {
                        if(vertexDefines[j].posIndex==vd.posIndex&&
                           vertexDefines[j].vtIndex==vd.vtIndex&&
                           vertexDefines[j].vnIndex==vd.vnIndex)
                        {
                            nCurrentVertexIndex=j;
                            break;
                        }
                    }
                    if(nCurrentVertexIndex==-1)
                    {
                        nCurrentVertexIndex=vertexDefines.size();
                        vertexDefines.push_back(vd);
                    }
                    faces.push_back(nCurrentVertexIndex);
                }
            }
        }
    }
    indiceCount=faces.size();
    *indices=new unsigned short[indiceCount];
    for (int i=0; i<indiceCount; ++i) {
        (*indices)[i]=faces[i];
    }
    vertexCount=vertexDefines.size();
    *vertices=new Vertex[vertexCount];
    for (int i=0; i<vertexCount; ++i) {
        memcpy((*vertices)[i].pos, positions[vertexDefines[i].posIndex].v, sizeof(float)*3);
        memcpy((*vertices)[i].texcoord, texcoords[vertexDefines[i].vtIndex].v, sizeof(float)*2);
        memcpy((*vertices)[i].normal, normals[vertexDefines[i].vnIndex].v, sizeof(float)*3);
    }
    return true;
}

GLuint GenerateAlphaTexture(int size)
{
    GLuint texture;
    unsigned char*imgData=new unsigned char[size*size];
    float maxDistance=sqrtf(size/2.0f*size/2.0f+size/2.0f*size/2.0f);
    float centerX=(float)size/2.0f;
    float centerY=centerX;
    for (int y=0; y<size; ++y)
    {
        for (int x=0; x<size; ++x)
        {
            float distance=sqrtf((x-centerX)*(x-centerX)+(y-centerY)*(y-centerY));
            float alpha=1.0f-distance/maxDistance;
            alpha=alpha>1.0f?1.0f:alpha;
            alpha=powf(alpha, 4.0f);
            imgData[x+y*size]=(unsigned char)(alpha*255.0f);
        }
    }
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, size, size, 0, GL_ALPHA, GL_UNSIGNED_BYTE, imgData);
    glBindTexture(GL_TEXTURE_2D, 0);
    return texture;
}

char*DecodeBMP(char*bmpFileContent,int&width,int&height)
{
    unsigned char*pixelData=nullptr;
    if (0x4D42==*((unsigned short*)bmpFileContent))
    {
        int pixelDataOffset=*((int*)(bmpFileContent+10));
        width=*((int*)(bmpFileContent+18));
        height=*((int*)(bmpFileContent+22));
        pixelData=(unsigned char*)(bmpFileContent+pixelDataOffset);
        //bgr -> rgb
        for(int i=0;i<width*height*3;i+=3)
        {
            unsigned char temp=pixelData[i+2];//r
            pixelData[i+2]=pixelData[i];//b
            pixelData[i]=temp;
        }
        return (char*)pixelData;
    }
    return (char*)pixelData;
}

//vertex shdader,fragment shader
GLuint CompileShader(GLenum shaderType,const char*code)
{
    //create shader object in gpu
    GLuint shader=glCreateShader(shaderType);
    //transform src to gpu & asign to the shader object
    glShaderSource(shader, 1, &code, NULL);
    glCompileShader(shader);
    GLint compileStatus=GL_TRUE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if(compileStatus==GL_FALSE)
    {
        printf("compile shader error,shader code is : %s\n",code);
        char szBuffer[1024]={0};
        GLsizei logLen=0;
        glGetShaderInfoLog(shader, 1024, &logLen, szBuffer);
        printf("error log : %s\n",szBuffer);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

GLuint CreateGPUProgram(const char*vsCode,const char*fscode)
{
    GLuint program;
    //compile source code
    //.cpp .mm .m -> .o
    GLuint vsShader=CompileShader(GL_VERTEX_SHADER, vsCode);
    GLuint fsShader=CompileShader(GL_FRAGMENT_SHADER, fscode);
    //link .o -> executable file
    program=glCreateProgram();
    glAttachShader(program, vsShader);
    glAttachShader(program, fsShader);
    glLinkProgram(program);
    GLint programStatus=GL_TRUE;
    glGetProgramiv(program, GL_LINK_STATUS, &programStatus);
    if(GL_FALSE==programStatus)
    {
        printf("link program error!");
        char szBuffer[1024]={0};
        GLsizei logLen=0;
        glGetProgramInfoLog(program, 1024, &logLen, szBuffer);
        printf("link error : %s\n",szBuffer);
        glDeleteProgram(program);
        return 0;
    }
    return program;
}

GLuint CreateBufferObject(GLenum objType,int objSize,void*data,GLenum usage)
{
    GLuint bufferObject;
    glGenBuffers(1, &bufferObject);
    glBindBuffer(objType, bufferObject);
    glBufferData(objType, objSize, data, usage);
    glBindBuffer(objType, 0);
    return bufferObject;
}
