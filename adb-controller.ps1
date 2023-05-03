do {
    $packageName = adb shell 'dumpsys activity activities | grep ResumedActivity' | Select-Object -First 1 | Select-String -Pattern "u0 (.*)/" | ForEach-Object {$_.Matches.Groups[1].Value -replace ' .*',''}
    Write-Host "`nFocuse app is: $packageName"

    Write-Host "What do you wanna do with it?`n:"
    Write-Host "1- Just kill the app"
    Write-Host "2- Restart the app"
    Write-Host "3- Kill & clear the data of app"
    Write-Host "4- Kill & clean & restart"
    Write-Host "Press 'Q' to quit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            adb shell am force-stop $packageName
        }
        2 {
            adb shell am force-stop $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
        }
        3 {
            adb shell am force-stop $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
        }
        4 {
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
        }
        q {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again"
        }
    }
} while ($choice -ne "exit")
