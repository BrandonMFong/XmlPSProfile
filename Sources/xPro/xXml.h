/**
 * @file xXml.h 
 * 
 * @brief xXml class
 * 
 * @author Brando
 */

#ifndef _XXML_
#define _XXML_

#include <xPro/extern/rapidxml.hpp>
#include <xPro/extern/rapidxml_utils.hpp>
#include <xPro/xPro.h>
// #define RAPIDXML_NO_EXCEPTIONS // read rapidxml

class xXml : public xFile
{
public:
    /**
     * @brief Construct a new x Xml object
     * 
     */

    xXml();
    /**
     * @brief Construct a new x Xml object
     * 
     * @param file full or relative path to the config
     */
    xXml(xString filepath);
    
    /**
     * @brief Construct a new x Xml object
     * 
     * @param rootNodeName accepts the root node of the config
     * @param file the full or relative path to the config
     */
    xXml(xString rootNodeName, xString filepath);

    /**
     * @brief Returns the children of the root node 
     * 
     * @return xStringArray - an array of the root children names 
     */
    xStringArray RootChildNames();

    /**
     * @brief Returns the Root Node name 
     * 
     * @return xString 
     */
    xString RootNodeName();
protected:
    rapidxml::file<> * _xmlFile; /** Rapidxml file object */
    rapidxml::xml_document<> _xmlDocument; /** xmldocument that holds parse xml data */ 
    xString _rootNodeName; /** String name of the root node of xml file */
private: 
};

#endif