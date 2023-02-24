$done = @()

if(Test-Path tested.txt) {
    $done = Get-Content -Path tested.txt
}

Get-ChildItem -Path "*server*" |
    ForEach-Object {
        $env:TAG = $_.Name
        if(-not $done.Contains($env:TAG)) {
            Write-Host $env:TAG
            docker build -t maven:$($env:TAG) $env:TAG
            $result = Invoke-Pester -Path .\tests\ -PassThru
            if($result.FailedCount -ne 0) {
                Write-Error "Failed on $($env:TAG)"
                break
            } else {
                Add-Content -Path tested.txt -Value $env:TAG
            }
        }
    }