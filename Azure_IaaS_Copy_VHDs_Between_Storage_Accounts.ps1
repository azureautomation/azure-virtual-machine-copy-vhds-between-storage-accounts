#------------------------------------------------------------------------------ 
# 
# Copyright © 2014 Microsoft Corporation.  All rights reserved. 
# 
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT 
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT 
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS 
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. 
# 
#------------------------------------------------------------------------------ 
# 
# PowerShell Source Code 
# 
# NAME: 
#    Azure_IaaS_Copy_VHDs_Between_Storage_Accounts.ps1 
# 
# VERSION: 
#    1.0
# 
#------------------------------------------------------------------------------ 

#check for and create log directory
If (!(Test-Path "$Env:SystemDrive\Temp")) { New-Item -ItemType Directory -Path "$Env:SystemDrive\Temp" -Force }

#set up log file
$LogFile = "$Env:SystemDrive\Temp\Azure_IaaS_Copy_VHDs_Between_Storage_Accounts.log"

"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" Copyright © 2014 Microsoft Corporation.  All rights reserved. " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED `“AS IS`” WITHOUT " | Write-Host -ForegroundColor Yellow
" WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT " | Write-Host -ForegroundColor Yellow
" LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS " | Write-Host -ForegroundColor Yellow
" FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  " | Write-Host -ForegroundColor Yellow
" RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. " | Write-Host -ForegroundColor Yellow
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" PowerShell Source Code " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" NAME: " | Write-Host -ForegroundColor Yellow
"    Azure_IaaS_Copy_VHDs_Between_Storage_Accounts.ps1 " | Write-Host -ForegroundColor Yellow
"" | Write-Host -ForegroundColor Yellow
" VERSION: " | Write-Host -ForegroundColor Yellow
"    1.0" | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
"" | Write-Host -ForegroundColor Yellow
"`n This script SAMPLE is provided and intended only to act as a SAMPLE ONLY," | Write-Host -ForegroundColor Yellow
" and is NOT intended to serve as a solution to any known technical issue."  | Write-Host -ForegroundColor Yellow
"`n By executing this SAMPLE AS-IS, you agree to assume all risks and responsibility associated."  | Write-Host -ForegroundColor Yellow

$ContinueAnswer = Read-Host "`n Do you wish to proceed at your own risk? (Y/N)"
"`n Do you wish to proceed at your own risk? (Y/N)" | Out-File $LogFile -Append
"User answer: $ContinueAnswer" | Out-File $LogFile -Append
If ($ContinueAnswer -ne "Y") { Write-Host "`n Exiting." -ForegroundColor Red;Exit }

#set up listbox input UI
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#####
#OBJECT FOR SUBSCRIPTION SELECTION
#####
$objSubForm = New-Object System.Windows.Forms.Form 
$objSubForm.Text = "Azure Subscription"
$objSubForm.Size = New-Object System.Drawing.Size(300,200) 
$objSubForm.StartPosition = "CenterScreen"

$objSubForm.KeyPreview = $True
$objSubForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$SelSubName=$objSubListBox.SelectedItem;$objSubForm.Close()}})
$objSubForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objSubForm.Close()}})

$SubOKButton = New-Object System.Windows.Forms.Button
$SubOKButton.Location = New-Object System.Drawing.Size(75,120)
$SubOKButton.Size = New-Object System.Drawing.Size(75,23)
$SubOKButton.Text = "OK"
$SubOKButton.Add_Click({$SelSubName=$objSubListBox.SelectedItem;$objSubForm.Close()})
$objSubForm.Controls.Add($SubOKButton)

$SubCancelButton = New-Object System.Windows.Forms.Button
$SubCancelButton.Location = New-Object System.Drawing.Size(150,120)
$SubCancelButton.Size = New-Object System.Drawing.Size(75,23)
$SubCancelButton.Text = "Cancel"
$SubCancelButton.Add_Click({$objSubForm.Close()})
$objSubForm.Controls.Add($SubCancelButton)

$objSubLabel = New-Object System.Windows.Forms.Label
$objSubLabel.Location = New-Object System.Drawing.Size(10,20) 
$objSubLabel.Size = New-Object System.Drawing.Size(280,20) 
$objSubLabel.Text = "Select a subscription:"
$objSubForm.Controls.Add($objSubLabel) 

