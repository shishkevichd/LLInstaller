$serverFolder = "S" + -join ((65..90) + (97..122) | Get-Random -Count 3 | % {[char]$_})

echo "
================="
echo "
LL-Ins"
echo "Source: https://github.com/sxsmc/LL-Ins
"
echo "=================
"
echo "[Info] Create server folder"
New-Item -Path "." -Name $serverFolder -ItemType "directory" | out-null
echo "[Info] Your server folder is '${serverFolder}'"

echo "
[Info] Getting Minecraft Bedrock Dedicated Server URL..."

$bedrockData = Invoke-WebRequest 'https://raw.githubusercontent.com/sxsmc/MCVersion/main/mcversion.json' | ConvertFrom-Json
$bedrockServerURL = $bedrockData.data.bedrock.fromSite.serverDownloadURL

echo "[Info] Getting LiteLoaderBDS Download URL..."
$liteloaderReleases = Invoke-WebRequest 'https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases' | ConvertFrom-Json
$liteloaderDownloadURL = $liteloaderReleases[0].assets[0].browser_download_url

echo "
[Info] Download Minecraft Bedrock Dedicated Server..."
Invoke-WebRequest -Uri $bedrockServerURL -OutFile "./${serverFolder}/Server.zip"

echo "[Info] Download LiteLoaderBDS..."
Invoke-WebRequest -Uri $liteloaderDownloadURL -OutFile "./${serverFolder}/LL.zip"

echo "
[Info] Unzipping your server!"
Expand-Archive -LiteralPath "./${serverFolder}/Server.zip" -DestinationPath "./${serverFolder}"
Expand-Archive -LiteralPath "./${serverFolder}/LL.zip" -DestinationPath "./${serverFolder}"

echo "
[Info] Deleting temporary files!"
Remove-Item -Path "./${serverFolder}/*.zip" -Force -Recurse

echo "
[Info] Running SymDB.exe."

# Running SymDB.exe and setting LiteLoader
cd ".\${serverFolder}"
Start-Process -FilePath ".\SymDB2.exe"

echo "
[Info] Done! To enable the server, open 'bedrock_server_mod.exe' (if you don't have it, open 'bedrock_server.exe')"
echo "
[Info] Goodbye!
"
