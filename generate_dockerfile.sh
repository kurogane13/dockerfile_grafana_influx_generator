#!/bin/bash

# Fancy banner
clear
date
echo
echo -e "\e[1;34m=======================================================\e[0m"
echo -e "\e[1;32m      🔧 InfluxDB & Grafana Dockerfile Generator      \e[0m"
echo -e "\e[1;34m=======================================================\e[0m"
echo
echo -e "\e[1;33m SCRIPT SCOPE: \e[0m"
echo
echo -e " - Create a Dockerfile, which will install and setup influxdb, and Grafana"
echo -e " - Prompt for InfluxDB configuration variables."
echo -e " - Generate a new Dockerfile with your inputs."
echo -e " - Save it to a specified path."
echo
echo -e "============================================"

# Wait for user to press Enter to continue
echo -e "\e[1;36mPress Enter to start...\e[0m"
read

# Prompt for variables
echo -e "\e[1;34mEnter InfluxDB Configuration:\e[0m"
echo
echo -n "🔹 Influx UI Admin Username: "; read influx_ui_user
echo -n "🔹 Influx UI Admin Password: "; read -s influx_ui_password; echo
echo -n "🔹 Organization Name: "; read influx_organization
echo -n "🔹 Bucket Name: "; read influx_bucket
echo -n "🔹 Authentication Token: "; read influx_token
echo
# Fixed retention period
influx_bucket_retention=0

# Ask for save location
ls -lhaR
echo
echo $PWD
echo -e "\e[1;34mWhere should the new Dockerfile be saved?\e[0m"
echo -n "(Press Enter to use current directory or specify a path): "; save_path
echo
#!/bin/bash

while true; do
    clear
    echo -e "\e[1;34m========================================\e[0m"
    echo -e "\e[1;32m      📂 Choose a Directory Option      \e[0m"
    echo
    echo -e "1 - Use current directory (\e[1;33m$PWD\e[0m)"
    echo -e "2 - Create a new folder"
    echo -e "3 - Exit"
    echo
    echo -e "\e[1;34m========================================\e[0m"
    echo
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            echo -e "\e[1;32m✅ Using current directory: $PWD\e[0m"
            break  # Exit the loop
            ;;
        2)
            read -p "Enter new folder name: " save_path
            if [ -z "$save_path" ]; then
                echo -e "\e[1;31m❌ Folder name cannot be empty!\e[0m"
                sleep 1
                continue
            fi

            mkdir -p "$save_path"
            echo -e "\e[1;32m✅ Folder created: $save_path\e[0m"
            break  # Exit the loop
            ;;
        3)
            echo -e "\e[1;31m🚪 Exiting...\e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[1;31m❌ Invalid option! Please choose again.\e[0m"
            sleep 1
            ;;
    esac
done

dockerfile_var="Dockerfile"
save_path="$save_path"
dockerfilepath="$save_path/$dockerfile_var"

# Generate Dockerfile using EOF
cat <<EOF > "$dockerfilepath"
# Use Ubuntu 20.04 as base
FROM ubuntu:20.04

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget curl gnupg2 software-properties-common sudo net-tools jq

# Install InfluxDB
RUN mkdir -p /usr/share/keyrings && \
    wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key | gpg --dearmor -o /usr/share/keyrings/influxdb-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/influxdb-keyring.gpg] https://repos.influxdata.com/ubuntu focal stable" | tee /etc/apt/sources.list.d/influxdb.list && \
    apt-get update && apt-get install -y influxdb2 influxdb2-cli

# Modify InfluxDB configuration to enable authentication
RUN sed -i 's/# auth-enabled = false/auth-enabled = true/' /etc/influxdb/config.toml && \
    sed -i 's/# bind-address = ":8086"/bind-address = ":8086"/' /etc/influxdb/config.toml

# Setup InfluxDB
RUN influxd & sleep 5 && \
    influx setup --host http://localhost:8086 -u $influx_ui_user -p $influx_ui_password --org $influx_organization --bucket $influx_bucket --retention $influx_bucket_retention --force --token $influx_token && \
    influx auth create --org $influx_organization --user $influx_ui_user --description "Admin RW access" --read-buckets --write-buckets --token $influx_token && \
    echo "==== InfluxDB Setup Verification ====" > /root/influxdb_credentials.txt && \
    influx org list --host http://localhost:8086 --token $influx_token >> /root/influxdb_credentials.txt && \
    influx bucket list --host http://localhost:8086 --token $influx_token >> /root/influxdb_credentials.txt && \
    influx auth list --host http://localhost:8086 --token $influx_token >> /root/influxdb_credentials.txt

