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
$needLLPrompt = Read-Host -Prompt "Need to install LiteLoaderBDS? (1 is YES, 0 is NO)"
$needLL = $null;

if ($needLLPrompt -eq 1) {
    $needLL = $true;
} else {
    $needLL = $false;
}

Write-Host "[Question] " -NoNewline -ForegroundColor Green
$needLatestPrompt = Read-Host -Prompt "Need to install LATEST version LiteLoaderBDS and BDS? (1 is YES, 0 is NO)"
$needLatest = $null;

if ($needLatestPrompt -eq 1) {
    $needLatest = $true;
} else {
    $needLatest = $false;
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
$bedrockServerURL = $null
if (!$needLatest) {
    Write-Host "[Question] " -NoNewline -ForegroundColor Green
    $customBedrockVersion = Read-Host -Prompt "What version of Minecraft BDS do you need (example: 1.18.30.04)"

    if ($customBedrockVersion) {
        $bedrockServerURL = "https://minecraft.azureedge.net/bin-win/bedrock-server-${customBedrockVersion}.zip"
    } else {
        Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
        echo "Exit!"
        exit
    }
} else {
    $bedrockServerURL = $bedrockData.data.bedrock.fromSite.serverDownloadURL
}

if ($needLL) {
    Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
    echo "Getting LiteLoaderBDS Download URL..."
    $liteloaderReleases = Invoke-WebRequest 'https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases' | ConvertFrom-Json
    $liteloaderDownloadURL = $null
    if (!$needLatest) {
        Write-Host "[Question] " -NoNewline -ForegroundColor Green
        $customLLVersion = Read-Host -Prompt "What version of LiteLoaderBDS do you need (example: 2.1.8)"

        if ($customLLVersion) {
            $liteloaderDownloadURL = "https://github.com/LiteLDev/LiteLoaderBDS/releases/download/${customLLVersion}/LiteLoader-${customLLVersion}.zip"
        } else {
            Write-Host "[Error] " -NoNewline -ForegroundColor Red
            echo "Exit!"
            exit
        }
    } else {
        $liteloaderDownloadURL = $liteloaderReleases[0].assets[0].browser_download_url
    }
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Download Minecraft Bedrock Dedicated Server..."
try {
    Invoke-WebRequest -Uri $bedrockServerURL -OutFile "./${serverFolder}/Server.zip"
} catch {
    Write-Host "[Error] " -NoNewline -ForegroundColor Red
    echo "BDS version not found. Requested URL: ${bedrockServerURL}"
    exit
}

if ($needLL) {
    Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
    echo "Download LiteLoaderBDS..."
    try {
        Invoke-WebRequest -Uri $liteloaderDownloadURL -OutFile "./${serverFolder}/LL.zip"
    } catch {
        Write-Host "[Error] " -NoNewline -ForegroundColor Red
        echo "LiteLoaderBDS version not found. Requested URL: ${liteloaderDownloadURL}"
        exit
    }
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
    Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
    echo "Try to run LLPeEditor.exe."

    try {
        Start-Process -FilePath ".\LLPeEditor.exe"
    } catch {
        try {
            Write-Host "[Warning] " -NoNewline -ForegroundColor Yellow
            echo "LLPeEditor.exe not found. Try to run SymDB2.exe."
            Start-Process -FilePath ".\SymDB2.exe"
        } catch {
            Write-Host "[Error] " -NoNewline -ForegroundColor Red
            echo "Failed to install LiteLoaderBDS properly."
            exit
        }
    }
}

Write-Host "[Info] " -NoNewline -ForegroundColor Cyan
echo "Done!"
