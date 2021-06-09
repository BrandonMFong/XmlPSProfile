/**
 * @file xArguments.cpp
 * @author Brando
 * @brief 
 * @version 0.1
 * @date 2021-02-12
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <xPro/xArguments.hpp>

xArguments::xArguments() : xObject()
{
    xStatus status = this->_status;

    this->_status = status;
}

xArguments::xArguments(int argc, char *argv[]) : xObject()
{
    xStatus status = this->_status;
    this->_argCount = argc;

    for(xUInt i = 0; i < this->_argCount; i++)
    {
        this->_argVal.push_back(argv[i]);
    }

    this->_status = status;
}

xInt xArguments::Count()
{
    return this->_argCount;
}

xStringArray xArguments::Values()
{
    return this->_argVal;
}
