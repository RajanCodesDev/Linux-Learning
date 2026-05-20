# WordPress Performance Optimization Checklist (NGINX + PHP-FPM + Redis + FastCGI)

## Goal

Optimize WordPress sites for:

- Lower TTFB
- Faster LCP
- Better Lighthouse/PageSpeed scores
- Lower PHP load
- Better concurrent handling
- Reduced frontend payload

---

# 1. NGINX Gzip Compression

Edit:

```bash
/etc/nginx/nginx.conf
```

Inside `http {}`:

```nginx
gzip on;
gzip_comp_level 5;
gzip_min_length 256;
gzip_vary on;
gzip_proxied any;

gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    application/json
    application/javascript
    application/xml+rss
    application/xml
    application/rss+xml
    image/svg+xml;
```

Verify:

```bash
curl -I -H "Accept-Encoding: gzip" https://domain.com
```

Expected:

```http
Content-Encoding: gzip
```

---

# 2. Enable HTTP/2

Inside SSL server block:

```nginx
listen 443 ssl http2;
listen [::]:443 ssl http2 ipv6only=on;
```

Verify:

```bash
curl -I --http2 https://domain.com
```

Expected:

```http
HTTP/2 200
```

---

# 3. SSL Optimization

Inside `http {}`:

```nginx
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;
```

---

# 4. NGINX Performance Tuning

Inside `http {}`:

```nginx
sendfile on;
tcp_nopush on;
tcp_nodelay on;

keepalive_timeout 65;
keepalive_requests 1000;

open_file_cache max=200000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
open_file_cache_errors on;
```

---

# 5. Browser Cache Headers

Inside site config:

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|svg|webp|avif|css|js|map|json|woff|woff2|ttf)$ {

    expires 30d;

    access_log off;
    log_not_found off;

    add_header Cache-Control "public, immutable";
}
```

---

# 6. FastCGI Cache

Inside PHP block:

```nginx
fastcgi_cache WORDPRESS;
fastcgi_cache_valid 200 301 302 60m;
fastcgi_cache_use_stale error timeout invalid_header updating http_500;
fastcgi_cache_min_uses 1;
fastcgi_cache_lock on;

add_header X-FastCGI-Cache $upstream_cache_status;
```

Bypass rules:

```nginx
set $skip_cache 0;

if ($request_method = POST) {
    set $skip_cache 1;
}

if ($query_string != "") {
    set $skip_cache 1;
}

if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
    set $skip_cache 1;
}

if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in") {
    set $skip_cache 1;
}

fastcgi_cache_bypass $skip_cache;
fastcgi_no_cache $skip_cache;
```

Verify:

```bash
curl -I https://domain.com
```

Expected:

```http
X-FastCGI-Cache: HIT
```

---

# 7. Redis Object Cache

Install Redis:

```bash
sudo apt install redis-server
```

Install PHP extension:

```bash
sudo apt install php-redis
```

Verify:

```bash
redis-cli ping
```

Expected:

```text
PONG
```

WordPress plugin:

- Redis Object Cache

Verify:

```bash
wp redis status
```

---

# 8. Brotli Compression

Install:

```bash
sudo apt install libnginx-mod-http-brotli-filter \
                 libnginx-mod-http-brotli-static
```

Inside `http {}`:

```nginx
brotli on;
brotli_comp_level 5;
brotli_static on;

brotli_types
    text/plain
    text/css
    text/javascript
    application/javascript
    application/json
    application/xml
    image/svg+xml;
```

---

# 9. PHP-FPM Optimization

Pool config:

```bash
/etc/php/8.x/fpm/pool.d/www.conf
```

Recommended:

```ini
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500
```

Restart:

```bash
sudo systemctl restart php8.x-fpm
```

---

# 10. Verify Backend Performance

Test:

```bash
curl -o /dev/null -s -w '\nDNS: %{time_namelookup}\nConnect: %{time_connect}\nSSL: %{time_appconnect}\nTTFB: %{time_starttransfer}\nTotal: %{time_total}\n' https://domain.com
```

Target:

```text
TTFB < 300ms
Total < 2s
```

---

# 11. Frontend Optimization (Highest Impact)

## Remove/Reconsider

- Revolution Slider
- Excessive Elementor widgets
- Multiple carousels
- Unused WooCommerce assets
- jQuery migrate

---

# 12. Delay Non-Critical JavaScript

Recommended plugins:

- FlyingPress
- Perfmatters
- Asset CleanUp

Delay:

- analytics
- social widgets
- sliders
- carousels
- masonry
- chat widgets

---

# 13. Elementor Optimization

Enable:

- Improved Asset Loading
- Improved CSS Loading
- Optimized DOM Output
- Inline Font Icons

---

# 14. Image Optimization

Convert images to:

- WebP
- AVIF

Hero image target:

```text
<200KB
```

Recommended plugins:

- Converter for Media
- ShortPixel
- Imagify

---

# 15. WooCommerce Optimization

Unload WooCommerce scripts globally except:

- Shop
- Cart
- Checkout
- Product pages

Recommended plugin:

- Asset CleanUp

---

# 16. Cloudflare CDN

Enable:

- Brotli
- HTTP/3
- APO (optional)
- Cache Everything rules

Useful for geographically distributed users.

---

# 17. Recommended Performance Targets

## Backend

| Metric | Target |
|---|---|
| TTFB | <300ms |
| FastCGI Cache | HIT |
| Redis | Connected |

## Frontend

| Metric | Target |
|---|---|
| LCP | <2.5s |
| TBT | <200ms |
| CLS | <0.1 |
| Requests | <80 |
| Total Page Size | <2MB |

---

# 18. Useful Commands

Reload nginx:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Check enabled modules:

```bash
nginx -V
```

Check Redis:

```bash
redis-cli info
```

Check PHP-FPM:

```bash
systemctl status php8.x-fpm
```

Check cache headers:

```bash
curl -I https://domain.com
```

---

# Reality Check

Backend optimization has diminishing returns.

Most WordPress performance issues eventually become:

- frontend JavaScript bloat
- oversized images
- Elementor/Slider ecosystems
- third-party scripts

Once FastCGI cache + Redis + gzip + HTTP/2 are working:

Frontend optimization becomes the real work.
