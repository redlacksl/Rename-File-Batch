function Rename-File-Batch {
<#
.SYNOPSIS
Rename and relocate all the files in a folder.
.DESCRIPTION
Change all the names in a folder to the same value with a sequential number.
This is useful for archiving things like CD rips or client papers in a standardized way.
.PARAMETER source
The folder containing the files you wish to rename and relocate.
.PARAMETER destination
The target folder for the files.
.PARAMETER prefix
The standardized name for each file.
This wil be automatically appended with a sequential number.
.PARAMETER eject
Switch this on to automatically eject a disk in the DVD drive.
.EXAMPLE
Rename-File-Batch -source "C:\Users\me\Music\A_Folder" -destination "C:\Users\me\Google Drive\Audio\Another_Folder" -prefix "John_Doe_Interview_"
#>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [string]$source,
        [parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [string]$destination,
        [parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [string]$prefix,
        [switch]$eject
    )
    BEGIN{
        # Create the destination folder
        Write-Verbose "Destination = $destination"
        New-Item -Path $destination -ItemType directory
    }
    PROCESS{
        $items = Get-ChildItem -Path $source
        [int]$i = 0
        foreach ($item in $items) {
            $i++
            $newName = $prefix + $i + $item.Extension
            Rename-Item("$source\$item") -NewName $newName
            Write-Verbose "$item renamed to $newName" 
        }

        # Re-collect the items since they changed, then send them to the destination
        $items = Get-ChildItem -Path $source
        foreach ($item in $items) {
            Move-Item("$source\$item") -Destination ($destination)
            Write-Verbose "$item moved to $destination"
        }
    }
    END{
       if ($eject) {
            # CD Eject script from
            # http://techibee.com/powershell/eject-or-close-cddvd-drive-using-powershellalternative-to-windows-media-objects/2176
            Write-Verbose "Ejecting disc..."
            $Diskmaster = New-Object -ComObject IMAPI2.MsftDiscMaster2            
            $DiskRecorder = New-Object -ComObject IMAPI2.MsftDiscRecorder2            
            $DiskRecorder.InitializeDiscRecorder($DiskMaster)            
            $DiskRecorder.EjectMedia()
        }
        Write-Verbose "All done"
    }
}
