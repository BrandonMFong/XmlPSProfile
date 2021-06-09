# Engineer: Brandon Fong
# Important Global Variables: XmlReader, AppPointer, LogHandler
Param(
    [System.Boolean]$StartDir=$true,
    [System.Boolean]$StartScript=$true,
    [System.Boolean]$DebugFlag=$false,
    [String]$BuildPath=$null,
    [System.Boolean]$Silent=$false # There is Verbose/Progress. Using Progress in github workflow looks silent
)

[System.Boolean]$okayToContinue             = $true;
[System.Xml.XmlDocument]$Global:XMLReader   = $null;
[System.Xml.XmlDocument]$Global:AppPointer  = $null;
[String]$profileFilePath                    = $null;
[String]$GitRepoDir                         = $null;
[String]$AppJsonPath                        = $null;
[System.Object[]]$Global:AppJson            = $null;
[String]$pathToConfig                       = $null;
[System.Boolean]$Verbose                    = $false;
[String]$xProUtilitiesPath                  = $null;
[String]$TerminalModulePath                 = $null;
[System.Boolean]$Save                       = $false;
[System.Boolean]$updateProfileFlag          = $false;
[System.Boolean]$updateConfigFlag           = $false;
[String]$pathToSetupScript                  = "setup.ps1";

<### GET AppPointer ###>
# For the CI test build
if($okayToContinue)
{
    if(![String]::IsNullOrEmpty($BuildPath))
    {
        # Push-Location $($BuildPath | Split-Path -Parent);
        $profileFilePath = "D:\a\xPro\xPro\" + $BuildPath;
    }
    else
    {
        # Push-Location $($PROFILE |Split-Path -Parent);
        $profileFilePath = $HOME + "\\Profile.xml";
    }

    $okayToContinue = ![String]::IsNullOrEmpty($profileFilePath);
}

if($okayToContinue)
{
    # [string]$profileFilePath = $HOME + "\\Profile.xml"; # TODO change 
    $Global:AppPointer = [System.Xml.XmlDocument]$(Get-Content $profileFilePath); # Will always be Profile.xml

    $okayToContinue = ($Global:AppPointer -ne $null);
}

if($okayToContinue)
{
    # Get Git repo dir
    $GitRepoDir = $Global:AppPointer.Machine.GitRepoDir;

    $okayToContinue = ($null -ne $GitRepoDir);
}

if($okayToContinue)
{
    
    <# GET App Json, think of a better name for this #>
    $AppJsonPath = $GitRepoDir + "\Config\app.json";
    $Global:AppJson = [System.Object[]]$(Get-Content $AppJsonPath | ConvertFrom-Json);

    $pathToConfig = $GitRepoDir + $Global:AppJson.Directories.UserConfig + $Global:AppPointer.Machine.ConfigFile;
    $Global:XMLReader = [System.Xml.XmlDocument]$(Get-Content $pathToConfig);

    $okayToContinue =   ($null -ne $Global:AppJson) -and 
                        ($null -ne $Global:XMLReader);
}

if($okayToContinue)
{
    # Pop-Location;
    $xProUtilitiesPath = $GitRepoDir + "\Modules\xProUtilities.psm1";
    $TerminalModulePath = $GitRepoDir + "\Modules\Terminal.psm1";

    if($null -ne $xProUtilitiesPath)
    {
        Import-Module $xProUtilitiesPath -DisableNameChecking:$true -Scope Local -WarningAction SilentlyContinue;
    }

    if($null -ne $TerminalModulePath)
    {
        Import-Module $TerminalModulePath -DisableNameChecking:$true -Scope Local -WarningAction SilentlyContinue;
    }

    $Global:LogHandler = Get-LogObject;

    $okayToContinue = ($null -ne $Global:LogHandler);
}

if($okayToContinue)
{
    $okayToContinue = $Global:XMLReader.Machine.LoadProfile.ToBoolean($null)
}
# Flag to load profile (in case someone wanting to use powershell)
# if(!$Global:XMLReader.Machine.LoadProfile.ToBoolean($null))
# {
#     break;
# } 

if($okayToContinue)
{
    $pathToSetupScript = $GitRepoDir + "\" + $pathToSetupScript;

    <### CHECK UPDATES ###>
    if([string]::IsNullOrEmpty($BuildPath))
    {
        $arg = @{UpdateProfile=$true;BooleanReply=[ref]$updateProfileFlag}
        $(& $pathToSetupScript @arg);
        # $updateProfileFlag = $($LASTEXITCODE -eq 0);

        $arg = @{UpdateConfig=$true;CheckUpdate=$true}
        $updateConfigFlag = $(& $pathToSetupScript @arg);
        
        # if((.\update-profile.ps1) -or (.\update-config.ps1 -CheckUpdate))
        if($updateProfileFlag -or $updateConfigFlag)
        {
            if("y" -eq $(Read-Host -Prompt "Do you want to restart powershell? (y/n)"))
            {
                if($PSVersionTable.PSVersion.Major -lt 7){Start-Process powershell;Stop-Process -Id $PID;}
                else{Start-Process pwsh;Stop-Process -Id $PID;}
            }
            else
            {
                # exit;
                $okayToContinue = $false
            }
        }
    }
}

