#!/data/data/com.termux/files/usr/bin/bash

# Result directory
RESULT_DIR="/storage/emulated/0/x/result"
mkdir -p "$RESULT_DIR"

# Timestamp for log files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
NC_LOG="$RESULT_DIR/ncat_scan_$TIMESTAMP.txt"
NMAP_LOG="$RESULT_DIR/nmap_scan_$TIMESTAMP.txt"
FINAL_LOG="$RESULT_DIR/full_scan_$TIMESTAMP.txt"

echo "==================================="
echo "       Open Port Scanner Tool     "
echo "==================================="
echo ""

# Step 1: Get IP address
echo "Pls input the ip adress:"
read IP_ADDRESS

# Validate IP input (basic check)
if [ -z "$IP_ADDRESS" ]; then
    echo "Error: No IP address provided. Exiting."
    exit 1
fi

echo ""
echo "Starting scan for IP: $IP_ADDRESS"
echo "-----------------------------------"

# Step 2: NCAT scan to find open ports
echo "[1/3] Running ncat port scan (this may take a while)..."
echo "ncat scan for $IP_ADDRESS started at $(date)" > "$NC_LOG"
echo "----------------------------------------" >> "$NC_LOG"

# Run ncat scan and capture output
NCAT_OUTPUT=$(nc -zv -w1 "$IP_ADDRESS" 1-65535  2>&1 | tee /storage/emulated/0/x/result/ncat_full_output.txt  | grep "succeeded!")
echo "$NCAT_OUTPUT" >> "$NC_LOG"

# Extract open ports from ncat output
OPEN_PORTS=$(echo "$NCAT_OUTPUT" | cut -d' ' -f4 | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$OPEN_PORTS" ]; then
    echo "No open ports found on $IP_ADDRESS"
    echo "No open ports found at $(date)" >> "$FINAL_LOG"
    echo "Scan completed. No open ports detected."
    echo "Logs saved to: $RESULT_DIR"
    exit 0
fi

echo "Open ports found: $OPEN_PORTS"
echo "Open ports: $OPEN_PORTS" >> "$NC_LOG"
echo "ncat scan completed at $(date)" >> "$NC_LOG"
echo ""

# Step 3: Nmap scan on open ports
echo "[2/3] Running nmap version scan on open ports..."
echo "nmap scan for $IP_ADDRESS started at $(date)" > "$NMAP_LOG"
echo "Ports to scan: $OPEN_PORTS" >> "$NMAP_LOG"
echo "----------------------------------------" >> "$NMAP_LOG"

# Run nmap scan
nmap -sV --version-intensity 9 -p "$OPEN_PORTS" -T3 --open -n "$IP_ADDRESS" >> "$NMAP_LOG" 2>&1

echo "nmap scan completed at $(date)" >> "$NMAP_LOG"
echo "[2/3] Nmap scan completed"
echo ""

# Step 4: Combine logs and save
echo "[3/3] Saving all logs..."

{
    echo "=========================================="
    echo "COMPLETE SCAN REPORT for $IP_ADDRESS"
    echo "Scan Date: $(date)"
    echo "=========================================="
    echo ""
    echo "----- NCAT PORT SCAN RESULTS -----"
    cat "$NC_LOG"
    echo ""
    echo "----- NMAP VERSION SCAN RESULTS -----"
    cat "$NMAP_LOG"
    echo ""
    echo "=========================================="
} > "$FINAL_LOG"

echo "[3/3] All logs saved to: $RESULT_DIR"
echo ""
echo "=========================================="
echo "Scan completed successfully!"
echo "Files created:"
echo "  - ncat_scan_$TIMESTAMP.txt"
echo "  - nmap_scan_$TIMESTAMP.txt"
echo "  - full_scan_$TIMESTAMP.txt"
echo "=========================================="
