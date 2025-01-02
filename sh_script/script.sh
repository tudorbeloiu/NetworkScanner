#!/bin/bash


show(){
   echo "============================"
   echo
   echo "=  Simple Network Scanner  ="
   echo
   echo "============================"
   echo
}

main_menu(){

    while true; do
      echo "1. Scan local network"
      echo "2. Retrive MAC addresses"
      echo "3. Scan open ports"
      echo "4. Save logs"
      echo "5. Exit"
      echo
      read -p "Choose an option: " choice
      echo

      case $choice in

      1) scan_network
         ;;
      2) get_mac_addresses
         ;;
      3) scan_ports
         ;;
      4) save_logs
         ;;
      5) echo "Exiting..."
         sleep 2
         echo "Goodbye!"
         exit 0
         ;;
      *) echo "Invalid option. Please try again."
         ;;
      esac
   done
}

scan_network(){

    echo "[INFO] Scanning the local network..."
    read -p "Enter the IP range (e.g, 192.168.1.0/24): " subnet
    echo
    sleep 1

    echo "[INFO] Detecting active devices on the network..."
    echo

    nmap -sn "$subnet" | grep "Nmap scan report for" | awk '{print $5}' > active_ips.txt

   if [[ -s active_ips.txt ]]; then
      echo "[INFO] Detected IPs: "
      cat active_ips.txt
   else
      echo "[INFO] No active devices detected."
   fi
   echo

}

get_mac_addresses(){
    echo "" > mac_addresses.txt
    echo "[INFO] Retrieving MAC addresses for active devices..."
    sleep 1
    while IFS= read -r ip; do
       mac=$(arp -n "$ip" | grep -oE "([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}")
       if [[ -n "$mac" ]]; then
          echo "IP: $ip - MAC: $mac" >> mac_addresses.txt
       else
          echo "IP: $ip - MAC: Unknown" >> mac_addresses.txt
       fi
    done < active_ips.txt

    if [[ -f mac_addresses.txt ]]; then
       echo "[INFO] Detected MAC addresses: "
       cat mac_addresses.txt
    fi
    echo

}

scan_ports(){

    read -p "Enter the IP to scan for open ports: " target_ip
    echo "[INFO] Scanning ports for $target_ip..."
    sleep 1
    echo
    nmap -p- "$target_ip" > port_scan_results.txt

    echo "[INFO] Port scan results: "
    cat port_scan_results.txt
    echo

}


save_logs(){

    log_file="network_scan_$(date +%Y%m%d_%H%M%S).log"
    echo "[INFO] Saving logs to $log_file..."
    sleep 1

    {
      echo "=== Network Scan Log ==="
      echo "Active devices: "
      cat active_ips.txt
      echo
      echo "MAC addresses: "
      cat mac_addresses.txt
      echo
      echo "Port scan results: "
      cat port_scan_results.txt
    } > "$log_file"

    echo "[INFO] Logs saved successfully."
    echo
}


show
main_menu

