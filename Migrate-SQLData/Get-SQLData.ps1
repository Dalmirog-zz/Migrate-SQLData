<#
.Synopsis
   Gets data from a SQL database and returns it as a System.Data.Datarow object
.DESCRIPTION
   Gets data from a SQL database and returns it as a System.Data.Datarow object. This script was meant to be used along with Add-SQLData.ps1 and Migrate-SQLData.ps1. If QueryFile script is provided, this script will do a "Select * from" on the table provided.
.EXAMPLE
   Get-sqlData -SQLInstance MySQLInstance -Database HumanResources -Table Users -QueryFile .\CustomQuery.sql
.EXAMPLE
   Get-sqlData -SQLInstance MySQLInstance -Database HumanResources -Table Users
#>
Function Get-SQLData
{
    [CmdletBinding()]
    Param
    (
        # SQL Instance name. eg 'BG6VD1004', 'BG6VD1309'
        [Parameter(Mandatory=$true)]
        [String]$SQLInstance,

        # Database Name. eg 'Monitoring','Bang6TPCProd'
        [Parameter(Mandatory=$true)]
        [String]$Database,

        # Table Name. eg 'ALMAssessmentRating','People'
        [Parameter(Mandatory=$true)]
        [String]$Table,

        # Full Log file Path. eg "C:\Logs\Log.txt"
        [String]$LogPath,

        # File with custom T-SQL query to select data. All the data retrieved by this query will be inserted into the Destination.
        [String]$QueryFile

    )
    Begin
    {
        #$null = add-pssnapin sqlserverprovidersnapin100
        #$null = add-pssnapin sqlservercmdletsnapin100
        $error.Clear() #clearing error variable to be able to capture all the output on the catch.


    }
    Process
    {
        
        $date = Get-Date -Format g

        Write-output "$date - Getting data" | Out-File $LogPath -Append
        Write-output "$date - Source SQL Instance - $SQLInstance" | Out-File $LogPath -Append
        Write-output "$date - Source Database - $Database" | Out-File $LogPath -Append
        Write-output "$date - Source Table - $Table" | Out-File $LogPath -Append
        
        Try{
        
            if(($queryfile) -and (test-path $QueryFile)){
                
                $Queryfile = Get-Item $QueryFile
                Write-Output "$date - Running custom query from: $($QueryFile.fullname)" | Out-File $LogPath -Append
                $data = Invoke-Sqlcmd -inputfile $QueryFile -ServerInstance $SQLInstance -Database $Database        
            }
            else{
                Write-Output "$date - No Query File defined or Query File was not found. Value passed to parameter QueryFile: $QueryFile" | Out-File $LogPath -Append
                $data = Invoke-Sqlcmd -query "select * from $Table" -ServerInstance $SQLInstance -Database $Database        
            }
        }

        Catch{
            
            foreach ($e in $error){    
                                    
                Write-Output "ERROR $date - $($e)" | Out-File $LogPath -Append

            }
        }
                
        Finally{

            Write-Output "$date - Found $($data.count) lines" | Out-File $LogPath -Append

        }

    }

    
    End
    {
        return $data
    }

}

#Get-sqlData -SQLInstance BSAS-DB-01 -Database Monitoring -Table Source_Users -LogPath "C:\Scripts\Migrate-SQLData_BSAS-DB-01_11_2014.txt"