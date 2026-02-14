# SOC Lab Script Instructions

Here’s a **ready-to-run SOC lab script** to generate **test Linux auth logs** on your Log Source VM. This is useful for validating Splunk Forwarder and index pipelines.

It will:
- Append entries to /var/log/auth.log
- Simulate **successful and failed SSH logins**
- Add **timestamps** in real-time
- Safe for lab environment

## ✅ Usage Instructions
1. Copy this file to **Log Source VM**:
```bash
scp generate-test-logs.sh user@log-source-vm:/home/user/
```
2. Make it executable:
```bash
chmod +x generate-test-logs.sh
```
3. Run it:
```bash
sudo ./generate-test-logs.sh
```
4. Verify logs are appended:
```bash
tail -f /var/log/auth.log
```

## ✅ Verify in Splunk
Search in Splunk:
```spl
index=linux_auth sourcetype=linux_secure "Accepted password"
index=linux_auth sourcetype=linux_secure "Failed passwor"
index=linux_auth sourcetype=linux_secure "Invalid user"
```
