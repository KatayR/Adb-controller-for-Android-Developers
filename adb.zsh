while true; do
  packageName=$(adb shell 'dumpsys activity activities' | grep "ResumedActivity" | awk -F 'u0 ' '{print $2}' | awk -F '/' '{print $1}')

  echo "\nFocused app is: $packageName"
  echo "  Type 'r' to refresh the focused app"
  echo "\nWhat do you wanna do with it?"
  echo "1- Kill app"
  echo "2- Restart app"
  echo "3- Kill & clear app data"
  echo "4- Kill & clear & restart app"
  echo "5- Clean & uninstall app"
  echo "Type 'q' to quit"

  read choice

  if [ "$packageName" = "com.sec.android.app.launcher" ]; then
    echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
  fi

  case $choice in
    r)
      continue
      ;;
    1)
      adb shell am force-stop $packageName
      echo "\nKilled $packageName"
      echo "=========================="
      ;;
    2)
      adb shell am force-stop $packageName
      adb shell am start -n $packageName/$packageName.MainActivity
      echo "\nRestarted $packageName"
      echo "=========================="
      ;;
    3)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb shell am force-stop $packageName
      adb shell pm clear --user 0 $packageName
      echo "\nKilled and cleared $packageName"
      echo "=========================="
      ;;
    4)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb shell am force-stop $packageName
      adb shell pm clear --user 0 $packageName
      adb shell am start -n $packageName/$packageName.MainActivity
      echo "\nClean restarted $packageName"
      echo "=========================="
      ;;
    5)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb shell am force-stop $packageName
      adb shell pm clear --user 0 $packageName
      adb shell pm uninstall -k --user 0 $packageName
      echo "\nUninstalled $packageName"
      echo "=========================="
      ;;
    q)
      exit 0
      ;;
    *)
      echo "Invalid choice, please try again"
      ;;
  esac
done
