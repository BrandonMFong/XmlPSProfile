/**
 * @file xAppSettings.hpp
 * @author Brando
 * @brief 
 * @version 0.1
 * @date 2021-02-02
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#ifndef _XAPPSETTINGS_
#define _XAPPSETTINGS_

#include <xPro/xPro.hpp>

/**
 * @brief Defines the app.json structure.  Pretty follows similarly to the xml family 
 * 
 */
struct xRootAppSettings : BasicJson
{
    xString RepoName;
    xString BaseConfig;

    struct Directories : BasicJson
    {
        xString UserConfig;
        xString UserCache;
        xString CalendarCache;
        xString gitCache; // following naming convention in config TODO change
        xString GreetingsCache;
        xString CalendarFileEventImport;
        xString Classes;
    } Directories;

    struct Files : BasicJson
    {
        xString Debug;
        xString Greetings;
        xString SessionCache;
        xString plistConfig;
        xString CalendarClassMod;
        xString DictionaryCache;

        struct Config : BasicJson 
        {
            xString Verioning;
        } Config;
    } Files;
};

/**
 * @brief 
 * 
 * @note this is a unique case where we are using xFile (its relative) to construct the path 
 * 
 */
class xAppSettings : public xJson 
{
public: 
    /**
     * @brief Construct a new App Settings object
     * 
     */
    xAppSettings();

    /**
     * @brief The holder for the app settings structure 
     * 
     */
    xRootAppSettings Machine;

    xString GetValueFromPath(xString path);
protected:
    /**
     * @brief Set the Json Value object
     * 
     * @param target The struct
     * @param value the json object
     */
    void SetJsonValue(xString &target, nlohmann::json value);
private:
};

#endif 
