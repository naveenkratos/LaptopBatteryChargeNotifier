Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$vbsPath = "D:\Softwares\LaptopBatteryChargeNotifier\LaptopBatteryChargeNotifier.vbs"
$script:proc = $null

$icon = New-Object System.Windows.Forms.NotifyIcon
# $icon.Icon = [System.Drawing.SystemIcons]::Application
$icon.Icon = New-Object System.Drawing.Icon("D:\Softwares\LaptopBatteryChargeNotifier\battery.ico")
$icon.Visible = $true
$icon.Text = "BatteryNotifier Controller"

$menu = New-Object System.Windows.Forms.ContextMenuStrip

$startItem = $menu.Items.Add("Start Script")
$stopItem  = $menu.Items.Add("Stop Script")
$exitItem  = $menu.Items.Add("Exit")

function Update-Status {
    if ($script:proc -and -not $script:proc.HasExited) {
        $icon.Text = "BatteryNotifier: Running"
        $startItem.Enabled = $false
        $stopItem.Enabled  = $true
    } else {
        $icon.Text = "BatteryNotifier: Stopped"
        $startItem.Enabled = $true
        $stopItem.Enabled  = $false
    }
}

$startItem.Add_Click({
    if (-not ($script:proc -and -not $script:proc.HasExited)) {
        $script:proc = Start-Process "wscript.exe" -ArgumentList "`"$vbsPath`"" -WindowStyle Hidden -PassThru
    }
    Update-Status
})

$stopItem.Add_Click({
    if ($script:proc -and -not $script:proc.HasExited) {
        Stop-Process -Id $script:proc.Id -Force
    }
    Update-Status
})

$exitItem.Add_Click({
    if ($script:proc -and -not $script:proc.HasExited) {
        Stop-Process -Id $script:proc.Id -Force
    }
    $icon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

$icon.ContextMenuStrip = $menu

# Auto-start the script when tray loads
$script:proc = Start-Process "wscript.exe" -ArgumentList "`"$vbsPath`"" -WindowStyle Hidden -PassThru
Update-Status

[System.Windows.Forms.Application]::Run()