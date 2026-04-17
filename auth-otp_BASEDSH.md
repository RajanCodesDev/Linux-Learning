----
# OTP Based SSH

# Install Package
```
sudo apt update
sudo apt install libpam-google-authenticator
```

# Generate OTP secret (per user)
```
google-authenticator
```



## Configure SSH : /etc/ssh/sshd_config 
```
Include /etc/ssh/sshd_config.d/*.conf
ChallengeResponseAuthentication yes
UsePAM yes
KbdInteractiveAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
PasswordAuthentication no
PermitEmptyPasswords no
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server
```
## Configure PAM : /etc/pam.d/sshd
```
auth required pam_google_authenticator.so <---- Add This 
@include common-auth
account    required     pam_nologin.so
@include common-account
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_keyinit.so force revoke
@include common-session
session    optional     pam_motd.so  motd=/run/motd.dynamic
session    optional     pam_motd.so noupdate
session    required     pam_limits.so
session    required     pam_env.so user_readenv=1 envfile=/etc/default/locale
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so open
@include common-password
```

# Restart SSH
```
sudo systemctl restart ssh
```
