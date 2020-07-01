using module .\..\Classes\Calendar.psm1;
using module .\..\Classes\Math.psm1;
using module .\..\Classes\SQL.psm1;
using module .\..\Classes\List.psm1;

# These are functions used inside other functions

$Sql = [SQL]::new($XMLReader.Machine.Objects.Database,$XMLReader.Machine.Objects.ServerInstance); # This needs to be unique per config

function MakeClass($XmlElement)
{
    try 
    {
        switch($XmlElement.Class.ClassName) # TODO unique tag for classes under tag if have params
        {
            "Calendar" 
            {
                [string]$PathToEventImport = $XmlElement.Class.Calendar.PathToEventImport;
                [string]$EventConfig = $XmlElement.Class.Calendar.EventConfig;
                [string]$TimeStampFilePath = $XmlElement.Class.Calendar.TimeStampFilePath;
                [string]$FirstDayOfWeek = $XmlElement.Class.Calendar.FirstDayOfWeek;
                $x = [Calendar]::new($PathToEventImport,$EventConfig,$TimeStampFilePath,$FirstDayOfWeek);
                return $x;
            }
            "Web" {$x = [Web]::new();return $x;}
            "Calculations" {$x = [Calculations]::new($XmlElement.Class.Math.QuantizedStepSize,$XmlElement.Class.Math.PathToGradeImport,$XmlElement.Class.Math.GradeColors);return $x;}
            "Email" {$x = [Email]::new();return $x;}
            "SQL" 
            {
                [string]$Database = $XmlElement.Class.SQL.Database;
                [string]$ServerInstance = $XmlElement.Class.SQL.ServerInstance;
                [System.Object[]]$Tables = $XmlElement.Class.SQL.Tables;
                [boolean]$Sync = $XmlElement.Class.SQL.SyncConfiguration.ToBoolean($null);
                [boolean]$UpdateVerbose = $XmlElement.Class.SQL.UpdateVerbose.ToBoolean($null);
                [string]$SQLConvertFlags = $XmlElement.Class.SQL.SQLConvertFlags;
                [boolean]$RunUpdates = $XmlElement.Class.SQL.RunUpdates.ToBoolean($null);
                [boolean]$Create = $XmlElement.Class.SQL.CreateDatabase.ToBoolean($null);
                $x = [SQL]::new($Database, $ServerInstance, $Tables, $Sync, $UpdateVerbose, $SQLConvertFlags,$RunUpdates,$Create);
                return $x;
            }
            "List"{$x = [List]::new($XmlElement.Class.List.Title,$XmlElement.Class.List.Redirect,$XmlElement.Class.List.DisplayCompleteWith);return $x;}
            default
            {
                Write-Warning "Class $($XmlElement.Class.ClassName) was not made.";
            }
        }
    }
    catch
    {
        Write-Host "Uncaught: $($_.Exception.GetType().FullName)";
        Write-Warning "$($_)";
        Write-Warning "$($_.ScriptStackTrace)";
    }
}

