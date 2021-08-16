Install-Module -Name Pester -Force -RequiredVersion 5.0.4
Write-Host "Starting"
$dir = $args[0]
$username = $args[1]
$password = $args[2]
$tags = @('3.8.2', '3.8', '3')

# only push from master
$ref=$env:GITHUB_REF
$branch=$ref.substring($ref.LastIndexOf("/") +1)
echo "Running on branch ${branch} (${ref})"
if($branch -ne 'master') {
    $env:DOCKER_PUSH=""
}

Push-Location

Write-Host "Image: $dir"

# TODO manually copied from Dockerfiles
if(($dir.Contains('amazoncorretto')) -or ($dir.Contains('azulzulu'))) {
    $windowsDockerTag = 'ltsc2019'
}
if(($dir.Contains('adoptopenjdk')) -or ($dir.Contains('eclipse-temurin')) -or ($dir.Contains('openjdk'))) {
    $windowsDockerTag = '1809'
}

# run tests
Write-Host "Running tests: $dir"
Push-Location
$env:TAG=$dir
Invoke-Pester -Path tests -CI
Remove-Item env:\TAG
Pop-Location

$tags | ForEach-Object {
    Push-Location $dir
    $tag = ('csanchez/maven:{0}-{1}-{2}' -f $_,$dir,$windowsDockerTag)
    Write-Host "Building: $tag"
    docker build --tag $tag .

    if($env:DOCKER_PUSH -eq 'true') {
        # docker login with cause a warning which will cause this to fail unless we SilentlyContinue
        $ErrorActionPreference = 'SilentlyContinue'
        $password | & docker login --username $username --password-stdin
        $ErrorActionPreference = 'Stop'
        Write-Host "Pushing $tag"
        & docker push $tag
    }
    Pop-Location
}
Pop-Location
