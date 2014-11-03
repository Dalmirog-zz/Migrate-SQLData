<#
.Synopsis
   Migrates data from one table to another
.DESCRIPTION
   Migrates data from one table to another. IMPORTANT: It select * from the source table and inserts it into the destination table. Dalmiro.granas will update this script to allow custom select queries on the source table and will send it to Priyanka and Jim.
.EXAMPLE
   .\Migrate-SQLData.ps1 -SQLInstanceSource BG6VD1004 -DatabaseSource Monitoring -TableSource ALMAssessmentRating -SQLInstanceDestination VRTVW22960 -DatabaseDestination Monitoring -TableDestination ALMAssessmentRating
.EXAMPLE
   .\Migrate-SQLData.ps1 -file C:\Scripts\SQLData.xml
.EXAMPLE
   .\Migrate-SQLData.ps1 -file C:\Scripts\SQLData.xml -LogPath "D:\LogDir"
#>
[CmdletBinding()]
Param
(

        # Source SQL Instance name. eg 'BG6VD1004', 'BG6VD1309'
        [Parameter(Mandatory=$true, ParameterSetName = "File")]
        [String]$File,        
        
        # Source SQL Instance name. eg 'BG6VD1004', 'BG6VD1309'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$SQLInstanceSource,

        # Source Database Name. eg 'Monitoring','Bang6TPCProd'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$DatabaseSource,

        # Source Table Name. eg 'ALMAssessmentRating','People'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$TableSource,

        # Destination SQL Instance name. eg 'BG6VD1004', 'BG6VD1309'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$SQLInstanceDestination,

        # Destination Database Name. eg 'Monitoring','Bang6TPCProd'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$DatabaseDestination,

        # Destination Table Name. eg 'ALMAssessmentRating','People'
        [Parameter(Mandatory=$true, ParameterSetName= "Nofile")]
        [String]$TableDestination,

        # Log file Path. eg "C:\Logs". This path MUST NOT be a full path like "C:\Logs\MyLog.txt"
        [String]$LogPath = $PSScriptRoot,

        # File with custom T-SQL query to select data. All the data retrieved by this query will be inserted into the Destination.
        [String]$QueryFile

)

Begin
{
    $Date = Get-Date -Format g
    $LogDate = Get-Date -Format MM_yyyy

    If(!(Test-Path $LogPath)){
        
        Try{
        
            New-Item $LogPath -ItemType Directory -ErrorAction Stop
        }

        Catch{
            Write-Output "Unable to create $Logpath. Sending logs to $PSScriptRoot"
            $LogPath = $PSScriptRoot
        }
    }

    $LogPath = "$LogPath\Migrate-SQLData_$($env:Computername)_$Logdate.txt"

    write-output "******START - $date ******" | Out-File $LogPath -Append

    If($File){

        $file = Get-Item $File

        Write-Verbose "Getting connection data from $($File)"

        $FileContent = [xml](Get-Content $File)

        $SQLInstanceSource = $FileContent.Connections.Source.SQLInstance
        $DatabaseSource = $FileContent.Connections.Source.Database
        $TableSource = $FileContent.Connections.Source.Table
        $SQLInstanceDestination = $FileContent.Connections.Destination.SQLInstance
        $DatabaseDestination = $FileContent.Connections.Destination.Database
        $TableDestination = $FileContent.Connections.Destination.Table

        Write-output "$date - Getting connection data from $($File)" | Out-File $LogPath -Append
        
    }

    Write-Verbose "Sending log to $Logpath"
    Write-verbose "Source SQL Instance: $SQLInstanceSource"
    Write-Verbose "Source Database: $DatabaseSource"
    Write-Verbose "Source Table: $TableSource"        
    Write-verbose "Destination SQL Instance: $SQLInstanceDestination"
    Write-Verbose "Destination Database: $DatabaseDestination"
    Write-Verbose "Destination Table: $TableDestination"

    #Load scripts with functions
    . .\Add-SQLData.ps1
    . .\Get-SQLData.ps1

    $error.Clear() #clearing error variable to be able to capture all the output on the catch.

}

Process{

    try{
        
        If($QueryFile){
            $data = Get-SQLdata -SQLInstance $SQLInstanceSource -Database $DatabaseSource -Table $TableSource -LogPath $LogPath -QueryFile $QueryFile
        }
        Else{
            $data = Get-SQLdata -SQLInstance $SQLInstanceSource -Database $DatabaseSource -Table $TableSource -LogPath $LogPath
        }

        Add-SQLData -data $data -SQLInstance $SQLInstanceDestination -Database $DatabaseDestination -Table $TableDestination -LogPath $LogPath

    }
    Catch{
    
        foreach ($e in $error){
                                  
            Write-Output "ERROR $date - $($e)" | Out-File $LogPath -Append

        }
    
    }
    Finally{

        write-output "******END - $date ******" | Out-File $LogPath -Append

    }    


}
End
{    
    cd $PSScriptRoot
}
