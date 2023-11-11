$app_name = "..\typst\target\release\typst.exe"
$app_arguments = "w main.typ --font-path ./fonts"

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $app_name
$pinfo.Arguments = $app_arguments
$pinfo.RedirectStandardOutput = true;
$pinfo.UseShellExecute = false;
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$startTime = Get-Date
$p.Start()
# $p.ProcessorAffinity=0x200000
$p.ProcessorAffinity=0x20
$p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::RealTime
$p.WaitForExit()
$endTime = Get-Date

$timeDifference = New-TimeSpan -Start $startTime -End $endTime

echo $timeDifference.TotalSeconds