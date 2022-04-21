clear
Write-Host "
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-" -ForegroundColor Green
Write-Host "
Welcome to LL-Ins. It's universal Minecraft BDS installer.

Site: https://github.com/sxsmc/LL-Ins
"
Write-Host "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
" -ForegroundColor Green
Write-Host "[Question] " -NoNewline -ForegroundColor Green
$needLLPrompt = Read-Host -Prompt "Need to install LiteLoader? (1 is YES, 0 is NO)"
$needLL = $null;

if ($needLLPrompt -eq 1) {
    $needLL = $true;
} else {
    $needLL = $false;
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Creating server folder"
$serverFolder = "BDS-" + -join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_})
New-Item -Path "." -Name $serverFolder -ItemType "directory" | out-null
Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Your server folder is '${serverFolder}'"

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Getting Minecraft Bedrock Dedicated Server URL..."

$bedrockData = Invoke-WebRequest 'https://raw.githubusercontent.com/sxsmc/MCVersion/main/mcversion.json' | ConvertFrom-Json
$bedrockServerURL = $bedrockData.data.bedrock.fromSite.serverDownloadURL

if ($needLL) {
    Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
    echo "Getting LiteLoaderBDS Download URL..."
    $liteloaderReleases = Invoke-WebRequest 'https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases' | ConvertFrom-Json
    $liteloaderDownloadURL = $liteloaderReleases[0].assets[0].browser_download_url
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Download Minecraft Bedrock Dedicated Server..."
Invoke-WebRequest -Uri $bedrockServerURL -OutFile "./${serverFolder}/Server.zip"

if ($needLL) {
    Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
    echo "Download LiteLoaderBDS..."
    Invoke-WebRequest -Uri $liteloaderDownloadURL -OutFile "./${serverFolder}/LL.zip"
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Unzipping your server!"
Expand-Archive -LiteralPath "./${serverFolder}/Server.zip" -DestinationPath "./${serverFolder}"
if ($needLL) {
    Expand-Archive -LiteralPath "./${serverFolder}/LL.zip" -DestinationPath "./${serverFolder}"
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Deleting temporary files!"
Remove-Item -Path "./${serverFolder}/*.zip" -Force -Recurse

cd ".\${serverFolder}"

if ($needLL) {
    Write-Host "
    [Info] " -NoNewline -ForegroundColor Cyan
    echo "Running SymDB.exe."

    Start-Process -FilePath ".\SymDB2.exe"
}

Write-Host "[Question] " -NoNewline -ForegroundColor Green
$needStartServerPrompt = Read-Host -Prompt "Need to start server? (1 is YES, 0 is NO)"
$needStartServer = $null;

if ($needStartServerPrompt -eq 1) {
    $needStartServer = $true;
} else {
    $needStartServer = $false;
}

if ($needStartServer) {
    if ($needLL) {
        Start-Process -FilePath ".\bedrock_server_mod.exe"
    } else {
        Start-Process -FilePath ".\bedrock_server.exe"
    }
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Done!"