if($okayToContinue)
{
    # Helps debugging if on
    if(($Global:XMLReader.Machine.LoadProcedure -eq "Verbose") -and !$Silent)
    {
        $Verbose = $true
    } 
    else
    {
        $Verbose = $false
    }
    <### GET CREDENTIALS ###>
    # CheckCredentials;
    
    <# BACKGROUND SETTINGS #>
    # Doing this early so if Verbose:$false then progress color will be set
    # Import-Module .\Modules\Terminal.psm1 -DisableNameChecking:$true -Scope Local -WarningAction SilentlyContinue;
    # Import-Module $TerminalModulePath -DisableNameChecking:$true -Scope Local -WarningAction SilentlyContinue;
    _SetBackgroundColor;
        
    <### PROGRAMS ###> 
    LoadPrograms -XMLReader:$Global:XMLReader -Verbose:$Verbose
    
    <### MODULES ###>
    LoadModules -XMLReader:$Global:XMLReader -Verbose:$Verbose
        
    <### OBJECTS ###>
    LoadObjects -XMLReader:$Global:XMLReader -Verbose:$Verbose
    
    <### FUNCTIONS ###>
    LoadFunctions -XMLReader:$Global:XMLReader -Verbose:$Verbose
        
    <### START ###>
    if(($Global:XMLReader.Machine.Start.Enabled -eq "true") -and ($StartScript) -and ![string]::IsNullOrEmpty($Global:XMLReader.Machine.Start)) 
    {
        # clears host from the progess text
        if($Global:XMLReader.Machine.Start.ClearHost -eq "true")
        {
            Clear-Host;
        }
    
        # Some output methods that should be defined
        # Greetings, calendar
    
        # Greetings
        if(![string]::IsNullOrEmpty($Global:XMLReader.Machine.Start.Greetings))
        {
            if([String]::IsNullOrEmpty($Global:XMLReader.Machine.Start.Greetings.Type)){[String]$Type = "Big";}
            else{[String]$Type = $Global:XMLReader.Machine.Start.Greetings.Type;}
            $Save = [System.Boolean]$Global:XMLReader.Machine.Start.Greetings.Save;
            $arg = 
            @{
                string=$Global:XMLReader.Machine.Start.Greetings.InnerXml; # String 
                Type=$Type; # Type of font
                SaveToFile=$Save;
                UniqueExtension=$("." + $($Global:AppPointer.Machine.ConfigFile | Split-Path -Leaf));
            };
            [String]$GreetingsPath = (Get-ChildItem $($Global:AppJson.Files.Greetings)).FullName; # Gets the full file path to the greetings script
            & $GreetingsPath @arg;
        }
    
        # If the script is defined, run it
        if(![String]::IsNullOrEmpty($Global:XMLReader.Machine.Start.Script) -and $(Test-Path $Global:XMLReader.Machine.Start.Script))
        {
            Invoke-Expression $(Evaluate -value:$Global:XMLReader.Machine.Start.Script);# Executes the file that the user defines
        } 
    }
}

try 
{
    if(![String]::IsNullOrEmpty($Global:XMLReader.Machine.ShellSettings.GitDisplay) -and 
    ($Global:XMLReader.Machine.ShellSettings.Enabled.ToBoolean($null)) -and 
    [string]::IsNullOrEmpty($BuildPath))
    {
        [String]$gitstring = "Version: $(git describe --tags)";
        if($gitstring.Contains("-")){Write-Host "`n$($gitstring.Substring(0,$gitstring.IndexOf("-")))`n" -ForegroundColor Gray;}
        else {Write-Host "`n$($gitstring)`n" -ForegroundColor Gray;}
    }
}
catch 
{
    $LogHandler.Write("You may not have git bash installed.")
}

# Pop-Location;

# Method for start directory 
if($StartDir -and (![String]::IsNullOrEmpty($Global:XMLReader.Machine.ShellSettings.StartDirectory)) -and [string]::IsNullOrEmpty($BuildPath))
{
    if((Test-Path $($Global:AppPointer.Machine.GitRepoDir + $Global:AppJson.Files.SessionCache)))
    {
        # Seeing if other session saved a directory to start with 
        [String]$SeshDir = Get-Content $($Global:AppPointer.Machine.GitRepoDir + $Global:AppJson.Files.SessionCache);
        Remove-Item $($Global:AppPointer.Machine.GitRepoDir + $Global:AppJson.Files.SessionCache) -Force; # Delete the trace 
    }
    else{[String]$SeshDir = $null;}

    if(![string]::IsNullOrEmpty($SeshDir)){Set-Location $SeshDir;}
    elseif(Test-Path $Global:XMLReader.Machine.ShellSettings.StartDirectory){Set-Location $Global:XMLReader.Machine.ShellSettings.StartDirectory;}
    else{$Global:LogHandler.Warning("Configured Start directory does not exist.  Please check.")}
}
else
{
    # Main dir for OS user
    Set-Location ~;
} 

# For debug mode
# It will run the debug script after profile is loaded
if($DebugFlag)
{
    $DebugScript = $($Global:AppPointer.Machine.GitRepoDir + $Global:AppJson.Files.Debug);
    if(!(Test-Path $DebugScript)){New-Item $DebugScript -Force;}
    & $DebugScript;
}

$Global:LogHandler.Write("Successfully loaded profile");
