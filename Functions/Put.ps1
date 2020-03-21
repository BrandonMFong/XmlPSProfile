<#
.Synopsis
	A spin off of goto.ps1, instead uses the same aliases to put files to the directory specified.
.Description
	Puts files to a directory
.Parameter File
	File you are moving
.Parameter Destination
	The directory you are putting it in
.Example

.Notes

#>
Param([String[]]$File, [Alias ('Dest')][String[]] $Destination)
#[xml]$x = Get-Content $ConfigFile;
[bool]$ProcessExecuted = $false;
	
foreach ($Directory in $XMLReader.Machine.Directories.Directory)
{
	if($Directory.alias -eq $Destination)
	{
		move-item $File $Directory.InnerXml; $ProcessExecuted = $true;
	}
	
}
if(!($ProcessExecuted))
{
	throw "Parameter '$($Destination)' does match any aliases in the configuration.  Please check spelling.";
}