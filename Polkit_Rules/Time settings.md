# PATH
```
sudo nano /etc/polkit-1/localauthority/50-local.d/dev-time.pkla
```
---
## file contents:
```
[Dev time settings]
Identity=unix-group:devs
Action=org.freedesktop.timedate1.*;org.gnome.controlcenter.datetime.configure
ResultActive=yes
ResultInactive=yes
ResultAny=yes
```