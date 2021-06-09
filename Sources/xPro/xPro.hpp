/** 
 * @file xPro.h
 * 
 * @author Brando
 * @date 2021-01-23
 * 
 * Notes:
 * I want to improve my coding 
 * To do this I want to follow coding standards
 * Will consider derofim's: https://gist.github.com/derofim/df604f2bf65a506223464e3ffd96a78a 
*/

#ifndef _XPRO_
#define _XPRO_

/** OPERATING SYSTEM SPECIFIC **/
/* WINDOWS */
#if defined(_WIN32) || defined(_WIN64)
#include <iostream>
#include <string>
#include <filesystem>
#include <fstream> 
#include <istream> 
#include <direct.h>
#include <sstream> 
#include <stdlib.h>
#include <sys/stat.h>
namespace fs = std::filesystem;
#define dPathSeparator '\\'
#define getcwd _getcwd
#ifdef _MAX_PATH
#define PATH_MAX _MAX_PATH
#else 
#define PATH_MAX 260
#endif
#define isWINDOWS
#define dAppPointerFile "Profile.xml"
#define dAppSettingsFilePath "\\Config\\app.json"
#define dHomePath "USERPROFILE"
typedef unsigned int uint;

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
#include <fstream>
#include <stdlib.h>
namespace fs = std::experimental::filesystem;
#define dPathSeparator '/'
#define dAppPointerFile ".xPro/profile.xml"
#define dAppSettingsFilePath "/Config/app.json"
#define dHomePath "HOME"

/* APPLE */
#elif __APPLE__
#include <iostream>
#include <string>
#include <filesystem>
#include <sys/stat.h>
#include <vector>
#include <unistd.h>
#include <sstream> 
#include <fstream>
#include <stdlib.h>
namespace fs = std::__fs::filesystem;
#define dPathSeparator '/'
#define dAppPointerFile ".xPro/profile.xml"
#define dAppSettingsFilePath "/Config/app.json"
#define dHomePath "HOME"
#endif

/** EXTERNAL RESOURCES **/
#include <xPro/extern/pugixml.hpp>
#include <xPro/extern/json.hpp>
#include <xPro/extern/sqlite3.h>

/** APP SPECIFIC START **/

/*** xDefintions ***/
#define True true                                           /** Boolean True */
#define False false                                         /** Boolean False */
#define Good true                                           /** Status = Good */
#define Bad false                                           /** Status = Bad */ 
#define xNull nullptr                                       /** Null Pointer */
#define xEmptyString ""                                     /** Empty String */
#define IsFile(path,ec) fs::is_regular_file(path,ec)        /** Tests if file */
#define IsDirectory(path,ec) fs::is_directory(path,ec)      /** Tests path if it is a directory */
#define dUserConfigDirectoryPath "/Config/Users"            /** User Config Path */
#define xBegin int main(int argc, char *argv[])\
{setArgs(argc,argv);                                        /** Marks beginning of code */
#define xEnd return (xInt)(!gStatus);}                      /** Returns xStatus */
#define dFooter "(c) 2021 xPro All Rights Reserved"           /** Footer */
#define dHelpArgument "--help"                              /** Help argument */

/*** xTypes ***/
typedef int xInt;                           /** xPro-Type Integer */
typedef uint xUInt;                         /** xPro-Type Unsigned Integer */
typedef std::string xString;                /** xPro-Type String */
typedef bool xBool;                         /** xPro-Type Boolean */
typedef bool xStatus;                       /** xPro-Type Status */
typedef std::vector<xString> xStringArray;  /** xPro-Type String Array */
typedef char xChar;                         /** xPro-Type String */
typedef std::stringstream xStringStream;    /** xPro-Type String Stream */
typedef std::ifstream xInputFile;           /** xPro-Type ifstream */
typedef fs::path xPath;                     /** xPro-Type File System Path */

/*** xConstants ***/
const xString kHomeDirectoryPath = getenv(dHomePath); // _dupenv_s is suggested for windows 
const xString kHomeProfilePath = kHomeDirectoryPath + dPathSeparator + dAppPointerFile;

/*** xGlobals ***/
extern xStatus gStatus; /** Status variable for xTools */ 

// Order in descending order of inheritance
/*** xClasses ***/
#include <xPro/xObject.hpp>

/**** File System Objects ****/
#include <xPro/xDirectory.hpp>
#include <xPro/xFile.hpp>

// Xml family
#include <xPro/xXml.hpp>
#include <xPro/xConfigReader.hpp>
#include <xPro/xAppPointer.hpp>

// Json family 
#include <xPro/xJson.hpp>
#include <xPro/xAppSettings.hpp>

/**** Database Objects ****/
#include <xPro/xDatabase.hpp>
#include <xPro/xQuery.hpp>

/**** Argument Objects ****/
#include <xPro/xArguments.hpp>

/** Get's leaf item from a given filesystem path. This function is assuming the path already exists. 
 * Reference: https://stackoverflow.com/questions/22818925/c-error-undefined-symbols-for-architecture-x86-64
 * 
 * @param path the filesyste path (can be a file or a directory)
 * 
 * @return xString
 */
xString LeafItemFromPath(xString path);

/** Converts a character type to an integer type
 * @param character the char variable
 * 
 * @return xInt
 */
xInt Char2xInt(xString character);

void setArgs(int argc, char *argv[]);

/** APP SPECIFIC END **/

#endif