$objSubListBox = New-Object System.Windows.Forms.ListBox 
$objSubListBox.Location = New-Object System.Drawing.Size(10,40) 
$objSubListBox.Size = New-Object System.Drawing.Size(260,20) 
$objSubListBox.Height = 80

#####
# OBJECT FOR STORAGE SELECTION
#####
$objStorageForm = New-Object System.Windows.Forms.Form 
$objStorageForm.Text = "Azure Storage Account"
$objStorageForm.Size = New-Object System.Drawing.Size(300,200) 
$objStorageForm.StartPosition = "CenterScreen"

$objStorageForm.KeyPreview = $True
$objStorageForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$SelStorageName=$objStorageListBox.SelectedItem;$objStorageForm.Close()}})
$objStorageForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objStorageForm.Close()}})

$StorageOKButton = New-Object System.Windows.Forms.Button
$StorageOKButton.Location = New-Object System.Drawing.Size(75,120)
$StorageOKButton.Size = New-Object System.Drawing.Size(75,23)
$StorageOKButton.Text = "OK"
$StorageOKButton.Add_Click({$SelStorageName=$objStorageListBox.SelectedItem;$objStorageForm.Close()})
$objStorageForm.Controls.Add($StorageOKButton)

$StorageCancelButton = New-Object System.Windows.Forms.Button
$StorageCancelButton.Location = New-Object System.Drawing.Size(150,120)
$StorageCancelButton.Size = New-Object System.Drawing.Size(75,23)
$StorageCancelButton.Text = "Cancel"
$StorageCancelButton.Add_Click({$objStorageForm.Close()})
$objStorageForm.Controls.Add($StorageCancelButton)

$objStorageLabel = New-Object System.Windows.Forms.Label
$objStorageLabel.Location = New-Object System.Drawing.Size(10,20) 
$objStorageLabel.Size = New-Object System.Drawing.Size(280,20) 
$objStorageLabel.Text = "Select a SOURCE storage account:"
$objStorageForm.Controls.Add($objStorageLabel) 

$objStorageListBox = New-Object System.Windows.Forms.ListBox 
$objStorageListBox.Location = New-Object System.Drawing.Size(10,40) 
$objStorageListBox.Size = New-Object System.Drawing.Size(260,20) 
$objStorageListBox.Height = 80

#####
#OBJECT FOR VM SELECTION
#####
$objVMForm = New-Object System.Windows.Forms.Form 
$objVMForm.Text = "Azure VMs"
$objVMForm.Size = New-Object System.Drawing.Size(300,200) 
$objVMForm.StartPosition = "CenterScreen"

$objVMForm.KeyPreview = $True
$objVMForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$SelVMName=$objVMListBox.SelectedItem;$objVMForm.Close()}})
$objVMForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objVMForm.Close()}})

$VMOKButton = New-Object System.Windows.Forms.Button
$VMOKButton.Location = New-Object System.Drawing.Size(75,120)
$VMOKButton.Size = New-Object System.Drawing.Size(75,23)
$VMOKButton.Text = "OK"
$VMOKButton.Add_Click({$SelVMName=$objVMListBox.SelectedItem;$objVMForm.Close()})
$objVMForm.Controls.Add($VMOKButton)

$VMCancelButton = New-Object System.Windows.Forms.Button
$VMCancelButton.Location = New-Object System.Drawing.Size(150,120)
$VMCancelButton.Size = New-Object System.Drawing.Size(75,23)
$VMCancelButton.Text = "Cancel"
$VMCancelButton.Add_Click({$objVMForm.Close()})
$objVMForm.Controls.Add($VMCancelButton)

$objVMLabel = New-Object System.Windows.Forms.Label
$objVMLabel.Location = New-Object System.Drawing.Size(10,20) 
$objVMLabel.Size = New-Object System.Drawing.Size(280,20) 
$objVMLabel.Text = "Select VMs (click to multi-select):"
$objVMForm.Controls.Add($objVMLabel) 

$objVMListBox = New-Object System.Windows.Forms.ListBox 
$objVMListBox.Location = New-Object System.Drawing.Size(10,40) 
$objVMListBox.Size = New-Object System.Drawing.Size(260,20) 
$objVMListBox.Height = 80
$objVMListBox.SelectionMode = "MultiSimple"

#####
$Date = Get-Date
"BEGIN EXECUTION - $Date" | Out-File $LogFile -Append

