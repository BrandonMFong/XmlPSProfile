<#
.Synopsis
   Setup script for powershell
.Notes
#>
Param(
   [System.Management.Automation.SwitchParameter]$UpdateProfile,
   [System.Management.Automation.SwitchParameter]$ForceUpdate,
   [System.Management.Automation.SwitchParameter]$UpdateConfig,
   [System.Management.Automation.SwitchParameter]$CheckUpdate,
   [String]$ConfigName=$null,
   [ref]$BooleanReply
)
Import-Module .\Modules\Setup.psm1;

[Bool]$okayToContinue = $true;
[Bool]$status = $true; 
[String[]]$tempContent;
[String]$tempFilePath;

function UpdateProfile 
{
   Param([bool]$ForceUpdate=$false)
   [Bool]$status = $true; # is this the global?
   [String]$ProfPath;
   [string]$tempPath;

   # Get full path to git repo's profile script
   $ProfPath = $PSScriptRoot + "\profile.ps1";

   # Get the time stamp for what the user has
   [datetime]$PSProfileDate = $(Get-ChildItem $PROFILE).LastWriteTime; # Timestamp for msprofile script

   # Get the time stamp for the repo's profile
   [datetime]$GitProfileDate = $(Get-ChildItem $ProfPath).LastWriteTime; # Timestamp for repo profile script

   # Compare each Date
   if(($GitProfileDate -gt $PSProfileDate) -or ($ForceUpdate))
   {
      if(!$ForceUpdate)
      {
         Write-Host  "`nThere is an update to $($Global:AppJson.RepoName) profile." -ForegroundColor Red
         $update = Read-Host -Prompt "Want to update? (y/n)";
      }

      if(($update -eq "y") -or ($ForceUpdate))
      {
         Remove-Item $PROFILE -Verbose; 
         Copy-Item $ProfPath $($PROFILE | Split-Path -Parent) -Verbose;

         $tempPath = $($PROFILE | Split-Path -Parent) + "\" + $($ProfPath | Split-Path -Leaf);
         Rename-Item $tempPath $PROFILE -Verbose;

         $status = $true;
      }
      else
      {
         Write-Host "`nNot updating.`n" -ForegroundColor Red -BackgroundColor Yellow; 
         $status = $false;
      }
   }
   else
   {
      Write-Host "`nNo updates to profile`n" -ForegroundColor Green; 
      $status = $true;
   }

   if($status)
   {
      Write-Warning "Profile was updated";
   }

   return $status;
}

function UpdateConfig()
{
   Param([string]$ConfigName=$null,[Switch]$CheckUpdate)
   [String]$tempString = "";
   $tempString = $PSScriptRoot + "\Config\app.json"; # TODO use binaries
   [System.Object[]]$AppJson = Get-Content $tempString | ConvertFrom-Json; # Get app config

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

            Write-Warning "Config was updated";
            return 1; # Exiting code
         }
         else
         {
            return 0;
         }
      }
      else
      {
         return 0;
      }
   }
   else 
   {
      # Create AppPointer
      Write-Host "Config files to choose from:";
      [string]$pathToxProConfig = $PSScriptRoot + "\" + $AppJson.Directories.UserConfig;
      [string]$xProEnumDir = $PSScriptRoot + "\bin\xpro.enumdir.exe";
      $(& $xProEnumDir $pathToxProConfig); # Get items from the user config
      $choice = Read-Host -Prompt "So"; # Get user's choice 
      [string]$xProSelectItem = $PSScriptRoot + "\bin\xpro.selectitem.exe";
      [String]$ConfigFile = $(& $xProSelectItem -path $pathToxProConfig -index $($choice - 1)); # Get the index
   
      Write-Host  "`nConfig => $($ConfigFile)`n" -ForegroundColor Cyan;
   
      # write into apppointer
      [String]$xAppPointerPath = $HOME + "\Profile.xml";
      [System.Xml.XmlDocument]$XmlEditor = Get-Content $xAppPointerPath; # read profile.xml
      [String]$Path = $(Get-ChildItem $xAppPointerPath).FullName; # get the path to the profile.xml
      $XmlEditor.Machine.ConfigFile = "\" + $ConfigFile; # write configfile to AppPointer
      $XmlEditor.Save($Path); # save 
   }
}

# Profile
if($okayToContinue)
{
   if($UpdateProfile)
   {
      $status = [Bool]$(UpdateProfile -ForceUpdate:$ForceUpdate);
      if($status)
      {
         $BooleanReply.Value = $true
      }
      else 
      {
         $BooleanReply.Value = $true
      }

      $okayToContinue = $false;
   }
}

# Config
if($okayToContinue)
{
   if($UpdateConfig)
   {
      $status = UpdateConfig -ConfigName:$ConfigName -CheckUpdate:$CheckUpdate;
      if($status)
      {
         $LASTEXITCODE = 0;
      }
      else 
      {
         $LASTEXITCODE = 1;
      }
      
      $okayToContinue = $false;
   }
}

