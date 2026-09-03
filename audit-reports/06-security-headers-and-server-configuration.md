# 06. Security Headers & Server Configuration

## 🛡️ Live Security Headers Audit

Target Server: `LiteSpeed Web Server` (`https://crmapi.designstime.com`)

| Security Header | Status on Staging | Required Production Value | Purpose / Protection |
| :--- | :---: | :--- | :--- |
| **Strict-Transport-Security (HSTS)** | ❌ **MISSING** | `max-age=31536000; includeSubDomains; preload` | Forces HTTPS, prevents SSL stripping & man-in-the-middle attacks. |
| **X-Content-Type-Options** | ❌ **MISSING** | `nosniff` | Prevents MIME-type sniffing by browsers. |
| **X-Frame-Options** | ❌ **MISSING** | `SAMEORIGIN` | Prevents clickjacking and unauthorized iframe embedding. |
| **Referrer-Policy** | ❌ **MISSING** | `strict-origin-when-cross-origin` | Protects sensitive URL query parameters on outbound links. |
| **Content-Security-Policy (CSP)** | ❌ **MISSING** | *See configuration below* | Protects against Cross-Site Scripting (XSS) and code injection. |
| **Permissions-Policy** | ❌ **MISSING** | `geolocation=(self), microphone=(), camera=()` | Restricts browser device APIs to approved origins only. |
| **Cross-Origin-Opener-Policy (COOP)** | ❌ **MISSING** | `same-origin-allow-popups` | Isolates browsing context against Spectre-style attacks. |

---

## ⚙️ Production `.htaccess` Configuration for LiteSpeed / Apache

Create or replace `.htaccess` in the production web root with the following production-hardened configuration:

```apache
# ==============================================================================
# GLOBAL SALAH — PRODUCTION SECURITY HEADERS & COMPRESSION CONFIGURATION
# ==============================================================================

<IfModule mod_headers.c>
    # 1. Enforce HTTPS Strict Transport Security (HSTS)
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

    # 2. Prevent MIME type sniffing
    Header always set X-Content-Type-Options "nosniff"

    # 3. Protect against Clickjacking
    Header always set X-Frame-Options "SAMEORIGIN"

    # 4. Strict Referrer Policy
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    # 5. Device Permissions Policy (Allow Geolocation for Prayer/Qibla, block Cam/Mic)
    Header always set Permissions-Policy "geolocation=(self), microphone=(), camera=(), payment=()"

    # 6. Content Security Policy (Allows Google Fonts, Social Sharing, Vanilla Scripts)
    Header set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; img-src 'self' data: https:; media-src 'self' https:; connect-src 'self';"
</IfModule>

# ==============================================================================
# LEVERAGE BROWSER CACHING (EXPIRES & CACHE-CONTROL)
# ==============================================================================
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresDefault "access plus 1 month"

    # HTML Documents (Always revalidate for fresh prayer times/content)
    ExpiresByType text/html "access plus 0 seconds"

    # CSS & JavaScript (1 Year Immutable Cache)
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType text/javascript "access plus 1 year"

    # Images, Fonts & Media (1 Year Cache)
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# ==============================================================================
# GZIP & BROTLI COMPRESSION
# ==============================================================================
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json application/xml image/svg+xml
</IfModule>
```

---

## 🔒 Server Banner Information Leakage Check

- **Current Header Output:** `Server: LiteSpeed`
- **Recommendation:** Keep `ServerTokens ProductOnly` or configure LiteSpeed to suppress specific patch versions to prevent automated fingerprinting by vulnerability scanners.