function _GetXMLContent
{
    return Get-Content $($(Get-Variable -Name 'AppPointer').Value.Machine.GitRepoDir + "\Config\" + $(Get-Variable -Name 'AppPointer').Value.Machine.ConfigFile);
}
function _GetXMLFilePath
{
    return $($(Get-Variable -Name 'AppPointer').Value.Machine.GitRepoDir + "\Config\" + $(Get-Variable -Name 'AppPointer').Value.Machine.ConfigFile).ToString();
}

# If an object is found that has methods we want to use, return that object
# Object must be configured
function GetObjectByClass([string]$Class)
{
    [xml]$xml = _GetXMLContent;
    foreach($Object in $xml.Machine.Objects.Object)
    {
        if(($Object.Type -eq 'PowerShellClass') -and ($Object.Class.Classname -eq $Class))
        {
            return $(Get-Variable $Object.VarName.InnerXml).Value;
        }
    }
    throw "Object not found!";
}

function IsNotPass($x){return ($x -ne "pass");}

function FindNodeInterval($value,[string]$Node,[ref]$start,[ref]$end)
{
    $n = 1; # This helps find the first index
    $u = 0; # This holds the value to figure out how far to look in the interval for another node
    $foundbeginning = $false;
    foreach($v in $value.Key)
    {
        if(($v.Node -eq $Node) -and !$foundbeginning)
        {
            $start.Value = $n-1;
            $u = 1;
            $foundbeginning = $true;
        }
        elseif($v.Node -eq $Node)
        {
            $n++; # Figure out what index this is and that it does not overlap
            $u = $n - $start.Value ; # Expands the interval to look for
        }
        else{$n++;}
    }
    $end.Value = $u;
}
function Evaluate([System.Object[]]$value,[Switch]$IsDirectory=$false)
{
    # param([Switch]$IsGoto)
    if([String]::IsNullOrEmpty($value))
    {
        return $null;
    }
    elseif($value.SecType -eq "private")
    {
        return $Sql.InputReturn($value.InnerText);
    }
    elseif($null -ne $value.NodePointer)
    {
        return $( MakeHash -value $value.ParentNode -lvl $([int]$value.Lvl + 1) -Node $value.NodePointer);# The attributes lvl and nodepointer are not passing
    }
    elseif($value.InnerText.Contains('$')) # if powershell object
    {
        # If user is using PSScriptRoot, must use it in the context that this file will return the script root
        if($value.InnerText.Contains('$PSScriptRoot'))
        {
            if($IsDirectory)
            {
                Push-Location $value.Innertext;
                    [String]$path = (Get-Location).Path;
                Pop-Location;
                return $path;
            }
            else{return $(Get-ChildItem $value.InnerText).Fullname;}
        }
        else{return $(Get-Variable $value.InnerText.Replace('$','')).Value;} # Else return the variable
    }
    else{return $value.InnerText;}
}

# Hmmmmm, what if a node is on difference indexes
# TODO finish.  This might not work out in terms of improving performance
function GetAllIntervals([System.Object[]]$Keys)
{
    # Goal: 
    # - Sweep all nodes [X]
    # - Find nodes and record index []
    # - sort all nodes in []
    #   - [0] A to [last index] Z
    # - implement binary search []
    $t = [Ordered]@{};
    $n = @{"Node"="";"Start"="";"End"="";}; # New node
    [bool]$StartFound = $false; [bool]$EndFound = $false;
    for([int]$i=0;$i -lt $Keys.Length;$i++)
    {
        # If the key has a node, the $n object node is empty and the $n start is empty
        if(![string]::IsNullOrEmpty($Keys[$i].Node) -and [string]::IsNullOrEmpty($n.Node) -and [string]::IsNullOrEmpty($n.Start))
        {
            $n.Start = $i.ToString();
            $n.Node = $Keys[$i].Node;
        }

        # End of the interval. Sort the nodes here
        if(($n.Node -ne $Keys[$i].Node) -and ![string]::IsNullOrEmpty($n.Node) -and ![string]::IsNullOrEmpty($n.Start)) # If node interval just passed
        {
            $n.End = $($i-1).ToString();
            SortHash -t ([ref]$t) -n ([ref]$n) -index:0 -Key $Keys[$i];
            $n = @{"Node"="";"Start"="";"End"="";}; # reset
        }

    }
    return $t;
}

# The higher the alphabet, the higher the index
# So 'A' would be [0]
function SortHash([ref]$t,[ref]$n,[int]$index,[System.Xml.XmlElement]$Key)
{
    [Calculations]$m = [Calculations]::new();
    # if Z > A
    # If the saved node is greater than the next node
    if($m.AsciiToDec($n.Value.Node[$index]) -gt $m.AsciiToDec($Key.Node[$index])){$t.Value.Add($n.Value.Node,$n);}

    # if Z < A
    # If the saved node is less than the next node
    elseif($m.AsciiToDec($n.Value.Node[$index]) -lt $m.AsciiToDec($Key.Node[$index]))
    {
        # sort
        $temp = $t.Value;
        $t.Value = @{};
        $t.Value.Add($n.Value.Node,$n);
        $t = $t + $temp; # Add on top of old
    }
    else{SorHash -t ([ref]$t) -n ([ref]$n) -index:$($index+1) -Key:$Key;}
}

function MakeHash($value,[int]$lvl,[string]$Node)
{
    [Hashtable]$t = @{}; # Init hash object 
    # $IntervalHolder = GetAllIntervals($value.Key);# Only using key because there always has to be a value
    
    if($value.Key.Count -ne $value.Value.Count){throw "Objects must have equal key and values in config."}

    # When there is a node pointer
    elseif(![string]::IsNullOrEmpty($Node))
    {
        $start = 0;$end = 0;
        FindNodeInterval -value $value -Node $Node -start ([ref]$start) -end ([ref]$end);
        for($i=$start;$i -le $($start + $end + 1);$i++)
        {
            if($node -eq $value.Key[$i].Node)
            {
                if(!(($value.Key[$i].Lvl -ne $value.Value[$i].Lvl) -or ([int]$value.Key[$i].Lvl -ne $lvl)))
                {
                    $t.Add($(Evaluate($value.Key[$i])),$(Evaluate($value.Value[$i])));
                }
            }
        }
    }

    # For the leaf node
    else 
    {
        # For the corner case where there is only one node
        if([string]::IsNullOrEmpty($value.Key.Count)){$t.Add($(Evaluate($value.Key)),$(Evaluate($value.Value)));}
        else 
        {
            for($i=0;$i -lt $value.Key.Count;$i++)
            {
                if(!(($value.Key[$i].Lvl -ne $value.Value[$i].Lvl) -or ([int]$value.Key[$i].Lvl -ne $lvl)))
                {
                    $t.Add($(Evaluate($value.Key[$i])),$(Evaluate($value.Value[$i])));
                }
            }
        }
    }
    return $t;
}

function Test {if(!(Test-Path .\archive\)){ mkdir archive;}}

function DoesFileExistInArchive($file)
{
    If(Test-Path $('.\archive\' + $file.Name))
    {

        [string]$NewName = $file.BaseName + " " + (Get-ChildItem $('.\archive\' + $file.Name)).Count.ToString() + $file.Extension;
        Rename-Item $file.Name $NewName;
        Move-Item $NewName .\archive\;
    }
    else{Move-Item $file.Fullname .\archive\;}
}

function LoadPrograms
{
    Param($XMLReader=$XMLReader,$AppPointer=$AppPointer,[switch]$Verbose)
    if(![String]::IsNullOrEmpty($XMLReader.Machine.Programs))
    {
        [int]$Complete = 1;
        [int]$Total = $(CheckCount -Count:$XMLReader.Machine.Programs.Program.Count);
        foreach($val in $XMLReader.Machine.Programs.Program)
        {
            if(!$Verbose)
            {
                Write-Progress -Activity "Loading Programs" -Status "Program: $($val.InnerXML)" -PercentComplete (($Complete / $Total)*100);
                $Complete++;
            }
            Set-Alias $val.Alias "$(Evaluate -value $val)" -Verbose:$Verbose -Scope Global;
        }
        Write-Progress -Activity "Loading Programs" -Status "Program: $($val.InnerXML)" -Completed;
    }
}
function LoadModules
{
    Param($XMLReader=$XMLReader,[switch]$Verbose)
    if(![String]::IsNullOrEmpty($XMLReader.Machine.Modules))
    {
        [int]$Complete = 1;
        [int]$Total = $(CheckCount -Count:$XMLReader.Machine.Modules.Module.Count);
        foreach($val in $XMLReader.Machine.Modules.Module)
        {
            if(!$Verbose)
            {
                Write-Progress -Activity "Loading Modules" -Status "Module: $($val)" -PercentComplete (($Complete / $Total)*100);
                $Complete++;
            }
            Import-Module $($val) -Verbose:$Verbose -Scope Global -DisableNameChecking;
        }
        Write-Progress -Activity "Loading Modules" -Status "Module: $($val.InnerXML)" -Completed;
    }
}

function LoadObjects
{
    Param($XMLReader=$XMLReader,[switch]$Verbose)
    if(![String]::IsNullOrEmpty($XMLReader.Machine.Objects))
    {
        [int]$Complete = 1;
        [int]$Total = $(CheckCount -Count:$XMLReader.Machine.Objects.Object.Count);
        foreach($val in $XMLReader.Machine.Objects.Object)
        {
            if(!$Verbose)
            {
                Write-Progress -Activity "Loading Objects" -Status "Object: $($val.VarName.InnerXML)" -PercentComplete (($Complete / $Total)*100);
                $Complete++;
            }
            switch ($val.Type)
            {
                "PowerShellClass"{New-Variable -Name "$($val.VarName.InnerXml)" -Value $(MakeClass -XmlElement $val) -Force -Verbose:$Verbose -Scope Global;break;}
                "XmlElement"{New-Variable -Name "$($val.VarName.InnerXml)" -Value $val.Values -Force -Verbose:$Verbose -Scope Global;break;}
                "HashTable"{New-Variable -Name "$(Evaluate -value $val.VarName)" -Value $(MakeHash -value $val -lvl 0 -Node $null) -Force -Verbose:$Verbose -Scope Global; break;}
                default {New-Variable -Name "$($val.VarName.InnerXml)" -Value $val.Values -Force -Verbose:$Verbose -Scope Global;break;}
            }
        } 
        Write-Progress -Activity "Loading Objects" -Status "Object: $($val.VarName.InnerXML)" -Completed;
    }
}

function LoadDrives
{
    Param($XMLReader=$XMLReader,[switch]$Verbose)
    if(![String]::IsNullOrEmpty($XMLReader.Machine.NetDrives))
    {
        [int]$Complete = 1;
        [int]$Total = $(CheckCount -Count:$XMLReader.Machine.NetDrives.NetDrive.Count);
        foreach($val in $XMLReader.Machine.NetDrives.NetDrive)
        {
            if(!$Verbose)
            {
                Write-Progress -Activity "Loading Drives" -Status "Drive: $($val.IPAddress.InnerXML)" -PercentComplete (($Complete / $Total)*100);
                $Complete++;
            }
            if(!(Test-Path $val.DriveLetter))
            {
                # net use $XMLReader.Machine.NetDrives.NetDrive.DriveLetter $XMLReader.Machine.NetDrives.NetDrive.IPAddress.InnerText
                net use $val.DriveLetter $(Evaluate -value:$val.IPAddress) $(Evaluate -value:$val.Password) /user:$(Evaluate -value:$val.Username);
            }
        } 
        Write-Progress -Activity "Loading Drives" -Status "Drive: $($val.IPAddress.InnerXML)" -Completed;
    }
}

function CheckCount # I guess in Powershell v5 the count on an xml with one node returns node
{
    Param([int]$Count)
    if(!$Count){return 1;}
    else{return $Count;}
}



function InsertFromCmd
{
    Param([string]$Tag,[string]$PathToAdd)
        # [XML]$x = Get-Content $($(Get-Variable 'AppPointer').Value.Machine.GitRepoDir + '\Config\' + $(Get-Variable 'AppPointer').Value.Machine.ConfigFile);
        [XML]$x = _GetXMLContent;
        $add = $x.CreateElement($Tag); 

        $Alias = Read-Host -Prompt "Set Alias";
        $add.SetAttribute("Alias", $Alias);

        $Security = Read-Host -Prompt "Is this private? (y/n)?";
        if($Security -eq "y")
        {
            $add.SetAttribute("SecType", "private");
            
            $insert = GetObjectByClass('SQL');
            [int]$MaxID = $insert.GetMax('PersonalInfo');
            [string]$GuidString = $insert.GetGuidString();
            [string]$subject = Read-Host -Prompt "Subject?";
            [int]$TypeContentID = ($insert.Query("select id as ID from typecontent where externalid = '$(GetTCExtID($Tag))'")).ID; # id must exist
            $querystring = "insert into PersonalInfo values ($($MaxID), $($GuidString),'$($PathToAdd)', '$($subject)', $($TypeContentID), GETDATE(), GETDATE())";

            Write-Host "`nQuery: " -NoNewline;Write-Host "$($querystring)`n" -foregroundcolor Cyan;
            $insert.Query($querystring);

            $Var = ($insert.Query("select guid as Guid from personalinfo where id = $($MaxID)")).Guid;
            $add.InnerXml = $Var.Guid; # Adding guid
        }
        else
        {
            $add.SetAttribute("SecType", "public")
            $add.InnerXml = $PathToAdd; # Adding literally path
        }
        
        AppendCorrectChild -Tag $Tag -add $add -x $([ref]$x);
        $x.Save($(Get-Variable 'AppPointer').Value.Machine.GitRepoDir + '\Config\' + $(Get-Variable 'AppPointer').Value.Machine.ConfigFile);
}
function GetFullFilePath([string]$File)
{
    return (Get-ChildItem $File).FullName
}

function AppendCorrectChild([string]$Tag,$add,[ref]$x)
{
    switch($Tag)
    {
        "Directory"{$x.Value.Machine.Directories.AppendChild($add);}
        "Program"{$x.Value.Machine.Programs.AppendChild($add);}
        default{throw "Something Bad Happened"}
    }
}

function GetTCExtID([string]$Type)
{
    [string]$str = "";
    switch($Type)
    {
        "Directory"{$str = "PrivateDirectory"}
        "Program"{$str = "PrivateProgram"}
        default{throw "Something Bad Happened"}
    }
    return $str;
}

function Test-KeyPress
{
    param
    (
        [Parameter(Mandatory)]
        [ConsoleKey]
        $Key,

        [System.ConsoleModifiers]
        $ModifierKey = 0
    )
    if ([Console]::KeyAvailable)
    {
        $pressedKey = [Console]::ReadKey($true)

        $isPressedKey = $key -eq $pressedKey.Key
        if ($isPressedKey)
        {
            return ($pressedKey.Modifiers -eq $ModifierKey);
        }
        else
        {
            return $false
        }
    }
}

function EmailOrder([int]$i,[int]$Max,[int]$OrderFactor)
{
    [System.Xml.XmlDocument]$xml = _GetXMLContent;
    if($xml.Machine.Email.ListOrderBy -eq "Asc")
    {
        return ($i -lt ($Max - $OrderFactor));
    }
    elseif($xml.Machine.Email.ListOrderBy -eq "Desc")
    {
        return ($i -gt ($OrderFactor - $Max));
    }
    else
    {
        return $false;
    }
}

function CheckCredentials
{
    # If the security elements are configured
    if(![String]::IsNullOrEmpty($XMLReader.Machine.ShellSettings.Security.Secure))
    {
        if($XMLReader.Machine.ShellSettings.Security.Secure.ToBoolean($null) -and !$LoggedIn)
        {
            Write-Host "CONFIG: $($AppPointer.Machine.ConfigFile)`n" -foregroundcolor Gray;
            $cred = Get-Content ($AppPointer.Machine.GitRepoDir + "\bin\credentials\user.JSON") | ConvertFrom-Json  
            [string]$user = Read-Host -prompt "Username"; 

            # Get Secure string and then convert it back to plain text
            [System.Object]$var = Read-Host -prompt "Password" -AsSecureString; 
            [System.ValueType]$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($var);
            [String]$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
            
            if(($user -ne $cred.Username) -or ($cred.Password -ne $(GetPassWord -password:$password -cred:$cred)))
            {
                Write-Error "WRONG CREDENTIALS";
                Start-Sleep 1;
                Pop-Location;
                if($XMLReader.Machine.ShellSettings.Security.CloseSessionIfIncorrect.ToBoolean($null)){Stop-Process -Id $PID;}
                else{exit;}
            }
            else{[Boolean]$x = $true; New-Variable -Name LoggedIn -Value $x -Scope Global;}
        }
    }
    Write-Host "`n";
}

function GetPassWord([String]$password, [System.Object[]]$cred) # Encrypts password
{
    # PlainText
    if($cred.Decode -eq "PlainText"){return $password;}
    # Binary
    elseif($cred.Decode -eq "Binary")
    {
        [string]$out = $null;
        [Calculations]$math = [Calculations]::new();
        for($i = 0;$i -lt $password.Length;$i++){$out += $math.IntToBinary($math.AsciiToDec($password[$i]))}
        return $out;
    }
    # HexMax
    elseif($cred.Decode -eq "HexMax")
    {
        [string]$out = $null;
        [Calculations]$math = [Calculations]::new();
        for($i = 0;$i -lt $password.Length;$i++)
        {
            $string = $math.IntToBinary($math.AsciiToDec($password[$i]));
            for($j = 0;$j -lt $string.Length;$j = $j + 4)
            {
                $out += $math.BinaryToInt($string.Substring($j,4));
            }
        }
        return $out;
    }
    else{return $password;}
}

function GenerateEncryption
{
    param
    (
        [ValidateSet('PlainText','Binary','HexMax')]
        [string]$Encryption,
        [Parameter(Mandatory)][string]$password
    )
    $t = @{"Decode"=$Encryption};
    GetPassWord -password:$password -cred:$t;
}

function CreateCredentials
{
    [System.Object[]]$user = @{"Username"="";"Password"="";"Decode"=""};
    [string]$CredPath = ($AppPointer.Machine.GitRepoDir + "\bin\credentials\user.JSON").ToString();
    New-Item $CredPath -Force;
    $user | ConvertTo-Json | Out-File $CredPath;
    Write-Host "Created credential file.  Must manually ecrypt and apply." -ForegroundColor Gray;
}