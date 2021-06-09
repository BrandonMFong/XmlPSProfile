/**
 * @file xDirectory.cpp
 * 
 * @brief xDirectory class
 * 
 * @author Brando
 * @date 2021-01-23
 */

#include <xPro/xAppPointer.hpp>
#include <xPro/xConfigReader.hpp>
#include <xPro/xXml.hpp>
#include <xPro/xAppSettings.hpp>
#include <xPro/xJson.hpp>
#include <xPro/xFile.hpp>
#include <xPro/xDirectory.hpp>

xDirectory::xDirectory() : xObject()
{
    this->_path = xEmptyString;
    this->_exists = False;

    this->_isInitialized = False;
}

xDirectory::xDirectory(xString path) : xObject()
{
    this->_isInitialized = True;
    xBool status = this->_status;
    xString filepath, tmp; 
    xString currdir;
    xChar cwd[PATH_MAX];
    const xPath * tempPath; // Constructing the path from a string is possible.
    std::error_code ec; // For using the non-throwing overloads of functions below.

    status = !path.empty(); // if the string is empty 

    // Test if this is a directory 
    if(status)
    {
        tempPath = new xPath(path);
        this->_isDirectory = IsDirectory(*tempPath,ec);

        this->SetPath(path);
        
        this->SetExists();

        // Keep track if this path exists
        status = this->_exists;
    }

    // if this is a directory, initialize items into Items vector
    if(status && this->_isDirectory)
    {
        if(path[0] == '\\') path.erase(0,1); // For windows

        // Get Curent working directory
        getcwd(cwd,sizeof(cwd));
        currdir = cwd;

        for (const auto & entry : fs::directory_iterator(path)) 
        {
            #ifdef isWINDOWS
            tmp = entry.path().filename().string();
            #else
            tmp = entry.path();
            #endif
            filepath = currdir + dPathSeparator + tmp; 
            this->_items.push_back(filepath);
        }
    }

    this->_status = status;
}

xBool xDirectory::Exists()
{
    return this->_exists;
}

void xDirectory::SetExists()
{
    xBool result = false; // Will assume it does not exist
    struct stat buffer;

    // will only check if path was set
    if(!this->_path.empty())
    {
        // Testing if the path exists
        result = (stat(this->_path.c_str(), &buffer) == 0); // does file exist

        // If the path does not exist, do not waste the memory 
        // TODO delete memory space 
        this->_path = result ? this->_path : xEmptyString;
    }
    else std::cout << "xDirectory: Path is empty" << std::endl;

    this->_exists = result;
}

void xDirectory::PrintItems()
{
    this->PrintItems(xNull);
}

void xDirectory::PrintItems(xString flag)
{
    xInt count = 1;
    xStringArray::iterator itr;

    if(this->_exists)
    {
        for(itr = this->_items.begin(); itr < this->_items.end(); itr++)
        {
            // Print out items
            if (xEnumerateDirectoryItems == flag) std::cout << "[" << count << "] ";
            std::cout << LeafItemFromPath(*itr) << std::endl;
            count++;
        }
    }
}

xString xDirectory::ItemByIndex(xInt index)
{
    xString result = xEmptyString;
    xInt count = 0; // zero index
    xStringArray::iterator itr;

    if(this->_exists)
    {
        for(itr = this->_items.begin(); itr < this->_items.end(); itr++)
        {
            if (index == count) result = *itr;
            count++;
        }
    }

    return result;
}

xString xDirectory::Path()
{
    return this->ToString();
}

// In the previous methods, I don't think I need to check if the path starts with 
// '/' because I create the full path here
void xDirectory::SetPath(xString path)
{
    #ifdef isWINDOWS
    try 
    {
        this->_path = fs::canonical(path).string();
    }
    catch (...)
    {
        std::cout << "xDirectory: error in fs::canonical() method, with parameter " << path << std::endl;
        this->_path = xEmptyString;
    }
    #else
    this->_path = fs::canonical(path); // Remove any of the ".." or "~" in path 
    #endif
}

xString xDirectory::ToString()
{
    return this->_path;
}
