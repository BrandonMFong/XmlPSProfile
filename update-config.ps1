<#
.Synopsis
   Updates the config pointer
#>
Param([string]$ConfigName=$null,[Switch]$CheckUpdate)
Push-Location $PSScriptRoot
    [System.Object[]]$AppJson = Get-Content .\Config\app.json|ConvertFrom-Json; # Get app config

    # This segment runs independtly.  I could have made another script but the context of this script is similar to this segment's goal
    # Can probably be arranged better
    if($CheckUpdate)
    {
        [string[]]$Scripts = (Get-ChildItem $PSScriptRoot\Config\UpdateConfig\*.*).Name;

        [String]$ParseString="MMddyyyy"
        [String[]]$UpgradeScripts = (Get-ChildItem $PSScriptRoot\Config\UpdateConfig\*.*).BaseName; # Only using the base name to determine update stamp
        $arg = @{Object=$UpgradeScripts;Method="SelectionSort";ParseString=$ParseString};
        $command = $(Get-ChildItem $($PSScriptRoot + "\Scripts\Sort-Object.ps1")).FullName;
        [string[]]$InOrderScripts = $(& $command @arg);

        # There has to be a better way at checking if there is an update needed
        if([DateTime]::ParseExact($Scripts[$Scripts.Count-1].Replace(".ps1",$null),$ParseString,$null) -gt [DateTime]::ParseExact($Global:XMLReader.Machine.UpdateStamp.Value,$ParseString,$null))
        {
            Write-Host  "`nThere is an update to GlobalScripts Config." -ForegroundColor Red
            [string]$update = Read-Host -Prompt "Want to update? (y/n)";
            if($update -eq "y")
            {
                Import-Module $($PSScriptRoot + "\Modules\ConfigHandler.psm1") -Scope Local -DisableNameChecking;
                Run-Update -InOrderScripts:$InOrderScripts; # Updates configuration file
                Pop-location; 
                
                Write-Warning "Config was updated";
                return 1; # Exiting code
            }
            else{Pop-Location; return 0;}
        }
        else{Pop-location;return 0;}
    }

    # Create AppPointer
    Write-Host "Config files to choose from:"
    [string]$pathToxProConfig = "." + $AppJson.Directories.UserConfig
    .\bin\xpro.enumdir.exe $pathToxProConfig; # Get items from the user config
    $choice = Read-Host -Prompt "So"; # Get user's choice 
    [String]$ConfigFile = $(.\bin\xpro.selectitem.exe -path $pathToxProConfig -index $($choice - 1)); # Get the index

    Write-Host  "`nConfig => $($ConfigFile)`n" -ForegroundColor Cyan;

    # write into apppointer
    Push-Location $HOME;
    # Push-Location $($PROFILE |Split-Path -Parent);
        [System.Xml.XmlDocument]$XmlEditor = Get-Content .\Profile.xml; # read profile.xml
        [String]$Path = $(Get-ChildItem .\Profile.xml).FullName; # get the path to the profile.xml
        $XmlEditor.Machine.ConfigFile = "\" + $ConfigFile; # write configfile to AppPointer
        $XmlEditor.Save($Path); # save 
    Pop-Location
Pop-Location