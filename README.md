# Splunk Log Source Lab - Linux Forwarder to GCP Splunk SIEM

## Project Overview

This project demonstrates a **basic Security Operations Center (SOC) lab** using Splunk SIEM.  
It simulates Linux log collection from a **Log Source VM** using the **Splunk Universal Forwarder**, forwarding authentication logs to a **Splunk Server VM** hosted on **Google Cloud Platform (GCP)**.

This project is designed for **SOC learning, threat simulation, and portfolio showcase**.

---

## Architecture
```
Log Source VM (Ubuntu 22.04)
├─ Splunk Universal Forwarder (splunkfwd user)
├─ Monitors: /var/log/auth.log
└─ Forwards logs → Splunk Server VM (9997)

Splunk Server VM (Ubuntu 22.04)
├─ Splunk Enterprise Free
├─ Receives logs (port 9997)
├─ Web UI (port 8000)
└─ Dashboards / Searches / Alerts
```
