do {
    $packageName = adb shell 'dumpsys activity activities | grep ResumedActivity' | Select-Object -First 1 | Select-String -Pattern "u0 (.*)/" | ForEach-Object { $_.Matches.Groups[1].Value -replace ' .*', '' }
    Write-Host "`nFocused app is: $packageName`n"
    Write-Host "  Type 'R' to refresh the focused app"

    Write-Host "`nWhat do you wanna do with it?:`n"
    Write-Host "1- Kill app"
    Write-Host "2- Restart app"
    Write-Host "3- Kill & clear app data"
    Write-Host "4- Kill & clear & restart app"
    Write-Host "5- Clean & uninstall app"
    Write-Host "Type 'Q' to quit"

    $choice = Read-Host "Enter your choice"

        if ($packageName -eq "com.sec.android.app.launcher") {
    Write-Host "`nLAUNCHER `nLAUNCHER `nLAUNCHER:"
    }

    switch ($choice) {
        r {
            continue
        }1 {
            adb shell am force-stop $packageName
            Write-Host "`n Killed $packageName"
            Write-Host "=========================="
        }
        2 {
            adb shell am force-stop $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
            Write-Host "`n Restarted $packageName"
            Write-Host "=========================="
        }
        3 {
            if ($packageName -eq "com.sec.android.app.launcher") {
    Write-Host "`nLAUNCHER `nLAUNCHER `nLAUNCHER:"
    continue
    }
    
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            Write-Host "`n Killed and cleared $packageName"
            Write-Host "=========================="
        }
        4 {
        if ($packageName -eq "com.sec.android.app.launcher") {
    Write-Host "`nLAUNCHER `nLAUNCHER `nLAUNCHER:"
    continue
    }
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            adb shell am start -n $packageName/$packageName.MainActivity
            Write-Host "`n Clean restarted $packageName"
            Write-Host "=========================="
        }5 {
        if ($packageName -eq "com.sec.android.app.launcher") {
    Write-Host "`nLAUNCHER `nLAUNCHER `nLAUNCHER:"
    continue
    }
            adb shell am force-stop $packageName
            adb shell pm clear --user 0 $packageName
            adb uninstall $packageName
            Write-Host "`n Uninstalled $packageName"
            Write-Host "=========================="
        }
        q {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again"
        }
    }
} while ($choice -ne "exit")
