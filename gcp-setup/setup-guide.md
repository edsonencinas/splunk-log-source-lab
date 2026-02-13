# GCP Setup Guide for Splunk Log Source Lab

This guide explains how to provision the VMs, configure networking, and open the necessary ports on **Google Cloud Platform (GCP)** for the Splunk SOC lab.

---

## 1. Create the Splunk Server VM (Indexer)

1. Go to **GCP Console → Compute Engine → VM Instances → Create VM**  
2. Configure the VM:

| Setting          | Value |
|------------------|-------|
| Name             | splunk-server |
| Zone             | us-central1-a | ***Choose zone closer to your location***
| Machine type     | e2-standard-2 (2 vCPU, 8 GB RAM) |
| Boot disk        | Debian-12 Bookworm, 50 GB |
| Firewall         | Allow HTTP (80), HTTPS (443) optional |

3. Note the **internal/external IP**. You will use it for the forwarder.

---

## 2. Create the Log Source VM

1. Go to **GCP Console → Compute Engine → VM Instances → Create VM**  
2. Configure the VM:

| Setting          | Value |
|------------------|-------|
| Name             | log-source |
| Zone             | us-central1-a | ***Choose zone closer to your location***
| Machine type     | e2-micro (2 vCPU, 1 GB RAM) |
| Boot disk        | Debian-12 Bookworm, 10 GB |
| Firewall         | Allow SSH |

3. Assign an internal/external IP. This will be your **log source VM**.

---

## 3. Configure GCP Firewall Rules

We need to allow **Splunk forwarders to communicate** with the Splunk server.

### 3.1 Allow Splunk Forwarder Traffic

- Go to **VPC Network → Firewall → Create Firewall Rule**
- Configure:

| Setting          | Value |
|------------------|-------|
| Name             | allow-splunk-forwarder |
| Network          | default |
| Direction        | Ingress |
| Action           | Allow |
| Targets          | All instances in network (or just Splunk Server) |
| Source IP ranges | LOG_SOURCE_VM_IP/32 |
| Protocols/ports  | TCP:9997 |

### 3.2 Allow Splunk Web Access (Optional)

- Firewall rule for **port 8000**:

| Setting          | Value |
|------------------|-------|
| Name             | allow-splunk-web |
| Protocols/ports  | TCP:8000 |
| Source IP ranges | 0.0.0.0/0 (or restrict to your IP) |

---

## 4. SSH Into VMs

```bash
# Splunk Server
ssh user@splunk-server-ip

# Log Source VM
ssh user@log-source-ip

***Note: Usually I add my machine's public key to GCP. Adding your public key at project level grant you all access to all current and future VM instances. Less hastle for you.***