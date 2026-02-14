# Splunk Log Source Lab on GCP - Linux Forwarder to Splunk SIEM

## 💼 Project Overview

This project demonstrates a **basic Security Operations Center (SOC) lab** using Splunk SIEM.  
It simulates Linux log collection from a **Log Source VM** using the **Splunk Universal Forwarder**, forwarding authentication logs to a **Splunk Server VM** hosted on **Google Cloud Platform (GCP)**.

This project is designed for **SOC learning, industry best practices, and threat simulation**.

## 🗺️ Architecture
```
Log Source VM (Debian 12 Bookworm)
├─ Splunk Universal Forwarder (splunkfwd user)
├─ Monitors: /var/log/auth.log
└─ Forwards logs → Splunk Server VM (9997)

Splunk Server VM (Debian 12 Bookworm)
├─ Splunk Enterprise Free
├─ Receives logs (port 9997)
├─ Web UI (port 8000)
└─ Dashboards / Searches / Alerts
```
<img src="docs/SOC-lab-design-diagram.png" width="800">

** 🧩Components:**

1. **Splunk Enterprise Server VM**
   - Receives logs from forwarders
   - Hosts Splunk Web UI on port `8000`
   - TCP input port `9997` for Universal Forwarders

2. **Log Source VM (Linux)**
   - Installs Universal Forwarder
   - Monitors `/var/log/auth.log`
   - Sends logs securely to Splunk Server

3. **Firewall Layers**
   - **GCP Firewall:** Controls ingress/egress traffic between VMs
   - **UFW OS Firewall:** Secures the VM at the operating system level

## 📌 Prerequisites

- Google Cloud account (Free Trial with $300 credit for 90 days)
- Two Ubuntu VMs:
  - **Splunk Server VM:** 2 vCPU, 8 GB RAM (for lab)
  - **Log Source VM:** 1 vCPU, 2 GB RAM
- Internet access to download Splunk packages
  
### Splunk Enterprise Package
<img src="screenshots/splunk-enterprise.png" width="800">

### Splunk Universal Forwarder
<img src="screenshots/splunk-univeral-forwarder.png" width="800">

## Splunk Server VM and Log Source VM Creation Guide
Link to VMs Setup guide:
[GCP VMs Setup Guide](gcp-setup/setup-guide.md)

***Note: Create the required VMs first before proceeding to the next step***

## Splunk Server VM Setup
### 1. 🔐 SSH into Splunk Server VM
```bash
ssh -i PATH_TO_SSH-KEY.pub user@SPLUNK-SERVER_IP
```

### 2. 🔄 Update system and Install UFW Firewall

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl ufw -y
```

### 3. 📦 Install Splunk Enterprise

```bash
# Sign up and download Splunk Enterprise Free trial package : https://www.splunk.com/en_us/download.html 
wget -O splunk-10.x.x.deb 'DOWNLOAD LINK'

# Install
sudo dpkg -i splunk-10.x.x.deb
```
### 4. 👤 Create the Splunk user
```bash
sudo useradd -m splunk
sudo passwd splunk
```
### 5. 🔧 Fix Ownership
```bash
sudo chown -R splunk:splunk /opt/splunk
```
### 6. ▶️ Start Splunk and dedicated user
```bash
sudo su - splunk
/opt/splunk/bin/splunk start --accept-license
```
- When prompted, enter/create the Splunk administrator username and password, and store them securely.
- Note: Splunk Enterprise runs as `splunk` user. Do **NOT run as root** in production.

### 7. 🌐 Access Splunk Web UI for the First Time
Find VM external IP:
```bash
http://YOUR_VM_IP:8000
```
Login:
- Username : admin
- Password : set during install

<img src="screenshots/splunk-ui.png" width="800">

### 8. ♻️ Enable Auto Start
Exit `splunk` user first:
```bash
exit
sudo /opt/splunk/bin/splunk enable boot-start -user splunk
```

### 9. 🔥 UFW Configuration for Splunk Server VM (Firewall)
```bash
# SSH
sudo ufw allow from YOUR_IP to any port 22 proto tcp
# Splunk Web
sudo ufw allow from YOUR_IP to any port 8000 proto tcp
# Splunk Forwarders
sudo ufw allow from FORWARDER_IP to any port 9997 proto tcp
```
Don't forget the Default Deny rules.
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```
Enable firewall:
```bash
sudo ufw enable
sudo ufw status verbose
```

## Log Source VM Setup (Splunk Universal Forwarder)

### 1. SSH into Log Source VM and Update
```bash
ssh -i PATH_TO_SSH-KEY.pub user@LOG_SOURCE_IP
sudo apt update && sudo apt upgrade -y
```

