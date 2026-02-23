# PATH
```
sudo nano /etc/polkit-1/localauthority/50-local.d/dev-network.pkla
```
---
## file contents:
```
[Dev network control]
Identity=unix-group:devs
Action=org.freedesktop.NetworkManager.*
ResultActive=yes
```