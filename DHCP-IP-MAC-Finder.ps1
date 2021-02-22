#This Powershell script module was written by Geoff Clark.

$author = "Geoff Clark"
$version = "1.0.0-2021.02.21"
$contactInfo = 
"E-Mail: info@clarktribegames.com
Discord: https://discord.gg/6kW4der"



function dhcpCheckBoxOn() {
    if($notDHCPServer.CheckState) {
        $dhcpCheck.Enabled = $false
        $dhcpText.Enabled = $false
        $dhcpExport.Enabled = $false
        } else {
            $dhcpText.Enabled = $true
            $dhcpExport.Enabled = $true
    }
    $importCheck.Enabled = $false
    $openButton.Enabled = $false
    $dhcpButton.Enabled = $false
    $noteButton.Enabled = $false
}

function dhcpCheckBoxOff() {
    $dhcpText.Enabled = $false
    $dhcpExport.Enabled = $false
    $importCheck.Enabled = $true
    if($notDHCPServer.CheckState) {
        $dhcpCheck.Enabled = $false
    }
}

function dhcpExportButton() { 
    Try {
        fetchDHCPLeases($dhcpText.Text)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("This function will not work on this machine!`n`nTry running this tool directly on the DHCP server.`nOr try the Import File -> Copy Code -> Notepad -> Open File option.","Cannot Use This Function!")
            $dhcpCheck.Checked = $false
            $notDHCPServer.Checked = $true
            $dhcpText.Text = ""
            dhcpCheckBoxOff
        }
}

function dhcpCodeButton() {
    [System.Windows.Forms.MessageBox]::Show("How to Use This Code:`n`n- Log into the DHCP Server as an Elevated Admin.`n- Open Powershell as Admin`n- Paste the Code (Copied to Clipboard from this button).`n- Run the pasted code in the PS Admin session.`n- Once complete, prompt confirm copy of scopes to clipboard.`n- Click Notepad on this Module.`n- Info will be pasted.`n- Save content as .txt file.`n- Import with Import File button.`n- Proceed with your search with this tool.","Instructions")
    getPSforDHCPScopes | clip
}


function notepadButton() {
    Get-Clipboard | Out-Notepad
}

function importCheckBoxOn() {
    $dhcpCheck.Enabled = $false
    $dhcpText.Enabled = $false
    $dhcpExport.Enabled = $false
    $openButton.Enabled = $true
    $noteButton.Enabled = $true
    $dhcpButton.Enabled = $true
}

function importCheckBoxOff() {
    if($notDHCPServer.CheckState) {
        $dhcpCheck.Enabled = $false
        $dhcpText.Enabled = $false
        $dhcpExport.Enabled = $false
        } else {
            $dhcpCheck.Enabled = $true
            $dhcpText.Enabled = $true
            $dhcpExport.Enabled = $true
        }
    $openButton.Enabled = $false
    $noteButton.Enabled = $false
    $dhcpButton.Enabled = $false
}

function openFileButton() {
    $importCheck.Enabled = $false
    $openButton.Enabled = $false
    $noteButton.Enabled = $false
    $dhcpButton.Enabled = $false

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "Text Tab Delimited Files (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $filePath = $OpenFileDialog.FileName 
    $loadedContent = Get-Content $filePath | Where-Object { $_ -ne "" } | ForEach-Object { $_.TrimStart(" ") + "`n" }
    if($loadedContent.length -le 2) {
        $sourceText.Text = "This file is not usable.  Try importing another file."
        $importCheck.Enabled = $true
        importCheckBoxOn
    } else {
        $sourceText.Text = $filePath
        $findButton.Enabled = $true
        $inputText.Enabled = $true
    }
}


