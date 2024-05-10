$clickerJob = $null

#region Functions

#This scriptblock contains the AutoClicker function that clicks down, releases the click, waits and then loops. At the end of the scriptblock the function is called 
$launchAutoClickerFunction= {
param($loopCount,$delay)
    Function AutoClicker($loopCount,$delay){
        try{
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$signature=@'
[DllImport("user32.dll",CharSet=CharSet.Auto,CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
            $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru
        }
        catch{
            Write-Host "Failed to add Win32MouseEvent"
        }

        for($i=0;$i -lt $loopCount;$i++){
            $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0); #Presses left click down
            $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0); #Releases left click
            sleep -Milliseconds $delay
        }
    }
AutoClicker -loopCount $loopCount -delay $delay
}

#This function contains the main components of a keylogger to listen for hotkey presses, without actually logging the key presses anywhere. Once the a hotkey is pressed it will trigger the action within it conditional
function StartKeyTracker() 
{
  # Signatures for API Calls
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  # load signatures and make members available
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru

  try
  {
    #These statements pull the text from the textboxes and store them
    $StartHotKey = $startRunHotKeyTextBox.Text
    $EndHotKey = $interruptRunHotKeyTextBox.Text
    $loopCount = $numberOfLoopsTextBox.Text
    $delayBetweenClicks = $clickDelayTextBox.Text

    $currentState = $true
    # executes and shows the collected key presses
    while ($currentState -eq $true) {
      Start-Sleep -Milliseconds 40
      
      # scan all ASCII codes above 8
      for ($ascii = 9; $ascii -le 254; $ascii++) {
        # get current key state
        $state = $API::GetAsyncKeyState($ascii)

        # is key pressed?
        if ($state -eq -32767) {
          $null = [console]::CapsLock

          # translate scan code to real code
          $virtualKey = $API::MapVirtualKey($ascii, 3)

          # get keyboard state for virtual keys
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

          # prepare a StringBuilder to receive input key
          $mychar = New-Object -TypeName System.Text.StringBuilder
          # translate virtual key
          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
          
          if ($success) 
          { 
            [string] $output = $mychar.ToString()
            Write-Host $output
            if($output -eq $StartHotKey){
               $clickerJob = Start-Job -ScriptBlock $launchAutoClickerFunction -ArgumentList $loopCount,$delayBetweenClicks #|Wait-Job | Receive-Job                
            }
            if($output -eq $EndHotKey){
                Stop-Job $clickerJob
                Remove-Job $clickerJob
                Write-Host "Job ended"
                $currentState = $false                               
            }
          }
        }
      }
    }
  }
  finally
  {
    Write-Host "Closed"
    Stop-Job $clickerJob
    Remove-Job $clickerJob   
  }
}
#endregion

#region Display
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Clicking Tools" Height="460" Width="250" MaxWidth="250" MaxHeight="460">
    <Grid>
        <TabControl HorizontalAlignment="Left" Height="376" Margin="4,4,0,0" VerticalAlignment="Top" Width="234">
            <TabItem Header="Run Details">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Number of Loops" HorizontalAlignment="Left" Margin="10,103,0,0" VerticalAlignment="Top" Width="102"/>
                    <TextBox x:Name="NUMBEROFLOOPSTEXTBOX" HorizontalAlignment="Left" Height="19" Margin="117,108,0,0" TextWrapping="Wrap" Text="10" VerticalAlignment="Top" Width="101"/>
                    <Label Content="HotKey: Start Run" HorizontalAlignment="Left" Margin="10,41,0,0" VerticalAlignment="Top"/>
                    <Label Content="HotKey: Interrupt Run" HorizontalAlignment="Left" Margin="10,72,0,0" VerticalAlignment="Top"/>
                    <TextBox x:Name="STARTRUNHOTKEYTEXTBOX" HorizontalAlignment="Left" Height="18" Margin="170,45,0,0" TextWrapping="Wrap" Text="z" VerticalAlignment="Top" Width="48"/>
                    <TextBox x:Name="INTERRUPTRUNHOTKEYTEXTBOX" HorizontalAlignment="Left" Height="18" Margin="170,76,0,0" TextWrapping="Wrap" Text="x" VerticalAlignment="Top" Width="48"/>
                    <Label Content="Delay between Clicks (ms)" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
                    <TextBox x:Name="CLICKDELAYTEXTBOX" HorizontalAlignment="Left" Height="18" Margin="170,15,0,0" TextWrapping="Wrap" Text="25" VerticalAlignment="Top" Width="48"/>
                </Grid>
            </TabItem>
        </TabControl>
        <Rectangle Fill="#FFF4F4F5" HorizontalAlignment="Left" Height="39" Margin="4,385,0,0" Stroke="Black" VerticalAlignment="Top" Width="234"/>
        <Button Content="Launch" x:Name="LAUNCHBUTTON" HorizontalAlignment="Left" Margin="10,392,0,0" VerticalAlignment="Top" Width="222" Height="27"/>
    </Grid>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$launchButton = $window.FindName("LAUNCHBUTTON")
$numberOfLoopsTextBox = $window.FindName("NUMBEROFLOOPSTEXTBOX")
$clickDelayTextBox = $window.FindName("CLICKDELAYTEXTBOX")
$startRunHotKeyTextBox = $window.FindName("STARTRUNHOTKEYTEXTBOX")
$interruptRunHotKeyTextBox = $window.FindName("INTERRUPTRUNHOTKEYTEXTBOX")

#endregion

#region Button Assignment
$launchButton.Add_Click({
    StartKeyTracker
})
#endregion

#Print Window
$window.ShowDialog()