### 2. 📦 Download Splunk Universal Forwarder
```bash
wget -O splunkforwarder-10.2.0-d749cb17ea65-linux-amd64.deb "DOWNLOAD LINK"
```

### 3. 👤 Create Dedicated Forwarder User (CRITICAL)
**Never run forwarder as root
```bash
sudo useradd -m splunkfwd
sudo passwd splunkfwd
```
### 4. ⚙️ Install Splunk Universal Forwarder
```
sudo dpkg -i splunkforwarder.deb
```
### 5. 🔐 Fix Ownership (Important Step)
```bash
sudo chown -R splunkfwd:splunkfwd /opt/splunkforwarder
```

### 6. ▶️ Start Forwarder for the First Time
```bash
# Switch to Splunk Forwarder User.
sudo su - splunkfwd
/opt/splunkforwarder/bin/splunk start --accept-license
```
- Create another Administrator username and password and keep it securely.

### 7. 🔄 Stop Splunk Forwarder to Enable Boot Start (Run as Root)
-Exit as `splunkfwd` user:
```bash
exit
sudo -u splunkfwd /opt/splunkforwarder/bin/splunk stop
sudo /opt/splunkforwarder/bin/splunk enable boot-start -user splunkfwd
```

### 8. 🌐 Add Splunk Server (Indexer)
Switchback to user `splunkfwd`:
```bash
sudo su - splunkfwd
```
```bash
/opt/splunkforwarder/bin/splunk add forward-server SPLUNK_SERVER_IP:9997
```

### 9. 📥 Add Linux Auth Logs (SOC Use Case)
```bash
/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index linux_auth -sourcetype linux_secure
```

### 10. 🔁 Restart Splunk Forwarder
```bash
/opt/splunkforwarder/bin/splunk add forward-server SPLUNK_SERVER_IP:9997
```

### 11. ✅ Verify Splunk Forwarder Status
```bash
/opt/splunkforwarder/bin/splunk list forward-server
```
Expected output:
```bash
Active forwards:
  SPLUNK_SERVER_IP:9997
```
### 12. ⚙️ UFW Firewall Configuration for Log Source VM
Allow your local machine to SSH the Log Source VM
```bash
# SSH
sudo ufw allow from YOUR_IP to any port 22 proto tcp
# Default deny
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Enable  the firewall
sudo ufw enable
sudo ufw status verbose
```


### 13. ✅ Enable Splunk Server to Listen on port 9997
Run on Splunk Server VM
```bash
sudo -u splunk /opt/splunk/bin/splunk enable listen 9997
```

## 🧪 Generate Test Logs
**On Log Source VM:**
```bash
ssh fakeuser@localhost
```
**Check in Splunk**
```
index=linux_auth "Invalid user"
```
<img src="screenshots/splunk-test-event.png" width="800">

## ➕ Future Expansion
This lab can be extended to simulate a full enterprise SOC environment. Future improvements include:
- Windows Endpoint Logging: Deploy Windows VMs with Splunk Universal Forwarder and ingest Security, PowerShell, and Sysmon logs to detect brute-force attacks, privilege escalation, and lateral movement.
- **Additional Linux Telemetry**: Ingest syslog, auditd, and system logs to improve visibility into command execution and persistence techniques.
- **Network and Cloud Logs**: Integrate GCP VPC Flow Logs, firewall logs, and web server logs to detect network anomalies and web-based attacks.
- **Detection & Alerting**: Build correlation searches, alerts, and SOC dashboards for authentication anomalies and admin activity monitoring.
- **Automation & SOAR**: Automate response actions (e.g., blocking IPs, sending alerts) using scripts or orchestration tools.
- **Threat Intelligence & MITRE Mapping**: Enrich logs with threat intel feeds and map detections to MITRE ATT&CK techniques.

These enhancements will evolve the lab into a comprehensive detection engineering and SOC simulation platform.

## ✨ Conclusion
This project demonstrates a complete end-to-end deployment of a **Splunk-based SIEM lab on Google Cloud Platform**, covering infrastructure provisioning, security hardening, log ingestion, and validation. By building both a **Splunk Enterprise server** and a **Linux log source with Universal Forwarder**, this lab replicates a real-world SOC ingestion pipeline where telemetry is collected, transported, and indexed for security monitoring.

Key outcomes of this project include:
- Designing a secure cloud-based SIEM architecture with network segmentation and firewall controls
- Implementing OS-level and cloud-level firewall rules to restrict management and data ingestion traffic
- Deploying Splunk Enterprise and Universal Forwarder using dedicated service accounts to follow least-privilege best practices
- Configuring log monitoring for Linux authentication logs and validating ingestion through Splunk searches

Overall, this project showcases practical SIEM engineering skills, cloud security fundamentals, and SOC operational workflows—skills directly applicable to security analyst, detection engineer, and cloud security roles.