function findButton() {
    $outputText.Enabled = $true
    $filePath = $sourceText.Text
    $findThis = $inputText.Text -replace (' ','')
    $importedData = Get-Content $filePath | Where-Object { $_ -ne "" } | ForEach-Object { $_.TrimStart(" ") + "`n" }
    $importedText.Text = $importedData
    $whichisIt = isitMacroIP($findThis)
    $result = ""
    if($whichisIt -eq "IP" -or $whichisIt -eq "MAC") {
        foreach($line in $importedText.lines) {
            if($whichisIt -eq "MAC") {
                $findwoch = $findThis -replace '[^a-zA-Z0-9 - ]',''
                $linewoch = $line -replace '[^a-zA-Z0-9 - ]',''
                if($linewoch.Contains($findwoch)) {
                    $copyButton.Enabled = $true
                    $result = resultParser $whichisIt $findThis $line
                    $outputText.Text = (IPtoSearchable($result))
                }
            } else {
                $findThis = (IPtoSearchable($findThis))
                if($line.Contains($findThis)) {
                    $copyButton.Enabled = $true
                    $result = resultParser $whichisIt $findThis $line
                    $outputText.Text = $result
                }
            }
        }
     } else {
        $result = "Source IP/MAC - INVALID FORMAT!"
        $copyButton.Enabled = $false
        $outputText.Text = $result
    }
    if($result.Length -lt 1) {
        $result = "Nothing Found!"
        $copyButton.Enabled = $false
        $outputText.Text = $result
    }
}

function copyButton() {
    $outputText.Text | clip
}

function clearButton() {
    if($findButton.Enabled) {
        $findButton.Enabled = $true
    } else {
        $findButton.Enabled = $false
    }
    $inputText.Text = ""
    $outputText.Text = ""
    $copyButton.Enabled = $false
}

function resetButton() {
    $answertoClear = areyouSure("you want to reset the fields")
    if($answertoClear -eq 'Yes') {
        $dhcpCheck.Enabled = $true
        $importCheck.Enabled = $true
        $notDHCPServer.Checked = $false
        $dhcpCheck.Checked = $false
        $importCheck.Checked = $false
        $noteButton.Enabled = $false
        $dhcpButton.Enabled = $false
        $dhcpExport.Enabled = $false
        $findButton.Enabled = $false
        $inputText.Enabled = $false
        $sourceText.Text = ""
        $dhcpText.Text = ""
        $inputText.Text = ""
        $outputText.Text = ""
        $copyButton.Enabled = $false
    }
}

function helpButton() {
    [System.Windows.Forms.MessageBox]::Show("This tool was designed to simplify the process`nof searching for IP/MAC addresses on a Windows`nbased DHCP Server.`n`nNote:  Any File Imports need to be in the format `nof a DHCPServerv4Lease format.  If you don't know `nwhat this is, use the Import File -> Copy Code `nfeature and follow the on-screen instructions.`n`nIn most cases, to use the DHCP server direct`noption, you will need to run this app directly on `nthe DHCP server itself and use localhost for the `nserver name.  It may work on an external workstation `nbut not always.  This app will tell you if it will `nwork or not.`n`nThis PS script module was written by "+$author+".`n`nVersion:  "+$version+"`n`nContact Info:`n`n"+$contactInfo+"`n`nThis can be freely distributed and used as needed.","Here To Help You")
}

function areyouSure([String] $type) {
    $caption = "Are You Sure?"
    $message = "Are you sure " + $type + "?"

    $continue = [System.Windows.Forms.MessageBox]::Show($message, $caption, 'YesNo');
    
    return $continue
}

function fetchDHCPLeases([String] $serverName) {
    $scopes = Get-DhcpServerv4Scope -ComputerName $serverName
    $result =  foreach ($Scope in $Scopes) {
        Get-DHCPServerv4Lease -ScopeID $Scope.ScopeId
    }
    $result | clip
    [System.Windows.Forms.MessageBox]::Show("Export of the DHCP Leases have been copied to the clipboard.`nClick the Notepad button and save the content as a .txt file.`nFrom there, click Open File and Import the File.","Alert")
    $dhcpCheck.Checked = $false
    $dhcpText.Text = ""
    dhcpCheckBoxOff
    $importCheck.Checked = $true
    importCheckBoxOn
    $dhcpButton.Enabled = $false
}


function getPSforDHCPScopes {
return '$scopes = Get-DhcpServerv4Scope -ComputerName localhost
$result =  foreach ($Scope in $Scopes)
{Get-DHCPServerv4Lease -ScopeID $Scope.ScopeId}
$result | clip
[System.Windows.Forms.MessageBox]::Show("Export of the DHCP Leases have been copied to the clipboard.`nPaste into Notepad on your local desktop and save as a .txt file","Alert")
Exit'
}

