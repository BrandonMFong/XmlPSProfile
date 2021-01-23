/**
 * @file xpro.readxml
 * 
 * @brief 
 * 
 * @author Brando (BrandonMFong.com)
 */

#include <xPro/xPro.h>

int main(int argc, char *argv[]) 
{
    // xXml * xmlFile = new xXml("/home/brandonmfong/source/repo/xPro/Config/Users/Makito.xml"); 
    xConfigReader * config = new xConfigReader("/Users/BrandonMFong/brando/sources/repos/xPro/Config/Users/Makito.xml"); 

    std::cout << config->Machine.Directories.Directory[0].InnerXml << std::endl; // Can increment

    std::cout << config->Machine.Objects.Object[0].VarName.InnerXml << std::endl;

    return 0;
}