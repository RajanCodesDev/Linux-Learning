# Privileges Without sudo (Ubuntu 22.04)

This setup allows normal users to operate their Linux workstation comfortably **without giving them sudo access**.
Instead of giving full root privileges, specific actions are allowed through **polkit policies**.

The goal is simple:

* Users should be able to **use their machines like a normal desktop OS**
* The system should **avoid granting full administrative control**
* Privileges should be **task-based instead of root-based**

Tested on **Ubuntu 22.04**.

---

# Why this exists

Traditionally Linux systems work like this:

```
user → sudo → root
```

Once sudo is granted, the user effectively has unlimited power.

For shared systems or managed workstations this is not ideal.

This configuration changes the model to:

```
user → allowed system action → polkit → privileged service
```

The user never becomes root.
Instead, system services perform approved operations on the user’s behalf.

This approach is closer to how modern desktop operating systems manage privileges.

---

# What this repository provides

A set of **polkit policy files** that allow members of a specific group (for example `devs`) to perform common workstation tasks without requiring sudo.

Policies are separated by purpose for easier management.

Example structure:

```
/etc/polkit-1/localauthority/50-local.d/

dev-software.pkla
dev-network.pkla
dev-services.pkla
dev-time.pkla
dev-power.pkla
```

---

# User capabilities

Users in the allowed group can perform common desktop operations such as:

### Software Management

* Install applications from the Ubuntu App Center
* Install or remove packages via PackageKit
* Install or remove Snap packages

### Service Control

* Restart services when required for development
* Manage local development services

### Network Management

* Connect or disconnect from networks
* Modify network connections using NetworkManager

### Date & Time

* Change system time
* Change timezone
* Enable or disable NTP synchronization
* Modify settings through GNOME Settings

### Power Actions

* Shutdown or reboot the system (if enabled)

These permissions allow users to operate their workstation without needing administrative intervention for routine tasks.

---

# What users cannot do

Even with these policies, users **do not gain root access**.

The following actions remain restricted:

* Running `sudo`
* Opening a root shell
* Modifying system files in `/etc`
* Managing system users
* Editing sudo configuration
* Installing packages using raw `apt` or `dpkg`
* Executing arbitrary commands as root
* Changing security configuration

Example commands that remain blocked:

```
sudo bash
pkexec bash
apt install package
useradd test
visudo
```

---

# Security model

This setup is based on **least privilege**.

Instead of giving full administrative access, only the exact capabilities required for workstation use are granted.

Key properties:

* Users never obtain a root shell
* Actions are restricted to specific system services
* Privileges are tied to group membership
* Policies can be audited and adjusted easily

Note that allowing software installation means packages may execute scripts as root during installation.
For developer workstations this is usually acceptable.

---

# Intended environment

This configuration is designed for:

* Developer workstations
* Lab environments
* Shared Linux desktops
* Internal company machines

It is **not intended for production servers** where stricter administrative control is required.

Servers should rely on carefully audited sudo policies instead.

---

# How it works (simplified)

```
User
 │
 │ request action
 ▼
System service (NetworkManager / PackageKit / snapd / systemd)
 │
 │ polkit check
 ▼
Policy decision
 │
 ├─ allowed → action executed
 └─ denied → authentication required
```

---

# Testing

The policies were tested on:

```
Ubuntu 22.04
GNOME desktop
snapd
PackageKit
systemd
NetworkManager
```

Typical verification steps included:

* Installing applications through the GUI store
* Restarting services
* Modifying time settings
* Managing network connections

While confirming that root escalation attempts remained blocked.

---

# Important note

This configuration improves usability but does not create a fully hardened environment.

If a user can install software, they can potentially run code with elevated privileges through package installation scripts.

Therefore this setup assumes a **trusted workstation environment**.

---

# Summary

This project demonstrates a practical way to run Linux desktops without granting sudo access while still allowing users to be productive.

It replaces broad administrative privileges with controlled, task-based permissions using polkit.

---

If you use or adapt this setup, review each policy carefully and adjust according to your environment and risk tolerance.
