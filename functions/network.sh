#!/usr/bin/env bash


function find-ip {
  MAC=$1

  sudo nmap -sP -n 192.168.1.0/24 | awk -v pattern="$MAC" '$0 ~ pattern  {print a[1]} {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}' x=2 | awk '{print $5;}'
}

alias find-ip-all="sudo nmap -sP -n 192.168.1.0/24 | awk 'NR>2 && (NR-3)%3 == 0 {print $5;}'"

# Nmap alias
alias nmap-lan='nmap -p T:22 192.168.1.*'
alias nmap-lan-all='nmap -p "*" 192.168.1.*'

alias arplan='sudo arp-scan -l'
