param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide the installation step number between 1 and 3.")]
    [int]$step = 1
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 

.\installCustomizations.ps1 -step $step