function Out-Notepad {
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]
    [AllowEmptyString()] 
    $Text
  )

  begin
  {
    $sb = New-Object System.Text.StringBuilder
  }

  process
  {
    $null = $sb.AppendLine($Text)
  }
  end
  {
    $text = $sb.ToString()

    $process = Start-Process notepad -PassThru
    $null = $process.WaitForInputIdle()


    $sig = '
      [DllImport("user32.dll", EntryPoint = "FindWindowEx")]public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
      [DllImport("User32.dll")]public static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);
    '

    $type = Add-Type -MemberDefinition $sig -Name APISendMessage -PassThru
    $hwnd = $process.MainWindowHandle
    [IntPtr]$child = $type::FindWindowEx($hwnd, [IntPtr]::Zero, "Edit", $null)
    $null = $type::SendMessage($child, 0x000C, 0, $text)
  }
}

function isitMacroIP([String] $testData) {
    $checkData = $testData -replace '[a-zA-Z0-9]',''
    if($checkData -eq '...') {
        return "IP"
        } else {
            $checkData = $testData -replace '[^a-zA-Z0-9 - ]',''
            if($checkData.Length -eq 12) {
                return "MAC"
            } else {
                return "INV"
            }
        }
}

function resultParser([String] $whichOne, [String] $MACorIP, [String] $foundString) {
    $noSpaces = processString($foundString)
    $resultArray = $noSpaces.Split(" ")
    $endResult = ""
    if($whichOne -eq "IP") {
        foreach($string in $resultArray) {
            $findMAC = isitMacroIP($string)
            if($findMAC -eq "MAC") {
                $endResult = $string
            }
        }
        $checkData = $endResult -replace  '[^a-zA-Z0-9 - ]',''
        if($checkData.Length -eq 12) {
            $sb = New-Object System.Text.StringBuilder
            $sb.Append($checkData.substring(0,4)) | Out-Null
            $sb.Append(".") | Out-Null
            $sb.Append($checkData.substring(4,4)) | Out-Null
            $sb.Append(".") | Out-Null
            $sb.Append($checkData.substring(8,4)) | Out-Null
            $checkData = $sb.ToString()
        } else {
            $checkData = "FOUND BUT INVALID MAC"
            $copyButton.Enabled = $false
        }
        return $checkData
    }
    if($whichOne -eq "MAC") {
        foreach($string in $resultArray) {
            $findMAC = isitMacroIP($string)
            $checkIPforZero = ""
            $continueOn = $false
            if($findMAC -eq "IP") {
                $checkIPforZero = IPtoZeroIP($string)
                if(($checkIPforZero.Substring($checkIPforZero.Length-3,3) -eq "000")) {
                    $continueOn = $false
                } else {
                    $continueOn = $true
                }
            }
            if($findMAC -eq "IP" -and ($continueOn)) {
                $endResult = IPtoZeroIP($string)
            }
        }
        return $endResult
    }
    if($whichOne -ne "MAC" -and $whichOne -ne "IP") {
        return "Source IP/MAC - INVALID FORMAT!"
        $result = "Source IP/MAC - INVALID FORMAT!"
        $copyButton.Enabled = $false
        $outputText.Text = $result
    }
}

function processString ([String] $ogString) {
    $newString = $ogString
    while ($newString.Contains('  ')) {
        $newString = $newString -replace '  ',' '
    }
    return $newString
}

function IPtoZeroIP ([String] $OGIP) {
    $sbIP = New-Object System.Text.StringBuilder
    $OGIPArray = $OGIP.Split('.')
    foreach($subnet in $OGIPArray) {
        $newSubnet = ""
        switch($subnet.length) {
            0 { $newSubnet = "000" }
            1 { $newSubnet = "00" + $subnet }
            2 { $newSubnet = "0" + $subnet }
            3 { $newSubnet = $subnet }
        }
        $sbIP.Append($newSubnet + '.') | Out-Null
    }
    $newIP = ($sbIP.ToString())
    $newIp = $newIP.Substring(0,$newIP.Length-1)
    return $newIP
}