#import the Azure PowerShell module
Write-Host "`n[WORKITEM] - Importing Azure PowerShell module"
"[WORKITEM] - Importing Azure PowerShell module" | Out-File $LogFile -Append

If ($ENV:Processor_Architecture -eq "x86")
{
	$ModulePath = "$Env:ProgramFiles\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

}
Else
{
	$ModulePath = "${env:ProgramFiles(x86)}\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"
}

Try
{
	If (-not(Get-Module -name "Azure")) 
	{ 
		If (Test-Path $ModulePath) 
		{ 
			Import-Module -Name $ModulePath
		}
		Else
		{
			#show module not found interaction and bail out
			Write-Host "[ERROR] - Azure PowerShell module not found. Exiting." -ForegroundColor Red
			"[ERROR] - Azure PowerShell module not found. Exiting." | Out-File $LogFile -Append
			Exit
		}
	}

	Write-Host "`tSuccess" -ForegroundColor Green 
	"`tSuccess" | Out-File $LogFile -Append
}
Catch [Exception]
{
	#show module not found interaction and bail out
	Write-Host "[ERROR] - PowerShell module not found. Exiting." -ForegroundColor Red
	"[ERROR] - PowerShell module not found. Exiting." | Out-File $LogFile -Append
	Exit
}

#Use Add-AzureAccount
Write-Host "[INFO] - Authenticating Azure account." 
"[INFO] - Authenticating Azure account." | Out-File $LogFile -Append
Add-AzureAccount

#####
#Azure subscription selection
#####
Write-Host "[INFO] - Obtaining subscriptions"
"[INFO] - Obtaining subscriptions" | Out-File $LogFile -Append
[array] $AllSubs = Get-AzureSubscription

If ($AllSubs)
{
	Write-Host "`tSuccess" -ForegroundColor Green
	"`tSuccess" | Out-File $LogFile -Append
	$AllSubs | FL | Out-File $LogFile -Append
}
Else
{
	Write-Host "`tNo subscriptions found. Exiting." -ForegroundColor Red
	"`tNo subscriptions found. Exiting." | Out-File $LogFile -Append
	Exit
}

Write-Host "[SELECTION] - Select the Azure subscription." 
"[SELECTION] - Select the Azure subscription." | Out-File $LogFile -Append

ForEach ($Sub in $AllSubs)
{
	$SubName = $Sub.SubscriptionName
	[void] $objSubListBox.Items.Add("$SubName")
}

$objSubForm.Controls.Add($objSubListBox) 
$objSubForm.Topmost = $True
$objSubForm.Add_Shown({$objSubForm.Activate()})
[void] $objSubForm.ShowDialog()
$SelSubName=$objSubListBox.SelectedItem

If ($SelSubName)
{
	$SelSub = Get-AzureSubscription -SubscriptionName $SelSubName
	$SelSub | Select-AzureSubscription
}
Else
{
	Write-Host "[ERROR] - No Azure subscription was selected. Exiting." -ForegroundColor Red
	"[ERROR] - No Azure subscription was selected. Exiting." | Out-File $LogFile -Append
	Exit
}

#get storage accounts
Write-Host "[INFO] - Obtaining storage accounts"
"[INFO] - Obtaining storage accounts" | Out-File $LogFile -Append
[array] $AllStorageAccounts = Get-AzureStorageAccount

If (($AllStorageAccounts) -and ($AllStorageAccounts.Count -gt 1))
{
	Write-Host "`tSuccess" -ForegroundColor Green
	"`tSuccess" | Out-File $LogFile -Append
	$AllStorageAccounts | FL | Out-File $LogFile -Append
}
Else
{
	Write-Host "`tAt least two Storage Accounts must exist in order to proceed. Exiting." -ForegroundColor Red
	"`tAt least two Storage Accounts must exist in order to proceed. Exiting." | Out-File $LogFile -Append
	Exit
}

#####
#Source Storage Account selection
#####
Write-Host "[SELECTION] - Select a Storage Account for the SOURCE of the VHD copy"
"[SELECTION] - Select a Storage Account for the SOURCE of the VHD copy" | Out-File $LogFile -Append

ForEach ($StorageAccount in $AllStorageAccounts)
{
	$StorageAccountName = $StorageAccount.StorageAccountName
	$StorageAccountLocation = $StorageAccount.GeoPrimaryLocation
	
	If ($StorageAccountLocation)
	{
		$DisplayName = "$StorageAccountName ($StorageAccountLocation)"
		[void] $objStorageListBox.Items.Add("$DisplayName")
	}
	Else
	{
		$DisplayName = "$StorageAccountName"
		[void] $objStorageListBox.Items.Add("$DisplayName")
	}
}

