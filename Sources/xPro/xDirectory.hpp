/**
 * @file xDirectory.h 
 * 
 * @brief xDirectory class
 * 
 * @author Brando
 * @date 2021-01-23
 */

#ifndef _XDIRECTORY_
#define _XDIRECTORY_

#include <xPro/xPro.hpp>
#define xEnumerateDirectoryItems "EnumerateDirectoryItems"
enum DirResult
{
    kDirSuccess = 0,
    kDirFailure = 1
};

class xDirectory : public xObject
{
public:
    /**
     * @brief Construct a new xDirectory object
     * 
     */
    xDirectory();

    /**
     * @brief Construct a new xDirectory object
     * 
     * @param path filesystem path
     */
    xDirectory(xString path);

    /**
     * @brief Does this object exist in the file system
     * 
     * @return xBool 
     */
    xBool Exists();

    /**
     * @brief Set the object's existence
     * 
     */
    void SetExists();

    /**
     * @brief Prints items from objects path
     * 
     */
    void PrintItems();

    /**
     * @brief Prints items from objects path
     * 
     * @param flag pass xEnumerateDirectoryItems to enumerate the list, otherwise just leave blank
     */
    void PrintItems(xString flag);

    /**
     * @brief If this is a directory and there are items in there, the returned object is filled with those items
     * 
     * @return xStringArray 
     */
    xStringArray GetItems();

    /**
     * @brief Returns the selected object outlined by PrintItems()
     * 
     * @param index The items num on the list
     * @return xString 
     */
    xString ItemByIndex(xInt index);

    /**
     * @brief Returns full path.  If the path isn't a real path, return xEmptyString
     * 
     * @return xString 
     */
    xString Path();

    /**
     * @brief Print full file path in c string
     * 
     * @return xChar * of Directory path 
     */
    xChar * ToCString();

    /**
     * @brief Set the Path 
     * 
     */
    void SetPath(xString path);

    /**
     * @brief To String
     * 
     */
    xString ToString();

protected:
    xString _path; /** The object's path */
    xBool _exists; /** if the path exists */
    xBool _isDirectory; /** if path is a directory */
private:
    xString _leafitem; /** The object's leaf item from path */
    xStringArray _items; /** List of items in path */
};

#endif