function IPtoSearchable ([String] $OGIP) {
    $sbIP = New-Object System.Text.StringBuilder
    $OGIPArray = $OGIP.Split('.')
    foreach($subnet in $OGIPArray) {
        $newSubnet = $subnet
        if($subnet.Length -eq 3) {
            if($subnet.Substring(0,1) -eq "0") {
                $newSubnet = $subnet.Substring(1,2)
            }
            if($subnet.Substring(0,2) -eq "00") {
                $newSubnet = $subnet.Substring(2,1)
            }
            if($subnet -eq "000") {
                $newSubnet = "0"
            }
        }
        if($subnet.Length -eq 2) {
            if($subnet.Substring(0,1) -eq "0") {
                $newSubnet = $subnet.Substring(1,1)
            }
            if($subnet -eq "00") {
                $newSubnet = "0"
            }
        }
        if($subnet.Length -eq 1) {
            if($subnet -eq "0") {
                $newSubnet = "0"
            }
        }
        $sbIP.Append($newSubnet + '.') | Out-Null
    }
    $newIP = ($sbIP.ToString())
    $newIp = $newIP.Substring(0,$newIP.Length-1)
    return $newIP
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$IPMacFinderForm = New-Object system.Windows.Forms.Form
$IPMacFinderForm.ClientSize = New-Object System.Drawing.Point(510,180)
$IPMacFinderForm.text = "IP/MAC Finder"
$IPMacFinderForm.TopMost = $false
$IPMacFinderForm.FormBorderStyle = "FixedDialog"

$dhcpCheck = New-Object system.Windows.Forms.CheckBox
$dhcpCheck.text = "DHCP Server"
$dhcpCheck.AutoSize = $false
$dhcpCheck.width = 103
$dhcpCheck.height = 25
$dhcpCheck.location = New-Object System.Drawing.Point(12,10)
$dhcpCheck.Font = New-Object System.Drawing.Font('Segoe UI',10)

$dhcpText = New-Object system.Windows.Forms.TextBox
$dhcpText.multiline = $false
$dhcpText.width = 100
$dhcpText.height = 25
$dhcpText.enabled = $false
$dhcpText.location = New-Object System.Drawing.Point(115,10)
$dhcpText.Font = New-Object System.Drawing.Font('Segoe UI',10)

$dhcpNote = New-Object system.Windows.Forms.Label
$dhcpNote.text = "Elevated Admin Rights Required for Exporting DHCP Scopes"
$dhcpNote.AutoSize = $true
$dhcpNote.width = 25
$dhcpNote.height = 10
$dhcpNote.location = New-Object System.Drawing.Point(10,42)
$dhcpNote.Font = New-Object System.Drawing.Font('Arial Narrow',10)

$dhcpExport = New-Object system.Windows.Forms.Button
$dhcpExport.text = "DHCP Export"
$dhcpExport.width = 95
$dhcpExport.height = 25
$dhcpExport.Enabled = $false 
$dhcpExport.location = New-Object System.Drawing.Point(220,10)
$dhcpExport.Font = New-Object System.Drawing.Font('Segoe UI',10)

$importCheck = New-Object system.Windows.Forms.CheckBox
$importCheck.text = "Import File"
$importCheck.AutoSize = $false
$importCheck.width = 90
$importCheck.height = 25
$importCheck.location = New-Object System.Drawing.Point(330,10)
$importCheck.Font = New-Object System.Drawing.Font('Segoe UI',10)

$notDHCPServer = New-Object System.Windows.Forms.CheckBox
$notDHCPServer.Visible = $false

$noteButton = New-Object system.Windows.Forms.Button
$noteButton.text = "Notepad"
$noteButton.width = 80
$noteButton.height = 25
$noteButton.Enabled = $false 
$noteButton.location = New-Object System.Drawing.Point(420,10)
$noteButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$dhcpButton = New-Object system.Windows.Forms.Button
$dhcpButton.text = "Copy Code"
$dhcpButton.width = 85
$dhcpButton.height = 25
$dhcpButton.Enabled = $false 
$dhcpButton.location = New-Object System.Drawing.Point(330,40)
$dhcpButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$openButton = New-Object system.Windows.Forms.Button
$openButton.text = "Open File"
$openButton.width = 80
$openButton.height = 25
$openButton.Enabled = $false 
$openButton.location = New-Object System.Drawing.Point(420,40)
$openButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$selectedLabel = New-Object system.Windows.Forms.Label
$selectedLabel.text = "Selected Source:"
$selectedLabel.AutoSize = $true
$selectedLabel.width = 25
$selectedLabel.height = 10
$selectedLabel.location = New-Object System.Drawing.Point(10,73)
$selectedLabel.Font = New-Object System.Drawing.Font('Segoe UI',10)

$sourceText = New-Object system.Windows.Forms.TextBox
$sourceText.AutoSize = $false
$sourceText.width = 370
$sourceText.height = 25
$sourceText.location = New-Object System.Drawing.Point(130,70)
$sourceText.Font = New-Object System.Drawing.Font('Segoe UI',10)
$sourceText.ReadOnly = $true

$sourceLabel = New-Object system.Windows.Forms.Label
$sourceLabel.text = "Source IP/MAC:"
$sourceLabel.AutoSize = $false
$sourceLabel.width = 100
$sourceLabel.height = 25
$sourceLabel.location = New-Object System.Drawing.Point(10,110)
$sourceLabel.Font = New-Object System.Drawing.Font('Segoe UI',10)

$inputText = New-Object system.Windows.Forms.TextBox
$inputText.multiline = $false
$inputText.width = 160
$inputText.height = 25
$inputText.enabled = $false
$inputText.location = New-Object System.Drawing.Point(115,108)
$inputText.Font = New-Object System.Drawing.Font('Segoe UI',10)

$findButton = New-Object system.Windows.Forms.Button
$findButton.text = "Find What You Need"
$findButton.width = 145
$findButton.height = 25
$findButton.enabled = $false
$findButton.location = New-Object System.Drawing.Point(290,108)
$findButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$clearButton = New-Object system.Windows.Forms.Button
$clearButton.text = "Clear"
$clearButton.width = 55
$clearButton.height = 25
$clearButton.location = New-Object System.Drawing.Point(445,108)
$clearButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$resultLabel = New-Object system.Windows.Forms.Label
$resultLabel.text = "Result:"
$resultLabel.AutoSize = $false
$resultLabel.width = 55
$resultLabel.height = 25
$resultLabel.location = New-Object System.Drawing.Point(10,148)
$resultLabel.Font = New-Object System.Drawing.Font('Segoe UI',10)

$outputText = New-Object system.Windows.Forms.TextBox
$outputText.multiline = $false
$outputText.width = 160
$outputText.height = 25
$outputText.enabled = $false
$outputText.ReadOnly = $true
$outputText.location = New-Object System.Drawing.Point(70,145)
$outputText.Font = New-Object System.Drawing.Font('Segoe UI',10)

$copyButton = New-Object system.Windows.Forms.Button
$copyButton.text = "Copy To Clipboard"
$copyButton.width = 125
$copyButton.height = 25
$copyButton.enabled = $false
$copyButton.location = New-Object System.Drawing.Point(245,145)
$copyButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$helpButton = New-Object system.Windows.Forms.Button
$helpButton.text = "Help"
$helpButton.width = 55
$helpButton.height = 25
$helpButton.location = New-Object System.Drawing.Point(380,145)
$helpButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$resetButton = New-Object system.Windows.Forms.Button
$resetButton.text = "Reset"
$resetButton.width = 55
$resetButton.height = 25
$resetButton.location = New-Object System.Drawing.Point(445,145)
$resetButton.Font = New-Object System.Drawing.Font('Segoe UI',10)

$importedText = New-Object system.Windows.Forms.TextBox
$importedText.multiline = $true
$importedText.Visible = $false

$IPMacFinderForm.controls.AddRange(@($dhcpCheck,$dhcpText,$dhcpNote,
    $dhcpExport,$importCheck,$noteButton,$dhcpButton,$openButton,
    $selectedLabel,$sourceText,$inputText,$resultLabel,$helpButton,
    $sourceLabel,$findButton,$outputText,$copyButton,$clearButton,
    $resetButton, $notDHCPServer, $importedText))

$dhcpCheck.Add_CheckStateChanged({ 
    If ($dhcpCheck.Checked) {
        dhcpCheckBoxOn
    } else {
        dhcpCheckBoxOff
        }
    })

$importCheck.Add_CheckStateChanged({ 
    If ($importCheck.Checked) {
        importCheckBoxOn
    } else {
        importCheckBoxOff
        }
    })

$dhcpExport.Add_Click({
    dhcpExportButton
    })


$noteButton.Add_Click({
    notepadButton
    })

$dhcpButton.Add_Click({
    dhcpCodeButton
    })

$openButton.Add_Click({
    openFileButton
    })

$findButton.Add_Click({
    findButton
    })


$copyButton.Add_Click({
    copyButton
    })

$clearButton.Add_Click({
    clearButton
    })

$resetButton.Add_Click({
    resetButton
    })

$helpButton.Add_Click({
    helpButton
    })

$IPMacFinderForm.ShowDialog()