# Install Grafana
RUN wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key && \
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list && \
    apt-get update && apt-get install -y grafana

# Expose ports for InfluxDB and Grafana
EXPOSE 8086 3000

# Start InfluxDB and Grafana when the container runs
CMD /bin/bash -c "influxd & sleep 5 && exec grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini"
EOF

# Display results
echo
echo -e "\e[1;32mDockerfile successfully created at: \e[0m$dockerfilepath"
echo
echo -e "\e[1;33mGenerated Dockerfile Preview:\e[0m"
echo
cat "$dockerfilepath"
echo
echo -e "\e[1;34m============================================\e[0m"
echo -e "\e[1;32m           ✅ Process Complete!           \e[0m"
echo -e "\e[1;34m============================================\e[0m"
echo
echo "Timestamp: $(date)" > $save_path/credentials_report.txt
echo "--------------------------------------------" >> $save_path/credentials_report.txt
echo "Influx UI Admin Username: $influx_ui_user" >> $save_path/credentials_report.txt
echo "Influx UI Admin Password: $influx_ui_password" >> $save_path/credentials_report.txt
echo "Organization Name: $influx_organization" >> $save_path/credentials_report.txt
echo "Bucket Name: $influx_bucket" >> $save_path/credentials_report.txt
echo "Authentication Token: $influx_token" >> $save_path/credentials_report.txt
echo "--------------------------------------------" >> $save_path/credentials_report.txt
echo "Credentials saved to: $save_path/credentials_report.txt"
echo

report_file="$save_path/report.html"

# Get current date and time
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Generate HTML Report
cat <<EOF > "$report_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dockerfile INFLUX Credentials Report</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #0a0a0a;
            color: #ffffff;
            margin: 20px;
            text-align: center;
        }

        .timestamp {
            position: absolute;
            top: 10px;
            left: 20px;
            font-size: 14px;
            color: #0ff;
            font-weight: bold;
        }

        h1 {
            color: #0ff;
            text-shadow: 0 0 15px #00ffff;
        }

        .section {
            color: #ff8c00;
            text-shadow: 0 0 15px #ff8c00;
            font-size: 22px;
            margin-top: 20px;
        }

        .codeblock {
            background-color: rgba(0, 0, 0, 0.8);
            color: #ffffff;
            font-family: 'Courier New', monospace;
            font-weight: bold;
            padding: 15px;
            border-radius: 10px;
            border: 2px solid #ffffff;
            box-shadow: 0px 0px 10px rgba(255, 255, 255, 0.7);
            text-align: left;
            overflow-x: auto;
            white-space: pre-wrap;
            display: inline-block;
            max-width: 80%;
            text-align: left;
        }

        .parsed-data {
            font-weight: bold;
            color: #00ff00;
            text-shadow: 0 0 10px #00ff00;
        }

        p {
            font-size: 18px;
        }

        .footer {
            margin-top: 20px;
            color: #888;
            font-size: 12px;
        }
    </style>
</head>
<body>

    <div class="timestamp">$timestamp</div>
    <h1>Dockerfile INFLUX Credentials Report</h1>

    <div class="section">➤ Dockerfile Data</div>
    <p class="parsed-data">Parsed variables and InfluxDB credentials report:</p>

    <div class="codeblock">
Influx UI Admin Username: $influx_ui_user
Influx UI Admin Password: $influx_ui_password
Organization Name: $influx_organization
Bucket Name: $influx_bucket
Retention Period: $influx_bucket_retention
Authentication Token: $influx_token
    </div>

    <div class="section">➤ Setup Steps Taken</div>
    <p class="parsed-data">✔ Prompted user for InfluxDB details</p>
    <p class="parsed-data">✔ Generated Dockerfile with user input</p>
    <p class="parsed-data">✔ Saved setup credentials in credentials_report.txt</p>
    <p class="parsed-data">✔ Created this HTML report</p>

    <div class="footer">Generated on $timestamp</div>

</body>
</html>
EOF

echo "HTML Report saved to: $report_file"
echo
read -p "Press enter to terminate this session... " read enter
