do {
    $packageName = adb shell 'dumpsys activity activities | grep ResumedActivity' | Select-Object -First 1 | Select-String -Pattern "u0 (.*)/" | ForEach-Object { $_.Matches.Groups[1].Value -replace ' .*', '' }
    Write-Host "`nFocused app is: $packageName"

    Write-Host "What do you wanna do with it?:`n"
    Write-Host "1- Kill app"
    Write-Host "2- Restart app"
    Write-Host "3- Kill & clear app data"
    Write-Host "4- Kill & clean & restart app"
    Write-Host "5- Clean & uninstall app"
    Write-Host "Press 'Q' to quit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            adb shell am force-stop $packageName
            Write-Host "`n Killed $packageName"
        }
        2 {
            adb shell am force-stop $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
            Write-Host "`n Restarted $packageName"
        }
        3 {
            adb shell am force-stop $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
            Write-Host "`n Killed and cleared $packageName"
        }
        4 {
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
            Write-Host "`n Clean restarted $packageName"
        }5 {
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            adb uninstall $packageName
            Write-Host "`n Uninstalled $packageName"
        }
        q {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again"
        }
    }
} while ($choice -ne "exit")
