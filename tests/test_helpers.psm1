
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

# Run a program, retrying it when it fails due to rate limiting by Docker Hub or Maven Central
# (HTTP 429 Too Many Requests, or 403 Forbidden from Maven Central).
# Retries $env:RETRY_RATE_LIMIT_ATTEMPTS times (default 5), waiting $env:RETRY_RATE_LIMIT_DELAY seconds (default 60) between attempts.
$RateLimitPattern = '429 Too Many Requests|toomanyrequests|Status: 429|status code: 429|HTTP Status: 403|status code: 403'
function Run-Program($Cmd, $Params) {
    $attempts = if($env:RETRY_RATE_LIMIT_ATTEMPTS) { [int]$env:RETRY_RATE_LIMIT_ATTEMPTS } else { 5 }
    $delay = if($env:RETRY_RATE_LIMIT_DELAY) { [int]$env:RETRY_RATE_LIMIT_DELAY } else { 60 }
    for($attempt = 1; ; $attempt++) {
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
        if(($proc.ExitCode -eq 0) -or ($attempt -ge $attempts) -or ("$stdout$stderr" -notmatch $RateLimitPattern)) {
            return $proc.ExitCode, $stdout, $stderr
        }
        Write-Host "Rate limited, retrying in ${delay}s (attempt $attempt/$attempts)"
        Start-Sleep -Seconds $delay
    }
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
