#!/bin/zsh

# Get list of connected devices
devices=($(adb devices | grep -w "device$" | awk '{print $1}'))

selected_device=""

# Check if multiple devices are connected
if [[ ${#devices[@]} -eq 0 ]]; then
    echo "No devices connected. Please connect a device and try again."
    exit 1
elif [[ ${#devices[@]} -eq 1 ]]; then
    selected_device=${devices[1]}
    echo "Using device: $selected_device"
else
    echo "Multiple devices detected:"
    for i in {1..${#devices[@]}}; do
        device_model=$(adb -s ${devices[$i]} shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        if [[ -z "$device_model" ]]; then
            device_model="Unknown"
        fi
        echo "$i- ${devices[$i]} ($device_model)"
    done

    read "device_choice?Select device (1-${#devices[@]}): "
    if [[ "$device_choice" =~ ^[0-9]+$ ]] && (( device_choice >= 1 && device_choice <= ${#devices[@]} )); then
        selected_device=${devices[$device_choice]}
        echo "Selected device: $selected_device"
    else
        echo "Invalid selection"
        exit 1
    fi
fi

echo "=========================="

while true; do
    package_name=$(adb -s "$selected_device" shell 'dumpsys activity activities | grep ResumedActivity' | head -n 1 | sed -n 's/.*u0 \([^/]*\).*/\1/p' | awk '{print $1}')

    echo "\nFocused app is: \033[1;36m$package_name\033[0m\n"
    echo "  Type 'r' to refresh the focused app"
    echo "\nWhat do you wanna do with it?:\n"
    echo "1- Kill app"
    echo "2- Restart app"
    echo "3- Kill & clear app data"
    echo "4- Kill & clear & restart app"
    echo "5- Clean & uninstall app"
    echo "Type 'q' to quit"

    read "choice?Enter your choice: "

    is_launcher=0
    if [[ "$package_name" =~ "launcher|home|trebuchet|lawnchair|nova|apex|action|adw|microsoft|teslacoillauncher|nemustech|oneplus|miui|pixel" ]]; then
        is_launcher=1
    fi

    if [[ $is_launcher -eq 1 && "$choice" =~ ^[1-5]$ ]]; then
        case $choice in
            1|2)
                echo "\n\033[1;33m⚠️  WARNING: $package_name appears to be a LAUNCHER app!\033[0m"
                read "confirm?Are you sure you want to proceed? (y/n): "
                if [[ "$confirm" != "y" ]]; then
                    echo "Action cancelled."
                    continue
                fi
                ;;
            3|4)
                echo "\n\033[1;31m⚠️  CRITICAL WARNING: $package_name appears to be a LAUNCHER app!\033[0m"
                echo "\033[1;31mClearing launcher data will reset your home screen layout and widgets!\033[0m"
                read "confirm?Are you REALLY sure you want to proceed? (yes/n): "
                if [[ "$confirm" != "yes" ]]; then
                    echo "Action cancelled."
                    continue
                fi
                ;;
            5)
                echo "\n\033[1;31m⛔ EXTREME WARNING: $package_name appears to be a LAUNCHER app!\033[0m"
                echo "\033[1;31mUninstalling the launcher could make your device unusable!\033[0m"
                echo "\033[1;31mYou may not be able to access apps or settings!\033[0m"
                read "confirm?Type 'I UNDERSTAND THE RISKS' to continue: "
                if [[ "$confirm" != "I UNDERSTAND THE RISKS" ]]; then
                    echo "Action cancelled. Good choice!"
                    continue
                fi
                ;;
        esac
    fi

    case $choice in
        r|R)
            continue
            ;;
        1)
            adb -s "$selected_device" shell am force-stop "$package_name"
            echo "\nKilled $package_name"
            echo "=========================="
            ;;
        2)
            main_activity=$(adb -s "$selected_device" shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER "$package_name" | tail -n 1)
            adb -s "$selected_device" shell am force-stop "$package_name"
            adb -s "$selected_device" shell am start -n "$main_activity"
            echo "\nRestarted $package_name"
            echo "=========================="
            ;;
        3)
            adb -s "$selected_device" shell am force-stop "$package_name"
            adb -s "$selected_device" shell pm clear --user 0 "$package_name"
            echo "\nKilled and cleared $package_name"
            echo "=========================="
            ;;
        4)
            main_activity=$(adb -s "$selected_device" shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER "$package_name" | tail -n 1)
            adb -s "$selected_device" shell am force-stop "$package_name"
            adb -s "$selected_device" shell pm clear --user 0 "$package_name"
            adb -s "$selected_device" shell am start -n "$main_activity"
            echo "\nClean restarted $package_name"
            echo "=========================="
            ;;
        5)
            adb -s "$selected_device" shell am force-stop "$package_name"
            adb -s "$selected_device" shell pm clear --user 0 "$package_name"
            adb -s "$selected_device" uninstall "$package_name"
            echo "\nUninstalled $package_name"
            echo "=========================="
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again"
            ;;
    esac
done
