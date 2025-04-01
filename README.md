# 📌 InfluxDB & Grafana Docker Project
# AUTHOR: Gustavo Wydler Azuaga
# Release Date: 03/26/2025

## 📖 Overview and project scope
- **Docker-based setup** for **InfluxDB 2.0** and **Grafana**.
- **Time-series data storage, visualization, and monitoring** in a seamless environment. 
- It runs a **bash script** that generates a ready-to-use Dockerfile by dynamically parsing user-defined variables.
- It **sets up all the indluxdb variables** required for set up and running.
- The **Dockerfile** is generated, and ready to build. 

## 🚀 Features
- **Automated Dockerfile Generation** 🛠️
- **InfluxDB 2.0 Installation & Setup** 📊
- **Grafana installation** 🎨
- **INFLUXDB custom admin User, organization, and bucket** 🔧
- **Secure Authentication & Token Management** 🔑
- **Interactive Bash Script for Customization** 💻
- **Directory & File Validation** 🗂️
- **Generates txt, and html reports with the influx credentials**📖 

## 🎯 Functionalities
- **User Prompting for Configurations**: Admin credentials, organization, bucket, and token.
- **Automatic InfluxDB Setup**: Enables authentication and initializes the database.
- **Grafana Installation**: Provides a visualization platform for time-series data.
- **Port Exposure**: 
  - Opens port **8086** (InfluxDB default port)
  - Opens port **3000** (Grafana default port) 
- **Error Handling & Interactive Flow**: Ensures valid input and directory management.

## 📦 Installation & Usage
1️⃣ **Run the Bash script**:
```bash
chmod +x generate_dockerfile.sh
./generate_dockerfile.sh
```
2️⃣ **Follow the prompts** to set up your environment.

3️⃣ **Check the generated Dockerfile** and **build the container**:
```bash
docker build -t influx-grafana .
docker run -d -p 8086:8086 -p 3000:3000 --name monitoring influx-grafana
```

## ⚙️ Technologies Used
- **Docker** 🐳
- **InfluxDB 2.0** 📡
- **Grafana** 📈
- **Bash Scripting** 🖥️
