Import-Module $($PSScriptRoot +  '\FunctionModules.psm1') -DisableNameChecking;

function Hop 
{
    Param($j)
    if ($j -gt 0)
    {
        $j = $j - 1;
        Set-Location ..;
        hop $j;
    }
}

function Jump 
{
    
    Param($j)

    for($i = 0; $i -lt $j; $i++)
    {
        Set-Location ..;
    }
}

function Slide
{
    Param([int]$j)
    while($j -gt 0){Set-Locatioin ..;$j = $j - 1}
}

function CL {Clear-Host;Get-ChildItem;}

function Restart-Session{Start-Process powershell;exit;}
function Start-Admin{Start-Process powershell -Verb Runas;}

function List-Color{[Enum]::GetValues([System.ConsoleColor])}
function Open-Settings{start ms-settings:;}
function Open-Bluetooth{start ms-settings:bluetooth;}
function Open-Display{start ms-settings:display;}

function Get-BatteryLife{Write-Host "Battery @ $((Get-WmiObject win32_battery).EstimatedChargeRemaining )%" -ForegroundColor Cyan}

function Open-Clock{explorer.exe shell:Appsfolder\Microsoft.WindowsAlarms_8wekyb3d8bbwe!App}

function Set-Brightness
{
    param([int]$Percentage)
    $monitor = Get-WmiObject -ns root/wmi -class wmiMonitorBrightNessMethods
    $monitor.WmiSetBrightness(0,$Percentage)
}

function Reload-Profile {.$PROFILE}