$objStorageForm.Controls.Add($objStorageListBox) 
$objStorageForm.Topmost = $True
$objStorageForm.Add_Shown({$objStorageForm.Activate()})
[void] $objStorageForm.ShowDialog()
$SelSourceStorageName=$objStorageListBox.SelectedItem

If ($SelSourceStorageName)
{
	If ($StorageAccountLocation)
	{
		$SelSourceStorageName = $SelSourceStorageName.Split(" ")[0]
	}
}
Else
{
	Write-Host "[ERROR] - No Azure storage account was selected. Exiting." -ForegroundColor Red
	"[ERROR] - No Azure storage account was selected. Exiting." | Out-File $LogFile -Append
	Exit
}

#####
#Target Storage Account selection
#####
Write-Host "[SELECTION] - Select a Storage Account for the TARGET of the VHD copy"
"[SELECTION] - Select a Storage Account for the TARGET of the VHD copy" | Out-File $LogFile -Append

$objStorageLabel.Text = "Select a TARGET storage account"
$objStorageListBox.Items.Clear()

ForEach ($StorageAccount in $AllStorageAccounts)
{
	$StorageAccountName = $StorageAccount.StorageAccountName
	$StorageAccountLocation = $StorageAccount.GeoPrimaryLocation
	
	If (($StorageAccountLocation) -and ($StorageAccountName -ne $SelSourceStorageName))
	{
		$DisplayName = "$StorageAccountName ($StorageAccountLocation)"
		[void] $objStorageListBox.Items.Add("$DisplayName")
	}
	ElseIf ($StorageAccountName -ne $SelSourceStorageName)
	{
		$DisplayName = "$StorageAccountName"
		[void] $objStorageListBox.Items.Add("$DisplayName")
	}
}

$objStorageForm.Controls.Add($objStorageListBox) 
$objStorageForm.Topmost = $True
$objStorageForm.Add_Shown({$objStorageForm.Activate()})
[void] $objStorageForm.ShowDialog()
$SelTargetStorageName=$objStorageListBox.SelectedItem

If ($SelTargetStorageName)
{
	If ($StorageAccountLocation)
	{
		$SelTargetStorageName = $SelTargetStorageName.Split(" ")[0]
	}
}
Else
{
	Write-Host "[ERROR] - No Azure storage account was selected. Exiting." -ForegroundColor Red
	"[ERROR] - No Azure storage account was selected. Exiting." | Out-File $LogFile -Append
	Exit
}

#####
#Set SOURCE context
#####
$SourceStorageKey = (Get-AzureStorageKey -StorageAccountName $SelSourceStorageName).Primary
$SourceStorageContext = New-AzureStorageContext -StorageAccountName $SelSourceStorageName -StorageAccountKey $SourceStorageKey

#####
#Set TARGET context
#####
$TargetStorageKey = (Get-AzureStorageKey -StorageAccountName $SelTargetStorageName).Primary
$TargetStorageContext = New-AzureStorageContext -StorageAccountName $SelTargetStorageName -StorageAccountKey $TargetStorageKey



#####
#VMs in SOURCE storage account
#####
Write-Host "[INFO] - Obtaining VMs in $SelSourceStorageName (this may take a few minutes)"
"[INFO] - Obtaining VMs in $SelSourceStorageName (this may take a few minutes)" | Out-File $LogFile -Append
$AllSourceVMs = Get-AzureVM | Where {$_.VM.OSVirtualHardDisk.MediaLink.Host.Split(".")[0] -eq $SelSourceStorageName}

If ($AllSourceVMs)
{
	Write-Host "`tSuccess" -ForegroundColor Green
	"`tSuccess" | Out-File $LogFile -Append
	$AllSourceVMs | FL | Out-File $LogFile -Append
}
Else
{
	Write-Host "`tNo VMs found in $SelSourceStorageName. Exiting." -ForegroundColor Red
	"`tNo VMs found in $SelSourceStorageName. Exiting." | Out-File $LogFile -Append
	Exit
}

Write-Host "[SELECTION] - Select VMs (click to multi-select)." 
"[SELECTION] - Select VMs (click to multi-select)." | Out-File $LogFile -Append

