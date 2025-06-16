#!/bin/zsh

# Get list of connected devices
devices=($(adb devices | grep -v "List of devices" | grep -v "^$" | awk '{print $1}'))
deviceSerial=""

# Check if multiple devices are connected
if [ ${#devices[@]} -eq 0 ]; then
  echo "No devices connected. Please connect a device and try again."
  exit 1
elif [ ${#devices[@]} -eq 1 ]; then
  deviceSerial=${devices[1]}
  echo "Using device: $deviceSerial"
else
  echo "Multiple devices detected:"
  for i in {1..${#devices[@]}}; do
    deviceName=$(adb -s ${devices[$i]} shell getprop ro.product.model 2>/dev/null || echo "Unknown")
    echo "$i- ${devices[$i]} ($deviceName)"
  done
  echo "Select device (1-${#devices[@]}):"
  read deviceChoice
  if [[ $deviceChoice =~ ^[0-9]+$ ]] && [ $deviceChoice -ge 1 ] && [ $deviceChoice -le ${#devices[@]} ]; then
    deviceSerial=${devices[$deviceChoice]}
    echo "Selected device: $deviceSerial"
  else
    echo "Invalid selection"
    exit 1
  fi
fi

echo "=========================="

while true; do
  packageName=$(adb -s $deviceSerial shell 'dumpsys activity activities' | grep "ResumedActivity" | awk -F 'u0 ' '{print $2}' | awk -F '/' '{print $1}')
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
      adb -s $deviceSerial shell am force-stop $packageName
      echo "\nKilled $packageName"
      echo "=========================="
      ;;
    2)
      adb -s $deviceSerial shell am force-stop $packageName
      adb -s $deviceSerial shell am start -n $packageName/$packageName.MainActivity
      echo "\nRestarted $packageName"
      echo "=========================="
      ;;
    3)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb -s $deviceSerial shell am force-stop $packageName
      adb -s $deviceSerial shell pm clear --user 0 $packageName
      echo "\nKilled and cleared $packageName"
      echo "=========================="
      ;;
    4)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb -s $deviceSerial shell am force-stop $packageName
      adb -s $deviceSerial shell pm clear --user 0 $packageName
      adb -s $deviceSerial shell am start -n $packageName/$packageName.MainActivity
      echo "\nClean restarted $packageName"
      echo "=========================="
      ;;
    5)
      if [ "$packageName" = "com.sec.android.app.launcher" ]; then
        echo "\nLAUNCHER \nLAUNCHER \nLAUNCHER"
        continue
      fi
      adb -s $deviceSerial shell am force-stop $packageName
      adb -s $deviceSerial shell pm clear --user 0 $packageName
      adb -s $deviceSerial shell pm uninstall -k --user 0 $packageName
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
