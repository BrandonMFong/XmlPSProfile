
Param([String[]] $dir, [Alias('p')][Switch] $push )
#[xml]$x = Get-Content $ConfigFile;
	
foreach ($Directory in $XMLReader.Machine.Directories.Directory)
{
	if($Directory.alias -eq $dir)
	{
		if($push){Push-Location $Directory.InnerXml;}
		else{Set-Location $Directory.InnerXml;}
	}
}