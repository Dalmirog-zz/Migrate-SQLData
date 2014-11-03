<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Add-SQLData
{
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

        # This parameter expects a data object of the class System.Data.Datarow
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, position=0)]
        [System.Data.DataRow[]]$Data,

        # Full Log file Path. eg "C:\Logs\Log.txt"
        [String]$LogPath

    )

    Begin
    {
        #$null = add-pssnapin sqlserverprovidersnapin100
        #$null = add-pssnapin sqlservercmdletsnapin100
        $error.Clear() #clearing error variable for catch. The variable should be empty since the script runs in a new process, but just in case.


    }
    Process
    {

        $date = Get-Date -Format g

        Write-output "$date - Inserting data" | Out-File $LogPath -Append
        Write-output "$date - Destination SQL Instance - $SQLInstance" | Out-File $LogPath -Append
        Write-output "$date - Destination Database - $Database" | Out-File $LogPath -Append
        Write-output "$date - Destination Table - $Table" | Out-File $LogPath -Append
        write-Output "$date - Attempting to insert $($data.count) rows" | Out-File $LogPath -Append

        try{

            $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$($SQLInstance);Integrated Security=SSPI;Initial Catalog=$($Database)");
            $cn.Open()
            $bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
            $bc.DestinationTableName = $Table
            $bc.WriteToServer($Data)
        
            write-Output "$date - Inserted $($data.count) rows" | Out-File $LogPath -Append

        }#Try
        
        Catch{
            
            Foreach ($e in $error){
                            
                Write-Output "ERROR $date - $($e)" | Out-File $LogPath -Append
                break

            }
        }#Catch

        Finally{

           $cn.Close()

        }#Finally
        
        
        
    }#Process
    
    End{}
}#Function