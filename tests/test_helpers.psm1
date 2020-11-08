
function Test-CommandExists($command) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    $res = $false
    try {
        if(Get-Command $command) {
            $res = $true
        }
    } catch {
        $res = $false
    } finally {
        $ErrorActionPreference=$oldPreference
    }
    return $res
}

# check dependencies
if(-Not (Test-CommandExists docker)) {
    Write-Error "docker is not available"
}

function Run-Program($Cmd, $Params) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.WorkingDirectory = (Get-Location)
    $psi.FileName = $Cmd
    $psi.Arguments = $Params
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    if($proc.ExitCode -ne 0) {
        Write-Host "`n`nstdout:`n$stdout`n`nstderr:`n$stderr`n`n"
    }
    return $proc.ExitCode, $stdout, $stderr
}

function Build-Docker() {
    return (Run-Program 'docker.exe' "build $args .")
}

function Retry-Command {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [scriptblock] $ScriptBlock,
        [int] $RetryCount = 3,
        [int] $Delay = 30,
        [string] $SuccessMessage = "Command executed successfuly!",
        [string] $FailureMessage = "Failed to execute the command"
        )

    process {
        $Attempt = 1
        $Flag = $true

        do {
            try {
                $PreviousPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Stop'
                Invoke-Command -NoNewScope -ScriptBlock $ScriptBlock -OutVariable Result 4>&1
                $ErrorActionPreference = $PreviousPreference

                # flow control will execute the next line only if the command in the scriptblock executed without any errors
                # if an error is thrown, flow control will go to the 'catch' block
                Write-Verbose "$SuccessMessage `n"
                $Flag = $false
            }
            catch {
                if ($Attempt -gt $RetryCount) {
                    Write-Verbose "$FailureMessage! Total retry attempts: $RetryCount"
                    Write-Verbose "[Error Message] $($_.exception.message) `n"
                    $Flag = $false
                } else {
                    Write-Verbose "[$Attempt/$RetryCount] $FailureMessage. Retrying in $Delay seconds..."
                    Start-Sleep -Seconds $Delay
                    $Attempt = $Attempt + 1
                }
            }
        }
        While ($Flag)
    }
}

function Remove-Container($Container) {
    docker kill "$Container" 2>&1 | Out-Null
    docker rm -fv "$Container" 2>&1 | Out-Null
}
