#!/bin/bash

get_random_mac() {
    printf "00:%02x:%02x:%02x:%02x:%02x\n" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]
}

change_mac() {
    sudo ifconfig "$1" down
    sudo ifconfig "$1" hw ether "$2"
    sudo ifconfig "$1" up
}

get_current_mac() {
    ifconfig_output=$(ifconfig "$1")
    current_mac=$(echo "$ifconfig_output" | grep -oE "([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}")
    echo "$current_mac"
}

echo "[* Welcome to MAC ADDRESS Changer *]"
echo "[*] Press CTRL-C to QUIT"
TIME_TO_WAIT=30

read -p "Enter the name of the interface: " interface
current_mac=$(get_current_mac "$interface")

while true; do
    random_mac=$(get_random_mac)
    change_mac "$interface" "$random_mac"
    new_mac_summary=$(ifconfig "$interface")
    if [[ $new_mac_summary =~ $random_mac ]]; then
        echo -ne "\r[*] MAC Address Changed to $random_mac "
        sleep "$TIME_TO_WAIT"
    fi
done

trap 'change_mac "$interface" "$current_mac"; echo -e "\n[+] Quitting Program..."; exit' INT
