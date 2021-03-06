Import-Module $PSScriptRoot\xProUtilities.psm1 -Scope Local;

function _MachineNode([ref]$File)
{
    # <Machine>
    $Node_Machine = $File.Value.CreateElement("Machine");
    $Node_Machine.SetAttribute("MachineName",$env:COMPUTERNAME);
    $Node_Machine.SetAttribute("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance");
    $Node_Machine.SetAttribute("xsi:noNamespaceSchemaLocation","..\Schema\xPro.xsd");
    $File.Value.AppendChild($Node_Machine);#Node
}

function _StartScriptNode([ref]$File)
{
    ### <StartScript> ##
    $Node_StartScript = $File.Value.CreateElement("StartScript");
    $Node_StartScript.SetAttribute("ClearHost","false");
    $Node_StartScript.SetAttribute("Enable","false");
    $File.Value.Machine.AppendChild($Node_StartScript); # Append
}

function _ShellSettingsNode([ref]$File)
{
    ## <Prompt> ##
    $Node_ShellSettings = $File.Value.CreateElement("ShellSettings");

    $Node_Prompt = $File.Value.CreateElement("Prompt");
    # String
    $Node_String = $File.Value.CreateElement("String");
    $Node_String.InnerXml = "Default";
    # BaterryLifeThreshold
    $Node_BaterryLifeThreshold = $File.Value.CreateElement("BaterryLifeThreshold");
    $Node_BaterryLifeThreshold.SetAttribute("Enabled", "true");
    $Node_BaterryLifeThreshold.InnerXml = "35";

    $Node_Header = $File.Value.CreateElement("Header");
    $Node_Header.SetAttribute("Enabled", "False");

    $Node_Format = $File.Value.CreateElement("Format");
    # <DateFormat>
    $Node_DateFormat = $File.Value.CreateElement("Date");
    # <TimeFormat>
    $Node_TimeFormat = $File.Value.CreateElement("Time");

    $Node_ShellColors = $File.Value.CreateElement("ShellColors");
    $Node_StartDirectory = $File.Value.CreateElement("StartDirectory");

    $Node_Header.AppendChild($Node_HeaderTitle);#Node
    $Node_Format.AppendChild($Node_DateFormat);#Node
    $Node_Format.AppendChild($Node_TimeFormat);#Node
    $Node_Prompt.AppendChild($Node_String);#Node
    $Node_Prompt.AppendChild($Node_BaterryLifeThreshold);#Node
    $Node_ShellSettings.AppendChild($Node_Prompt);#Node
    $Node_ShellSettings.AppendChild($Node_Format);#Node
    $Node_ShellSettings.AppendChild($Node_Header);#Node
    $Node_ShellSettings.AppendChild($Node_ShellColors);#Node
    $Node_ShellSettings.AppendChild($Node_StartDirectory);#Node
    $File.Value.Machine.AppendChild($Node_ShellSettings);
}

function _DirectoryNode([ref]$File)
{
    ## Directories ##
    $Node_Directories = $File.Value.CreateElement("Directories");
    # Directory
    $Node_Directory = $File.Value.CreateElement("Directory");
    $Node_Directory.SetAttribute("alias", "GitRepo");
    $Node_Directory.SetAttribute("SecType", "public");
    $Node_Directory.InnerXml = $PSScriptRoot; # putting this dir in the xml
    $Node_Directories.AppendChild($Node_Directory);#Node
    $File.Value.Machine.AppendChild($Node_Directories);
}
function _WeatherNode([ref]$File)
{
    ## Directories ##
    $Node_Weather = $File.Value.CreateElement("Weather");
    $Node_Area = $File.Value.CreateElement("Area");
    $Node_Weather.AppendChild($Node_Area);#Node
    $File.Value.Machine.AppendChild($Node_Weather);
}

function _ObjectsNode([ref]$File)
{
    # Objects
    $Node_Objects =  $File.Value.CreateElement("Objects");
    $Node_Objects.SetAttribute("Database", "");
    $Node_Objects.SetAttribute("ServerInstance", "");
    # Object 
    $Node_Object = $File.Value.CreateElement("Object");
    $Node_Object.SetAttribute("Type", "XmlElement");
    # VarName
    $Node_VarName = $File.Value.CreateElement("VarName");
    $Node_VarName.SetAttribute("SecType","public");
    $Node_VarName.InnerXml = "User";
    # Values
    $Node_Value = $File.Value.CreateElement("Value");
    # Key
    $Node_Key = $File.Value.CreateElement("Key");
    $Node_Object.AppendChild($Node_VarName);
    $Node_Object.AppendChild($Node_Key);
    $Node_Object.AppendChild($Node_Value);
    $Node_Objects.AppendChild($Node_Object);
    $File.Value.Machine.AppendChild($Node_Objects);
}

function _ProgramNode([ref]$File)
{
    # Programs
    $Node_Programs = $File.Value.CreateElement("Programs");
    # Program
    $Node_Program = $File.Value.CreateElement("Program");
    $Node_Program.SetAttribute("Alias", "");
    $Node_Program.SetAttribute("Type", "");
    $Node_Programs.AppendChild($Node_Program);
    $File.Value.Machine.AppendChild($Node_Programs);
}

