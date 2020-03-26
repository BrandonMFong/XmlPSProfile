<#
.Synopsis
	This relates an alias to a directory and sets the directory location to alias/dir relationship
.Description
	Useful to easily jump to a directory without writing out the whole path
.Parameter push
	Push-Location instead of set-location

.Parameter AddDirectory
	Use this switch on a directory to add to your list to jump to
.Example
	Goto CDrive -p 
.Notes

#>
Param([String[]] $dir, [Alias('p')][Switch] $push, [switch]$AddDirectory)
[bool]$ProcessExecuted = $false;


if($AddDirectory)
{
	$PathToAdd = (Get-Location).path; # Get the directory you are adding
	Push-Location $PSScriptRoot;
		$add = $(Get-Variable 'XMLReader').Value.CreateElement("Directory"); 
		$Alias = Read-Host -Prompt "Set Alias";
		$add.SetAttribute("alias", $Alias);
		$add.InnerXml = $PathToAdd;
		$x = $(Get-Variable 'XMLReader').Value
		$x.Machine.Directories.AppendChild($add);
		$x.Save($(Get-Variable 'AppPointer').Value.Machine.GitRepoDir + '\Config\' + $(Get-Variable 'AppPointer').Value.Machine.ConfigFile);
	Pop-Location;
	break;
}

Push-Location $PSScriptRoot;
	
	foreach ($Directory in $(Get-Variable 'XMLReader').Value.Machine.Directories.Directory)
	{
		if($Directory.alias -eq $dir)
		{
			if($push){Push-Location $Directory.InnerXml; $ProcessExecuted = $true;}
			else{Set-Location $Directory.InnerXml; $ProcessExecuted = $true;}
		}
		
	}
	if(!($ProcessExecuted))
	{
		throw "Parameter '$($dir)' does match any aliases in the configuration.  Please check spelling.";
	}
