#!/bin/bash

set -e

echo "=== [1] Creating Folder Structure ==="
mkdir -p /home/LinkEye/{DeX,WAN,LAN}
cd /home/LinkEye

echo "=== [2] Cloning DeX Repository ==="
git config --global credential.helper store
echo "https://leetcodeisalie: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@github.com" > ~/.git-credentials

if [ -d "DeX/.git" ]; then
    cd DeX
    git pull origin main
else
    git clone https://github.com/Filoffee-AI/DeX-Monitoring-V2.git DeX
fi

cd /home/LinkEye/DeX

echo "=== [3] Creating Python Virtual Environment ==="
/usr/bin/python3.12 -m venv dex_venv
source dex_venv/bin/activate

echo "=== [4] Installing Python Packages in Virtualenv ==="
pip install --upgrade pip
pip install \
    python-dotenv \
    aiomysql \
    scapy \
    asyncio \
    schedule \
    aiohttp \
    speedcheck \
    paramiko \
    aiofiles \
    netifaces \
    pytz

deactivate

echo "=== [5] Installing Ubuntu Packages ==="
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    mysql-server \
    nmap \
    dublin-traceroute \
    net-tools \
    wireguard \
    ca-certificates \
    ntp \
    python3.12-venv \
    python3-pip \
    git

echo "=== [6] Starting & Enabling NTP ==="
sudo systemctl start ntp
sudo systemctl enable ntp

echo "=== [7] Securing MySQL ==="
sudo mysql_secure_installation <<EOF

n
y
y
y
y
EOF

echo "=== [8] Creating MySQL User, Database, and Tables ==="
sudo mysql -u root <<'EOF'
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Fil0ff33@2025';
FLUSH PRIVILEGES;

CREATE USER IF NOT EXISTS 'dex_user'@'localhost' IDENTIFIED BY 'Fil0ff33@2025';
GRANT ALL PRIVILEGES ON *.* TO 'dex_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS dex;
USE dex;

DROP TABLE IF EXISTS fn_application_ssl_metrics;
DROP TABLE IF EXISTS fn_apps_present_default_metrics;
DROP TABLE IF EXISTS fn_apps_present_tcp_metrics;
DROP TABLE IF EXISTS fn_apps_present_udp_metrics;
DROP TABLE IF EXISTS fn_apps_previous_default_metrics;
DROP TABLE IF EXISTS fn_apps_previous_tcp_metrics;
DROP TABLE IF EXISTS fn_apps_previous_udp_metrics;
DROP TABLE IF EXISTS fn_apps_traceroute_metrics;
DROP TABLE IF EXISTS fn_cust_apps_details;
DROP TABLE IF EXISTS fn_cust_apps_ports_details;
DROP TABLE IF EXISTS fn_dns_metrics;
DROP TABLE IF EXISTS fn_s2s_monitoring_sites;
DROP TABLE IF EXISTS fn_s2s_site_availability_metrics;
DROP TABLE IF EXISTS fn_tcp_session_monitoring_metrics;

