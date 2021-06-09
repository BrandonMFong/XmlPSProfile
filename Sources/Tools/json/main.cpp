/**
 * @file main.cpp
 * @author Brando 
 * @brief 
 * @version 0.1
 * @date 2021-02-03
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <xPro/xPro.hpp>

#define dMaxArgs 2

xBegin
    xUInt size;
    xString value;
    xString delimiterString = "/";
    xAppSettings * settingsReader = new xAppSettings();

    if(gStatus)
    {
        gStatus = gArg->Count() != dMaxArgs ? Bad : Good; 
    }

    if(!gStatus) 
    {
        std::cout << "usage: " << gArg->Values()[0] << std::endl;
        std::cout << "See '"<< gArg->Values()[0] << " " << dHelpArgument << "' for an overview of the system." << std::endl;
        std::cout << dFooter << std::endl;
    }

    if(gStatus)
    {
        value = gArg->Values()[1];
        std::cout << value << std::endl;
    }

xEnd
