/**
 * @file xArguments.hpp
 * @author Brando
 * @brief 
 * @version 0.1
 * @date 2021-02-12
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#ifndef _XARGUMENTS_
#define _XARGUMENTS_

#include <xPro/xPro.hpp>

class xArguments;

extern xArguments * gArg;

class xArguments : public xObject
{
public:
    xArguments();
    xArguments(int argc, char *argv[]);
    xInt Count();
    xStringArray Values();
private: 
    xInt _argCount;
    xStringArray _argVal;
};

#endif 