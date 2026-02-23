# PATH : 
```
sudo nano /etc/polkit-1/localauthority/50-local.d/dev-software.pkla
```
---
### file contents:
```
[Dev software management]
Identity=unix-group:devs
Action=org.freedesktop.packagekit.*;org.debian.apt.*;io.snapcraft.snapd.*
ResultActive=yes
ResultInactive=yes
ResultAny=yes
```



