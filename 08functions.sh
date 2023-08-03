#!/bin/bash

hai() {
    echo Ï am hai function
    echo I am hai
    echo hai function compldted
}
hai

stat() {
    echo "number of sessions opened are $(who| wc -l)"
    echo "Todays date is $(date +%F)"
    echo "average CPU utilisation in last fibe minutes $(uptime | awk -F : '{Print $NF}' | awk -F , '{Print $2}')"
}

stat