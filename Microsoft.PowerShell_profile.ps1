<#
.SYNOPSIS
Get Weather of a City

.DESCRIPTION
Fetches Weather report of a City from website - http://wttr.in/ courtsey Igor Chubin [Twitter- @igor_chubin]

.PARAMETER City
Name of City

.PARAMETER Tomorrow
Switch to include tomorrow's Weather report

.PARAMETER DayAfterTomorrow
Switch to include Day after tomorrow's Weather report

.EXAMPLE
Get-Weather  "Los Angles" -Tomorrow -DayAfterTomorrow

.EXAMPLE
'london', 'delhi', 'beijing' | Get-Weather

.NOTES
Blog - Geekeefy.wordpress.com
#>
Function Get-Weather {
    [Alias('Wttr')]
    [Cmdletbinding()]
    Param(
            [Parameter(
                Mandatory = $true,
                HelpMessage = 'Enter name of the City to get weather report',
                ValueFromPipeline = $true,
                Position = 0
            )]
            [ValidateNotNullOrEmpty()]
            [string[]] $City,
            [switch] $Tomorrow,
            [switch] $DayAfterTomorrow
    )

    Process
    {
        Foreach($Item in $City){
            try {
                $Weather = $(Invoke-WebRequest "http://wttr.in/$City" -UserAgent curl).content -split "`n"
                If($Weather)
                {
                    $Weather[0..16]
                    If($Tomorrow){ $Weather[17..26] }
                    If($DayAfterTomorrow){ $Weather[27..36] }
                }
            }
            catch {
                $_.exception.Message
            }
        }            
    }

}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Import posh-git to help with git
Import-Module -Name posh-git

# Start SshAgent

# Start-SshAgent

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode
    Write-VcsStatus

    if (Test-Administrator) {  # if elevated
        Write-Host "(Elevated) " -NoNewline -ForegroundColor White
    }

    Write-Host "$env:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }

    Write-Host $curPath -NoNewline -ForegroundColor Blue
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    $LastExitCode = $origLastExitCode
    "`n$('>' * ($nestedPromptLevel + 1)) "
}

Import-Module posh-git

$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '


Import-Module Get-ChildItemColor

Set-Alias l Get-ChildItemColor -option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -option AllScope