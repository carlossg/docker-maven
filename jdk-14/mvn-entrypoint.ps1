
# Copy files from C:/ProgramData/Maven/Reference into ${MAVEN_CONFIG}
# So the initial ~/.m2 is set with expected content.
# Don't override, as this is just a reference setup

function Copy-ReferenceFiles() {
  $log = "${env:MAVEN_CONFIG}/copy_reference_file.log"
  $ref = "C:/ProgramData/Maven/Reference"

  $repo = Join-Path $env:MAVEN_CONFIG 'repository'

  New-Item -Path $repo -ItemType Directory -Force | Out-Null
  Write-Output $null > $log
  if((Test-Path $repo) -and (Test-Path $log)) {
    $count = (Get-ChildItem $repo | Measure-Object).Count
    if($count -eq 0) {
      # destination is empty...
      Add-Content -Path $log -Value "--- Copying all files to ${env:MAVEN_CONFIG} at $(Get-Date)"
      Copy-Item -Path "$ref\*" -Destination $env:MAVEN_CONFIG -Force -Recurse | Add-Content -Path $log
    } else {
      # destination is non-empty, copy file-by-file
      Add-Content -Path $log -Value "--- Copying individual files to ${MAVEN_CONFIG} at $(Get-Date)"
      Get-ChildItem -Path $ref -File | ForEach-Object {
        Push-Location $ref
        $rel = Resolve-Path -Path $($_.FullName) -Relative
        Pop-Location
        if(!(Test-Path (Join-Path $env:MAVEN_CONFIG $rel)) -or (Test-Path $('{0}.override' -f $_.FullName))) {
          $dir = Join-Path $env:MAVEN_CONFIG $($rel.DirectoryName)
          if(!(Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory | Out-Null
          }
          Copy-Item -Path $_.FullName -Destination (Join-Path $env:MAVEN_CONFIG $rel) | Add-Content -Path $log
        }
      }
    }
    Add-Content -Path $log -Value ""
  } else {
    Write-Warning "Can not write to ${log}. Wrong volume permissions? Carrying on ..."
  }
}

Push-Location -StackName 'maven-entrypoint'
Copy-ReferenceFiles
Pop-Location -StackName 'maven-entrypoint'

Remove-Item Env:\MAVEN_CONFIG

Invoke-Expression "$args"
