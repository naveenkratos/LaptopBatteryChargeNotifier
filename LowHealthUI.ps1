param(
	[float]$RepeatTimeInSec,
	[float]$BattPercent
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        Title='Notification'
        WindowStartupLocation='Manual'
        Width='450' Height='160'
        WindowStyle='None'
        AllowsTransparency='True'
        Background='Transparent'
        ShowInTaskbar='False'
        Topmost='True'
        Opacity='0.95'>
	
	<Grid>
	
	<Rectangle RadiusX="12" RadiusY="12" Fill="#80000000" Margin="10">
        <Rectangle.Effect>
            <BlurEffect Radius="16"/>
        </Rectangle.Effect>
    </Rectangle>
		
  <Border CornerRadius='12' BorderBrush='#FFFF2D20' BorderThickness='4' Margin='10' >
	<StackPanel Margin='10'>
      <TextBlock Text='Low Battery!' 
                 Foreground='#FFFF2D20' FontSize='28' FontWeight='Bold'
                 TextAlignment='Center' Margin='10'/>
      <TextBlock Text='Connect your charger.' 
                 Foreground='LightGray' FontSize='22' 
                 TextAlignment='Center' Margin='10'/>
    </StackPanel>
  </Border>
  </Grid>
</Window>
"@

# Parse and load the XAML
$reader = [System.XML.XMLReader]::Create([System.IO.StringReader] $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Set the toast position — bottom right corner
$screen = [System.Windows.SystemParameters]::WorkArea
$window.Left = $screen.Right - $window.Width - 20
$window.Top = $screen.Bottom - $window.Height - 20

# Get the OK button and attach event
# $okButton = $window.FindName('okButton')
# $okButton.Add_Click({ $window.Close() })

# Set up a timer for 10 minutes (600 seconds)
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds($RepeatTimeInSec)
$timer.Add_Tick({
    $timer.Stop()
    if ($window.IsVisible) {
        $window.Close()
    }
})
$timer.Start()

# Show the toast until OK is pressed
$window.ShowDialog() | Out-Null