function _ModulesNode([ref]$File)
{
    # Modules
    $Node_Modules = $File.Value.CreateElement("Modules");
    # Module
    $Node_Module = $File.Value.CreateElement("Module");
    $Node_Modules.AppendChild($Node_Module);
    $File.Value.Machine.AppendChild($Node_Modules);
}

function _ListNode([ref]$File)
{
    # Lists
    $Node_Lists = $File.Value.CreateElement("Lists");
    # List
    $Node_List = $File.Value.CreateElement("List");
    $Node_List.SetAttribute("Title", "");
    # Item
    $Node_Item = $File.Value.CreateElement("Item");
    $Node_Item.SetAttribute("rank","");
    $Node_Item.SetAttribute("name","");
    $Node_Item.SetAttribute("Completed","");
    $Node_Item.SetAttribute("name","New Years");
    $Node_List.AppendChild($Node_Item);
    $Node_Lists.AppendChild($Node_List);
    $File.Value.Machine.AppendChild($Node_Lists);
}

function _CalendarNode([ref]$File)
{
    # Calendar
    $Node_Calendar = $File.Value.CreateElement("Calendar");
    # SpecialDays
    $Node_SpecialDays = $File.Value.CreateElement("SpecialDays");
    # SpecialDay
    $Node_SpecialDay = $File.Value.CreateElement("SpecialDay");
    $Node_SpecialDay.InnerXml = "1/1/2021";
    $Node_SpecialDays.AppendChild($Node_SpecialDay);
    $Node_Calendar.AppendChild($Node_SpecialDays);
    $File.Value.Machine.AppendChild($Node_Calendar);
}

function Config-Editor
{ # Seems that you would need to restart ps session
    Param
    (
        [switch]$AddDirectory,
        [string]$AddProgram=$null
    )
    if($AddDirectory){InsertFromCmd -Tag "Directory" -PathToAdd $(Get-Location).Path;}
    if(![string]::IsNullOrEmpty($AddProgram)){InsertFromCmd -Tag "Program" -PathToAdd $(GetFullFilePath($AddProgram));}

}

function List-Directories
{
    Write-Host "`nDirectories and their aliases:`n" -ForegroundColor Cyan;
    foreach($d in $(Get-Variable 'XMLReader').Value.Machine.Directories.Directory)
    {
        Write-Host "$($d.alias)" -ForegroundColor Green -NoNewline;
        Write-Host " => " -NoNewline;
        Write-Host "$($d.InnerXML)" -ForegroundColor Cyan;
    }
    Write-Host `n;
}
function List-Programs
{
    Write-Host "`nPrograms, their aliases, and their type:`n" -ForegroundColor Cyan;
    foreach($p in $(Get-Variable 'XMLReader').Value.Machine.Programs.Program)
    {
        Write-Host "$($p.alias)" -ForegroundColor Green -NoNewline;
        Write-Host " => " -NoNewline;
        Write-Host "$($p.InnerXML)" -ForegroundColor Cyan -NoNewline;
        Write-Host " (" -NoNewline; Write-Host "$($p.SecType)" -ForegroundColor Cyan -NoNewline; Write-Host ") ";
    }
    Write-Host `n;
}


Import-Module $($PSScriptRoot + "\xProUtilities.psm1") -Scope Local;

# Runs Upgrade scripts on the config files that is currently pointed
# Not going to be in the profile load since this is a module
# Must include in startscripts
# Also it isn't required to have a config
function Run-Update
{
    Param([String[]]$InOrderScripts)

    Write-Host "`nRunning upgrade scripts`n" -ForegroundColor Cyan;

    [String]$ParseString="MMddyyyy"

    [System.Xml.XmlDocument]$xml = $(_GetUserConfig -Content);
    if([string]::IsNullOrEmpty($xml.Machine.UpdateStamp.Value)){[string]$val = "01012020";} # start of 2020
    else{[string]$val = $xml.Machine.UpdateStamp.Value;}
    [DateTime]$UpdateStamp = [DateTime]::ParseExact($val,$ParseString,$null); # Get update stamp from configuration

    for($i=0;$i -lt $InOrderScripts.Length;$i++)
    {
        # Compare with scripts
        [DateTime]$CurrentStamp = [DateTime]::ParseExact($InOrderScripts[$i],$ParseString,$null);
        if($UpdateStamp -lt $CurrentStamp) # Only run the scripts that have not been run yet
        {
            $script = $(Get-ChildItem $($PSScriptRoot + "\..\Config\UpdateConfig\$($InOrderScripts[$i]).ps1")).FullName;
            [Boolean]$Executed = $false;
            $arg = 
            @{
                Executed=[ref]$Executed;
            };
            & $script @arg;
            if($Executed)
            {
                Write-Host "Executing: $($script)`n" -ForegroundColor Gray;
                GetSynopsisText -script:$script;
            }
        }
    }
    Write-Host "`n";
}
