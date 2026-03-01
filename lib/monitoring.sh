set -x
monitor_system() {
    echo "-------------------------------"
    echo " System Monitoring"
    echo "-------------------------------"
    echo ""
    echo " System Uptime:"
    uptime

    #disk usage 
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "Disk Usage: ${disk_usage}%"
    if [ "$disk_usage" -gt 80 ]; then
    echo "warning!!!! disk usage is above 80%%"
    fi
    echo ""
    #memory usage 
    memory_used=$(top -l 1 |grep PhysMem| awk '{print $7}' | sed 's/M//')
    echo "memory used : ${memory_used}%"
    echo ""
    #cpu usage 
    cpu_idle=$(top -l 1 | grep "CPU usage" | awk '{print $7}' |sed 's/%//')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    echo "CPU_usage: ${cpu_usage}%"
    if [ "$cpu_usage" -gt 75 ]; then
    echo "Warning!!! cpu usage is above 75%%%"
    fi
    echo ""
}