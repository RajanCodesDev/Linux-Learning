# PATH :
```
sudo nano /etc/polkit-1/localauthority/50-local.d/dev-services.pkla
```
---

## file contents:
```
[Dev service control]
Identity=unix-group:devs
Action=org.freedesktop.systemd1.manage-units
ResultActive=yes
```