if($okayToContinue)
{
   Write-Host "";
   Write-Host " .----------------.  .----------------.  .----------------.  .----------------. " -ForegroundColor Cyan;
   Write-Host "| .--------------. || .--------------. || .--------------. || .--------------. |" -ForegroundColor Cyan;
   Write-Host "| |  ____  ____  | || |   ______     | || |  _______     | || |     ____     | |" -ForegroundColor Cyan;
   Write-Host "| | |_  _||_  _| | || |  |_   __ \   | || | |_   __ \    | || |   .'    ``.   | |" -ForegroundColor Cyan;
   Write-Host "| |   \ \  / /   | || |    | |__) |  | || |   | |__) |   | || |  /  .--.  \  | |" -ForegroundColor Cyan;
   Write-Host "| |    > ``' <    | || |    |  ___/   | || |   |  __ /    | || |  | |    | |  | |" -ForegroundColor Cyan;
   Write-Host "| |  _/ /'``\ \_  | || |   _| |_      | || |  _| |  \ \_  | || |  \  ``--'  /  | |" -ForegroundColor Cyan;
   Write-Host "| | |____||____| | || |  |_____|     | || | |____| |___| | || |   ``.____.'   | |" -ForegroundColor Cyan;
   Write-Host "| |              | || |              | || |              | || |              | |" -ForegroundColor Cyan;
   Write-Host "| '--------------' || '--------------' || '--------------' || '--------------' |" -ForegroundColor Cyan;
   Write-Host " '----------------'  '----------------'  '----------------'  '----------------' " -ForegroundColor Cyan;
   Write-Host "Author: Brando" -ForegroundColor DarkGray;
   Write-Host "";

   Write-Host "";
}

if($okayToContinue)
{
   Write-Warning "$($Global:AppJson.RepoName) uses Microsoft.PowerShell_profile.ps1 script.  Continuing will erase the script."
   $Answer = Read-Host -Prompt "Continue(y/n)?"
   if($Answer -ne "y")
   {
      Write-Warning "Exiting...";
      $status = $false;
   }

   $okayToContinue = $status;
}

if($okayToContinue)
{
   Write-Host "`nInitializing setup`n";
   
   # Create Profile
   if(!(Test-Path $Profile))
   { 
      New-Item -Path $Profile -Type File -Force;
   }

   $status = $(UpdateProfile -ForceUpdate:$true);

   if($status)
   {
      Write-Host "`nProfile established!`n" -BackgroundColor Black -ForegroundColor Yellow;  
   }
   else
   {
      Write-Warning "`nError in making profile`n"
   }

   $okayToContinue = $status;
}

# Config
if($okayToContinue)
{
   # _InitConfig;
   Write-Host "Creating AppPointer";

   # Construct empty xml file
   [XML]$NewXml = [XML]::new();
   $Node_Machine = $NewXml.CreateElement("Machine");
   $Node_Machine.SetAttribute("MachineName",$env:COMPUTERNAME);
   $Node_GitRepoDir = $NewXml.CreateElement("GitRepoDir");
   $Node_ConfigFile = $NewXml.CreateElement("ConfigFile");
   $NewXml.AppendChild($Node_Machine);
   $NewXml.Machine.AppendChild($Node_GitRepoDir)
   $NewXml.Machine.AppendChild($Node_ConfigFile)
   $NewXml.Machine.GitRepoDir = $PSScriptRoot;

   [String]$FileName = $HOME + "\Profile.xml"; # Get file name
   $NewXml.Save($FileName); # save the contents to the file

   $status = [byte]$(Test-Path $FileName);
   
   if(!$status)
   {
      Write-Warning "Error in creating file";
   }

   $tempContent = (Get-Content $FileName);

   if($tempContent.Length -eq 0)
   {
      Write-Warning "No content in file";
      $status = 0;
   }

   $okayToContinue = $status;
}

if($okayToContinue)
{
   # _WriteFullContent($FileName); # get the empty xml file 
   [String]$content = Get-Content $FileName; # get the content
   [String]$FirstLine = "<?xml version=`"1.0`" encoding=`"ISO-8859-1`"?>`n";
   [String]$FullContent = $FirstLine + $content; # put first line 
   $FullContent | Out-File $FileName; 

   $tempContent = $(Get-Content $FileName);

   # Useing contains because of the `n 
   $status = $FirstLine.Contains($tempContent[0]);

   if(!$status)
   {
      Write-Warning "Firstline was not written";
   }

   $okayToContinue = $status;
}

if($okayToContinue)
{
   [byte]$userIntInput = Read-Host -Prompt "What do you want to do?`nCreate New Config[1]`nUse Existing Confg[2]`nSo"

   # New config
   if ($userIntInput -eq 1)
   {
      [String]$ConfigurationName = Read-Host -Prompt "Name the configuration file";
      $NewXml.Machine.ConfigFile = $("\" + $ConfigurationName + ".xml");

      Write-Host "`nPlease review:" -Foregroundcolor Cyan;
      Write-Host("Machine Name : $($NewXml.Machine.MachineName)");
      Write-Host("Git Repository Directory : $($NewXml.Machine.GitRepoDir)");
      Write-Host("Configuration File : $($NewXml.Machine.ConfigFile)");

      if($(Read-Host -Prompt "Approve? (y/n)") -ne "y")
      {
         Write-Warning "Please restart setup."
         $status = 0;
      } # maybe call this function again

      # TODO give the user an option to put in their own path 
      if($status)
      {
         $tempFilePath = $PSScriptRoot + "\Config\Users\Kamanta.xml"; # TODO read from app settings
         [XML]$File = Get-Content $tempFilePath;
         $File.Save($($PSScriptRoot + '\Config\Users\' + $ConfigurationName + '.xml'));
      }
   }
   elseif($userIntInput -eq 2) 
   {
      # .\.\update-config.ps1;
      UpdateConfig;
   }
   else
   {
      Write-Warning "Please Specify an option"
      $status = 0;
   }

   $okayToContinue = $status;
}

# if($okayToContinue)
# {
#    $LASTEXITCODE = 0;
# }
# else 
# {
#    $LASTEXITCODE = 1;
# }