ForEach ($SourceVM in $AllSourceVMs)
{
	$SourceVMName = $SourceVM.Name
	[void] $objVMListBox.Items.Add("$SourceVMName")
}

$objVMForm.Controls.Add($objVMListBox) 
$objVMForm.Topmost = $True
$objVMForm.Add_Shown({$objVMForm.Activate()})
[void] $objVMForm.ShowDialog()
[array]$SelSourceVMNames=$objVMListBox.SelectedItems

If ($SelSourceVMNames.Count -ge 1)
{
	$VMCount = $SelSourceVMNames.Count
	"User selected $VMCount VMs: $SelSourceVMNames" | Out-File $LogFile -Append
	
	ForEach ($SelSourceVMName in $SelSourceVMNames)
	{
		$CopyDataDiskAnswer = "N"
		"Working on VM: $SelSourceVMName" | Out-File $LogFile -Append
		$AllSourceVMs | %{If ($_.Name -eq $SelSourceVMName){$SelSourceVM = $_}}
		
		If ($SelSourceVM.Status -notmatch "Stopped")
		{
			Write-Host "[WARNING] - $SelSourceVMName is currently running, and it must be shut down." -ForegroundColor Yellow
			"[WARNING] - $SelSourceVMName is currently running, and it must be shut down." | Out-File $LogFile -Append
			$ShutDownAnswer = Read-Host "[SELECTION] - Shut down ${SelSourceVMName}? (Y/N)"
			"[SELECTION] - Shut down ${SelSourceVMName}? (Y/N)" | Out-File $LogFile -Append
			"User input: $ShutDownAnswer" | Out-File $LogFile -Append
			If ($ShutDownAnswer -eq "Y")
			{
				Write-Host "[INFO] - Shutting down $SelSourceVMName"
				"[INFO] - Shutting down $SelSourceVMName" | Out-File $LogFile -Append
				$SourceVMServiceName = $SelSourceVM.ServiceName
				Stop-AzureVM -Name $SelSourceVMName -ServiceName $SourceVMServiceName -StayProvisioned -Force
				Start-Sleep -Seconds 10
			}
			Else
			{
				Write-Host "[ERROR] - Cannot proceed with a running VM. Exiting." -ForegroundColor Red
				"[ERROR] - Cannot proceed with a running VM. Exiting." | Out-File $LogFile -Append
				Exit
			}
		}
		Else
		{
			"$SelSourceVMName is already stopped" | Out-File $LogFile -Append
		}
		
		$SelSourceVM = Get-AzureVM | Where {$_.Name -eq $SelSourceVMName}
		
		If ($SelSourceVM.Status -notmatch "Stopped")
		{
			Write-Host "[ERROR] - Unable to shut down $SelSourceVMName. Exiting." -ForegroundColor Red
			"[ERROR] - Unable to shut down $SelSourceVMName. Exiting." | Out-File $LogFile -Append
			Exit
		}

	#####
	#Check for SOURCE data disks in same storage account
	#####
	If ($SelSourceVM.VM.DataVirtualHardDisks.Count -gt 0)
	{
		$CopyAssociatedDisks = $false
		$AllDataVHDs = $SelSourceVM.VM.DataVirtualHardDisks
		$AllDataVHDs | FL | Out-File $LogFile -Append
		
		ForEach ($DataVHD in $AllDataVHDs)
		{
			$DataDiskStorageAccount = $DataVHD.MediaLink.Host.Split(".")[0]
			
			If ($DataDiskStorageAccount -eq $SelSourceStorageName)
			{
				[array]$AssociatedDisks += $DataVHD
			}
		}
		
		If ($AssociatedDisks)
		{
			Write-Host "`n[WARNING] - There are data disks associated with $SelSourceVMName`nwhich are also in the $SelSourceStorageName storage account." -ForegroundColor Yellow
			"`n[WARNING] - There are data disks associated with $SelSourceVMName`nwhich are also in the $SelSourceStorageName storage account." | Out-File $LogFile -Append
			Write-Host "`nIf you answer 'Y' below, these disks will be copied along with the OS disk, but`nany data disks attached to $SelSourceVMName in another storage account will not be copied." -ForegroundColor Yellow
			"`nIf you answer 'Y' below, these disks will be copied along with the OS disk, but`nany data disks attached to $SelSourceVMName in another storage account will not be copied." | Out-File $LogFile -Append
			Write-Host "`nAssociated data disks found:" -ForegroundColor Yellow
			"`nAssociated data disks found:" | Out-File $LogFile -Append
			
			ForEach ($DiskToShow in $AssociatedDisks)
			{
				$DiskName = $DiskToShow.DiskName
				Write-Host "`t$DiskName" -ForegroundColor Yellow
				"`t$DiskName" | Out-File $LogFile -Append
			}
			
			$CopyDataDiskAnswer = Read-Host "`n[SELECTION] - Copy the associated data disks in $SelSourceStorageName as well? (Y/N)"
			"`n[SELECTION] - Copy the associated data disks in $SelSourceStorageName as well? (Y/N)" | Out-File $LogFile -Append
			"User input: $CopyDataDiskAnswer" | Out-File $LogFile -Append
		}
	}

		$SourceOSDiskBlob = $SelSourceVM.VM.OSVirtualHardDisk.MediaLink.AbsolutePath.Split("/")[2].ToString()
		$OSDiskContainer = $SelSourceVM.VM.OSVirtualHardDisk.MediaLink.Segments[1].Trim("/")
		$TargetDiskUri = $SelSourceVM.VM.OSVirtualHardDisk.MediaLink.Segments | Where {$_ -notmatch "/"}
		$TargetOSDiskBlob = "http://${SelTargetStorageName}.blob.core.windows.net/${OSDiskContainer}/${TargetDiskUri}"
		
	#####
	#Set TARGET OS disk container
	#####
	$AllContainers = Get-AzureStorageContainer -Context $TargetStorageContext
	$AllContainers | FL | Out-File $LogFile -Append
	$AllContainers | %{
		If ($_.Name -eq $OSDiskContainer)
		{
			"[INFO] - OS disk container '$OSDiskContainer' already exists. Using existing container." | Write-Host
			"[INFO] - OS disk container '$OSDiskContainer' already exists. Using existing container." | Out-File $LogFile -Append
			$ContainerExists = $True
		}
	}

	If (!($ContainerExists))
	{
		"[INFO] - OS disk container '$OSDiskContainer' does not exist. Attempting to create it." | Write-Host
		"[INFO] - OS disk container '$OSDiskContainer' does not exist. Attempting to create it." | Out-File $LogFile -Append
		New-AzureStorageContainer -Name $OSDiskContainer -Context $TargetStorageContext
	}
	 
	#####
	#OS Disk Copy
	#####
	Write-Host "`n[INFO] - Beginning asynchronous OS disk copy - $SelSourceVMName`n" -ForegroundColor Green -BackgroundColor Black
	"[INFO] - Beginning OS disk copy" | Out-File $LogFile -Append

	Try
	{
		Write-Host "[INFO] - Copying ${SourceOSDiskBlob}"
		"[INFO] - Copying ${SourceOSDiskBlob}" | Out-File $LogFile -Append
		$OSDiskCopy = Start-AzureStorageBlobCopy -srcblob $SourceOSDiskBlob -SrcContext $SourceStorageContext -SrcContainer $OSDiskContainer -DestContainer $OSDiskContainer -DestBlob $TargetDiskUri -DestContext $TargetStorageContext
		$objCopyJobParams = New-Object PSObject
		Add-Member -InputObject $objCopyJobParams -MemberType NoteProperty -Name "TargetDiskBlob" -Value $TargetOSDiskBlob
		Add-Member -InputObject $objCopyJobParams -MemberType NoteProperty -Name "DiskContainer" -Value $OSDiskContainer
		[array]$arrCopyJobs += $objCopyJobParams
		#$OSDiskCopyState = Get-AzureStorageBlobCopyState -Blob $TargetOSDiskBlob -Container $OSDiskContainer -Context $TargetStorageContext
	}
	Catch [Exception]
	{
		Write-Host "[ERROR] - $_"
		"[ERROR] - $_" | Out-File $LogFile -Append
	}

	#####
	#Data Disk Copy
	#####
	If ($CopyDataDiskAnswer -eq "Y")
	{
		Write-Host "`n[INFO] - Beginning asynchronous data disk copy - $SelSourceVMName`n" -ForegroundColor Green -BackgroundColor Black
		"[INFO] - Beginning data disk copy" | Out-File $LogFile -Append

		ForEach ($DataDisk in $AssociatedDisks)
		{
			$SourceDataDiskBlob = $DataDisk.MediaLink.AbsolutePath.Split("/")[2].ToString()
			$DataDiskContainer = $DataDisk.MediaLink.Segments[1].Trim("/")
			$TargetDiskUri = $DataDisk.MediaLink.Segments | Where {$_ -notmatch "/"}
			$TargetDataDiskBlob = "http://${SelTargetStorageName}.blob.core.windows.net/${DataDiskContainer}/${TargetDiskUri}"
		
			#####
			#Set TARGET container
			#####
			$DataContainerExists = $False
			$AllContainers | %{
				If ($_.Name -eq $DataDiskContainer)
				{
					"[INFO] - Data disk container '$DataDiskContainer' already exists. Using existing container." | Write-Host
					"[INFO] - Data disk container '$DataDiskContainer' already exists. Using existing container." | Out-File $LogFile -Append
					$DataContainerExists = $True
				}
			}

			If (!($DataContainerExists))
			{
				"[INFO] - Data disk container '$DataDiskContainer' does not exist. Attempting to create it." | Write-Host
				"[INFO] - Data disk container '$DataDiskContainer' does not exist. Attempting to create it." | Out-File $LogFile -Append
				New-AzureStorageContainer -Name $DataDiskContainer -Context $TargetStorageContext
			}
		
			Try
			{
				Write-Host "[INFO] - Copying ${SourceDataDiskBlob}"
				"[INFO] - Copying ${SourceDataDiskBlob}" | Out-File $LogFile -Append
				$DataDiskCopy = Start-AzureStorageBlobCopy -srcblob $SourceDataDiskBlob -SrcContext $SourceStorageContext -SrcContainer $DataDiskContainer -DestContainer $DataDiskContainer -DestBlob $TargetDiskUri -DestContext $TargetStorageContext
				$objCopyJobParams = New-Object PSObject
				Add-Member -InputObject $objCopyJobParams -MemberType NoteProperty -Name "TargetDiskBlob" -Value $TargetDataDiskBlob
				Add-Member -InputObject $objCopyJobParams -MemberType NoteProperty -Name "DiskContainer" -Value $DataDiskContainer
				[array]$arrCopyJobs += $objCopyJobParams
			}
			Catch [Exception]
			{
				Write-Host "[ERROR] - $_"
				"[ERROR] - $_" | Out-File $LogFile -Append
			}
		}
	}
}
}
Else
{
	Write-Host "[ERROR] - No Azure VM was selected. Exiting." -ForegroundColor Red
	"[ERROR] - No Azure VM was selected. Exiting." | Out-File $LogFile -Append
	Exit
}

