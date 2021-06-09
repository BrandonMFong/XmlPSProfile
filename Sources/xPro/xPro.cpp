/**
 * @file xPro.cpp
 * 
 * @brief Functions
 * 
 * @author Brando
 * @date 2021-01-23
 */

#include <xPro/xPro.hpp>

xStatus gStatus = Good;
xArguments * gArg;

xString LeafItemFromPath(xString path)
{
    xString leaf = "";
    size_t i;
    xString filepath; // apply to string 
    if(path[0] == '\\') path.erase(0,1); 

    const auto & entry = fs::directory_entry(path);
    #ifdef isWINDOWS
    leaf = entry.path().filename().string();
    #else
    leaf = entry.path();
    #endif
    #ifdef isWINDOWS
    leaf = entry.path().filename().string(); // apply to string 
    #else 
    filepath = entry.path(); // apply to string 
    i = filepath.rfind(dPathSeparator, filepath.length()); // find the positions of the path delimiters
    
    // if no failure
    if (i != xString::npos)  leaf = filepath.substr(i+1, filepath.length() - i);
    #endif
    return leaf;
}

xInt Char2xInt(xString character)
{
    xInt result = 0;
    xStringStream strValue;
    strValue << character;
    strValue >> result;
    return result;
}

void setArgs(int argc, char *argv[])
{
    gArg = new xArguments(argc, argv);
}
