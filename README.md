Azure Virtual Machine: Copy VHDs Between Storage Accounts
=========================================================


  *  **
 
This script sample is provided only as a sample and is not intended to serve as a solution to any technical issue**

  *  **By downloading and executing all or part of this script sample, you are executing this at your own risk with no support**


 


  *  The sample requires **Azure PowerShell** module to be installed on the system where the sample is executed

  *  http://go.microsoft.com/?linkid=9811175 

  *  The sample will attempt to authenticate you to your Azure account, which can be either a
**Microsoft Account (MSA) or Organizational Account (OrgID)** 
  *  Once authenticated, you will be presented a list of subscriptions found associated with the Azure account provided. You may select only one subscription for this sample

  *  There will be two prompts for storage account selection. The first prompt asks for the
**SOURCE** storage account (copy from), and the second prompt asks for the
**TARGET** storage account (copy to). The SOURCE and TARGET must not be the same

  *  All VMs found associated with the SOURCE storage account and listed, and **
you may select multiple VMs **in the SOURCE storage account for the VHD copy

  *  If selected VMs are currently not in the **Stopped** state, you will be prompted, and must answer '**Y**' to continue by allowing the sample to shut down the VM

  *  The sample also looks for data disks for each selected VM that happen to also reside in the SOURCE storage account.
**You will be prompted whether you would like data disks copied along with the OS disk**

  *  Once all selected VMs are Stopped and disk selection is complete, **asynchronous** file copy from SOURCE to TARGET begins

  *  Status messages for each copy job are shown in the PowerShell status bar. Status messages are refreshed every 10 seconds


 


  *  **Items this sample does NOT cover:**

  *  Virtual Machine objects are **NOT** removed or created; you will need to perform this step manually or scripted outside of this sample
Cloud Service objects are **NOT** removed or created; you will need to perform this step manually or scripted outside of this sample




 



    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
