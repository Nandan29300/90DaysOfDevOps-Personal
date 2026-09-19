#!/bin/bash

echo "===== System Information ====="

echo "Hostname:"
hostname

echo ""
echo "Operating System:"
cat /etc/os-release | grep PRETTY_NAME

echo ""
echo "Kernel:"
uname -r

echo ""
echo "Current User:"
whoami

echo ""
echo "Disk Usage:"
df -h /

echo ""
echo "Memory:"
free -h

# Intentional Failure
# echo "Running intentional failure..."
# exit 1

echo ""
echo "===== System Information Check Completed ====="