#####
#Check copy status
#####
If ($arrCopyJobs)
{
	Write-Host "[INFO] - Checking OS and data disk copy status (updates every 10 seconds)"
	"[INFO] - Checking OS and data disk copy status (updates every 10 seconds)" | Out-File $LogFile -Append
	$CheckIterations = 0
	
	While($CheckIterations -lt 180)
	{
		ForEach ($CopyJob in $arrCopyJobs)
		{
			"####################" | Out-File $LogFile -Append
			$TargetDiskBlob = $CopyJob.TargetDiskBlob.Split("/")[4].ToString()
			$DiskContainer = $CopyJob.DiskContainer
			$State = Get-AzureStorageBlobCopyState -Blob $TargetDiskBlob -Container $DiskContainer -Context $TargetStorageContext
			$Status = $State.Status
			$Source = $State.Source
			$BytesCopied = $State.BytesCopied
			$TotalBytes = $State.TotalBytes
			$NameToShow = $Source.ToString().Split("/")[4].Split("?")[0]
			Write-Progress -Activity "Copy VHDs from $SelSourceStorageName to $SelTargetStorageName" -CurrentOperation "Copying $NameToShow" -Status "$Status" -PercentComplete (($BytesCopied/$TotalBytes)*100)
			$Source | Out-File $LogFile -Append
			$Status | Out-File $LogFile -Append
			$BytesCopied | Out-File $LogFile -Append
			$TotalBytes | Out-File $LogFile -Append
			$Percent = (($BytesCopied/$TotalBytes)*100)
			$Percent | Out-File $LogFile -Append
			Start-Sleep -Seconds 10
			"####################" | Out-File $LogFile -Append
		}
		
		$CheckIterations++
	}
}

$Date = Get-Date
Write-Host "`nEnd of execution.`n`n"
"`nEnd of execution - ${Date}`n`n" | Out-File $LogFile -Append