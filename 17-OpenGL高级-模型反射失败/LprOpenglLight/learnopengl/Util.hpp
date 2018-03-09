//
//  Util.hpp
//  LprOpenglLight
//
//  Created by 李沛然 on 2018/2/11.
//  Copyright © 2018年 aranzi-go. All rights reserved.
//

#ifndef Util_hpp
#define Util_hpp

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string>
#include <sstream>
#include <vector>
#include <OpenGLES/ES2/glext.h>
#include "stb_image.h"

unsigned int TextureFromFile(const char *path, const std::string &directory, bool gamma = false);

#endif /* Util_hpp */