CREATE TABLE fn_application_ssl_metrics (
  id int NOT NULL AUTO_INCREMENT,
  app_id int NOT NULL,
  cust_id int NOT NULL,
  location_id int NOT NULL,
  app_name varchar(255) NOT NULL,
  ent datetime NOT NULL,
  sent_db int NOT NULL,
  ssl_issuer_name varchar(255) DEFAULT NULL,
  ssl_expiry_date date DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_present_default_metrics (
  id int NOT NULL AUTO_INCREMENT,
  app_id int DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  app_status int DEFAULT NULL,
  app_type int DEFAULT NULL,
  latency float DEFAULT NULL,
  packet_loss float DEFAULT NULL,
  jitter float DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_present_tcp_metrics (
  id int NOT NULL AUTO_INCREMENT,
  port_id int DEFAULT NULL,
  app_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  tcp_port_num int DEFAULT NULL,
  tcp_port_state varchar(255) DEFAULT NULL,
  tcp_port_jitter float DEFAULT NULL,
  tcp_port_latency float DEFAULT NULL,
  tcp_port_packet_loss float DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  tcp_port_criticality varchar(255) DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_present_udp_metrics (
  id int NOT NULL AUTO_INCREMENT,
  port_id int DEFAULT NULL,
  app_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  udp_port_num int DEFAULT NULL,
  udp_port_state varchar(255) DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  udp_port_criticality varchar(255) DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_previous_default_metrics (
  id int NOT NULL AUTO_INCREMENT,
  app_id int DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  app_status int DEFAULT NULL,
  app_type int DEFAULT NULL,
  latency float DEFAULT NULL,
  packet_loss float DEFAULT NULL,
  jitter float DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_previous_tcp_metrics (
  id int NOT NULL AUTO_INCREMENT,
  port_id int DEFAULT NULL,
  app_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  tcp_port_num int DEFAULT NULL,
  tcp_port_state varchar(255) DEFAULT NULL,
  tcp_port_jitter float DEFAULT NULL,
  tcp_port_latency float DEFAULT NULL,
  tcp_port_packet_loss int DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_previous_udp_metrics (
  id int NOT NULL AUTO_INCREMENT,
  port_id int DEFAULT NULL,
  app_id int DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  udp_port_num int DEFAULT NULL,
  udp_port_state varchar(255) DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_apps_traceroute_metrics (
  id int NOT NULL AUTO_INCREMENT,
  app_id varchar(255) DEFAULT NULL,
  cust_id varchar(255) DEFAULT NULL,
  location_id varchar(255) DEFAULT NULL,
  app_url varchar(255) DEFAULT NULL,
  app_status varchar(255) DEFAULT NULL,
  traceroute_data json DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_cust_apps_details (
  app_id int NOT NULL AUTO_INCREMENT,
  cust_id int DEFAULT NULL,
  group_id int DEFAULT NULL,
  app_url varchar(255) DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  app_type int DEFAULT '1',
  default_monitoring_type int DEFAULT '0',
  port_num int DEFAULT '0',
  location_id int DEFAULT NULL,
  resolved_ip varchar(255) DEFAULT NULL,
  app_hostname varchar(255) DEFAULT NULL,
  PRIMARY KEY (app_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_cust_apps_ports_details (
  port_id int NOT NULL AUTO_INCREMENT,
  app_id int DEFAULT '0',
  app_url varchar(255) DEFAULT NULL,
  port_number int DEFAULT NULL,
  criticality varchar(255) DEFAULT NULL,
  port_type int DEFAULT NULL,
  functionality varchar(255) DEFAULT NULL,
  location_id int DEFAULT NULL,
  cust_id int DEFAULT NULL,
  PRIMARY KEY (port_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_dns_metrics (
  id int NOT NULL AUTO_INCREMENT,
  cust_id int NOT NULL,
  location_id int NOT NULL,
  dns_server_ip varchar(45) NOT NULL,
  availability int DEFAULT '0',
  resolution_time float DEFAULT '0',
  latency float DEFAULT '0',
  packet_loss float DEFAULT '100',
  health_status enum('Healthy','Unhealthy') DEFAULT 'Unhealthy',
  ent datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sent_db int DEFAULT '0',
  PRIMARY KEY (id),
  KEY cust_id (cust_id),
  KEY location_id (location_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_s2s_monitoring_sites (
  id int NOT NULL AUTO_INCREMENT,
  source_private_ip varchar(15) DEFAULT NULL,
  dest_private_ip varchar(15) DEFAULT NULL,
  protocol varchar(5) DEFAULT NULL,
  port int DEFAULT NULL,
  cust_id int DEFAULT NULL,
  dest_location_id int DEFAULT NULL,
  source_location_id int DEFAULT NULL,
  dest_public_ips json DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_s2s_site_availability_metrics (
  id int NOT NULL AUTO_INCREMENT,
  cust_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  dest_location_id varchar(15) NOT NULL,
  dest_IP varchar(15) NOT NULL,
  latency float DEFAULT NULL,
  jitter float DEFAULT NULL,
  packet_loss float DEFAULT NULL,
  status int DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE fn_tcp_session_monitoring_metrics (
  id int NOT NULL AUTO_INCREMENT,
  app_id varchar(255) DEFAULT NULL,
  cust_id varchar(255) DEFAULT NULL,
  location_id varchar(255) DEFAULT NULL,
  app_url varchar(255) DEFAULT NULL,
  app_name varchar(255) DEFAULT NULL,
  app_status varchar(255) DEFAULT NULL,
  session_establishment_status tinyint(1) DEFAULT NULL,
  rtt int DEFAULT NULL,
  packet_transformation_percentage float DEFAULT NULL,
  throughput float DEFAULT NULL,
  ent datetime DEFAULT NULL,
  sent_db int DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

EOF

echo "=== [9] Creating Systemd Service for DeX ==="
sudo tee /etc/systemd/system/dex.service > /dev/null <<EOF
[Unit]
Description=Run DeX scripts after restart, shutdown, and power-up

[Service]
Type=simple
WorkingDirectory=/home/LinkEye/DeX
ExecStartPre=/bin/sleep 30
ExecStart=/home/LinkEye/DeX/dex_venv/bin/python /home/LinkEye/DeX/main.py
Environment="TZ=Asia/Kolkata"

[Install]
WantedBy=default.target
EOF

echo "=== [10] Reloading and Starting Services ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable mysql
sudo systemctl enable dex.service
sudo systemctl restart mysql
sudo systemctl restart dex.service

echo "✅ DeX installation and setup complete."
