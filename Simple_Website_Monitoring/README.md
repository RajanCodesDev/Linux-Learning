# Lightweight Website Uptime Monitor (Bash + Cron + Telegram)

This project is a minimal, no-nonsense uptime-monitoring script that uses nothing more than **bash**, **curl**, and **cron**.  
No paid SaaS. No heavyweight agents. Just pure command-line power.

---

## 🧠 What This Script Does

- Checks a list of websites periodically.  
- Retries each site 3 times before marking it as down.  
- Sends **Telegram alerts** instantly when a site:
  - **Goes DOWN**
  - **Recovers back UP**
- Stores the current "down" sites in `/tmp/sites_down.txt` so alerts are never spammy.
- Works on any Linux machine — no dependencies except `curl`.

---

## 🚀 Why I Built This

I wanted simple uptime monitoring without:
- Paying for tools that charge per check  
- Running heavy containers or dashboards  
- Maintaining Prometheus/Grafana just for "is my site alive?"

This script replaces all of that.  
It runs locally, costs nothing, and I control everything.

---

## 🧩 How It Works Internally

- `curl -w "%{http_code}"` is used to fetch only the HTTP status.
- A retry loop handles flaky intermediate failures.
- A temporary state file keeps track of which websites were previously down.
- Telegram Bot API is used for instant push notifications.

You can schedule it via cron:
```bash
*/2 * * * * /bin/bash /path/to/monitor.sh
```

This checks every 2 minutes.  
Adjust to whatever fits your needs.

---

## 📦 Configuration

Set your Telegram credentials:
```bash
BOT_TOKEN="your_bot_token_here"
CHAT_ID="your_chat_id_here"
```

Add your websites:
```bash
websites=(
  "https://site1.com"
  "https://site2.com"
  "https://site3.com"
)
```

Done.

---

## 🧪 Example Alerts

**When a site goes down:**
> ⚠️ [2025-11-27 12:11:14] Site DOWN: https://example.com (HTTP 503)

**When it recovers:**
> ✅ [2025-11-27 12:14:19] Site RECOVERED: https://example.com (HTTP 200)

---

## 🛠 Why This Script Is Better Than It Looks

- Runs on any cheap VPS or your home server
- Zero configuration outside the script
- No dashboards, no databases, no vendor lock-in
- Transparent and editable — you know exactly what it does
- Uses only standard Linux tooling

This is the kind of monitoring you build once and it just… works.

---

## 📄 License

MIT License. Use it, modify it, break it, fix it.
