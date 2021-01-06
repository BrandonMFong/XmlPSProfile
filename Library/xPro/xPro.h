#ifndef _XPROLIBRARY_
#define _XPROLIBRARY_

/* WINDOWS */
//cl main.cpp /std:c++latest
#if defined(_WIN32) || defined(_WIN64)
#include <iostream>
#include <string>
#include <filesystem>
#include <fstream> 
#include <istream> 
#include <direct.h>
#include <sstream> 
namespace fs = std::filesystem;
#define PathSeparator '\\'
#define getcwd _getcwd
#define PATH_MAX _MAX_PATH
#define isWINDOWS

/* LINUX */
#elif __linux__ 
#include <iostream>
#include <string>
#include <experimental/filesystem>
#include <sstream> 
#include <cstring>
#include <sys/stat.h>
#include <vector>
#include <unistd.h>
#include <stdio.h>
#include <limits.h>
namespace fs = std::experimental::filesystem;
#define PathSeparator '/'

/* APPLE */
#elif __APPLE__
#include <iostream>
#include <string>
#include <filesystem>
#include <sys/stat.h>
#include <vector>
#include <unistd.h>
#include <sstream> 
namespace fs = std::__fs::filesystem;
#define PathSeparator '/'
#endif

// Prototypes
void enumItemsInDir(std::string path);
bool exist(std::string name);
std::string getFileByIndex(std::string path, int index);
std::string char2str(char arr[],int size);
std::vector<std::string> getDirItems(std::string path);

// Functions 
void enumItemsInDir(std::string path)
{
    std::string filename;
    int count = 1;

    // If this isn't windows, define these variables for the operations of getting the file
    #if !defined(isWINDOWS)
    std::string filepath; // will hold each file path in the directory pointed to by the argument 
    char sep = PathSeparator; // defines how the file paths are separated
    #endif

    for (const auto & entry : fs::directory_iterator(path)) 
    {
        #ifdef isWINDOWS
        filename = entry.path().filename().string(); // apply to string 
        #else 
        filepath = entry.path(); // apply to string 
        size_t i = filepath.rfind(sep, filepath.length()); // find the positions of the path delimiters
        
        // if no failure
        if (i != std::string::npos)  filename = filepath.substr(i+1, filepath.length() - i);
        #endif
        
        // Print out items
        std::cout << "[" << count << "] " << filename << std::endl;

        count++;
    }
}

// Does file exist
// This will take the argument by reference 
// https://stackoverflow.com/questions/12774207/fastest-way-to-check-if-a-file-exist-using-standard-c-c11-c 
bool exist(std::string file)
{
    bool result = false; // Will assume it does not exist
    struct stat buffer;

    // for the case of Windows
    // I am not sure if this will affect any file system directories in UNIX 
    if(file[0] == '\\') file.erase(0,1); 

    result = (stat(file.c_str(), &buffer) == 0); // does file exist

    return result;
}

// Select item in directory by index
// 0 index
std::string getFileByIndex(std::string path, int index)
{
    std::string result = "";
    int count = 0; // zero index
    std::vector<std::string> filepathvector = getDirItems(path);
    
    std::vector<std::string>::iterator itr;
    for(itr = filepathvector.begin(); itr < filepathvector.end(); itr++)
    {
        if (index == count) result = *itr;
        count++;
    }

    return result;
}

std::vector<std::string> getDirItems(std::string path)
{
    std::vector<std::string> filepathvectors;
    std::string filepath, tmp; 
    char cwd[PATH_MAX];

    getcwd(cwd,sizeof(cwd));

    std::string currdir = cwd;

    for (const auto & entry : fs::directory_iterator(path)) 
    {
        #ifdef isWINDOWS
        // fs::path path(entry.path()); // converting to path
        tmp = entry.path().filename().string();
        #else
        tmp = entry.path();
        #endif
        filepath = currdir + PathSeparator + tmp; 
        filepathvectors.push_back(filepath);
    }

    return filepathvectors;
}

#endif