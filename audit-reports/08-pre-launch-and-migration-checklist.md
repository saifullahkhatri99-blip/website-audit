# 08. Pre-Launch & Live Migration Checklist

This actionable checklist guides the development and DevOps team step-by-step through a flawless launch from staging (`https://crmapi.designstime.com`) to the live production domain (`https://globalsalah.com`).

---

## 📋 Phase 1: Critical Code & Template Fixes (Pre-DNS)

- [ ] **1. Fix Sitemaps Base URL:**
  - Update `blog-sitemap.xml` and `forum-sitemap.xml` to replace all `http://localhost/Global_Salah_New/site/public/` URLs with `https://globalsalah.com/`.
- [ ] **2. Fix Blog Structured Data (JSON-LD):**
  - Remove all hardcoded `localhost` references from article schema templates (`headline`, `url`, `image`, `@id`).
- [ ] **3. Fix Corrupted Character Encodings:**
  - Run a global search-and-replace for `?Ts` ➡️ `'s`, `?\"` ➡️ `–`, and `?` ➡️ `…` across all template files.
- [ ] **4. Remove `<base href="./">` Tag:**
  - Delete `<base href="./">` and `<script>if(location.protocol==="file:")...</script>` from `<head>`.
  - Convert all relative links (`./blog/`, `./countries/`) to absolute root-relative links (`/blog/`, `/countries/`).
- [ ] **5. Inject High-Impact Schemas:**
  - Add `WebApplication` schema to `/zakat-calculator/`, `/qibla-finder/`, `/prayer-tracker/`, `/inheritance-calculator/`.
  - Add `Place` + `GeoCoordinates` schema to city prayer schedule pages.
  - Add `Event` schema to `/special-islamic-days/*`.
  - Add `Book` / `CreativeWorkSeries` schema to Hadith pages.
  - Add `SearchAction` to homepage `WebSite` schema.

---

## 📋 Phase 2: Server & Infrastructure Setup

- [ ] **6. Deploy Security Headers:**
  - Copy `server-config/.htaccess` to the web root.
  - Verify HSTS, X-Content-Type-Options, X-Frame-Options, CSP, and Referrer-Policy headers.
- [ ] **7. Setup 301 Redirect Rules:**
  - Redirect `/about/` ➡️ `/about-us/`
  - Redirect `/contact/` ➡️ `/contact-us/`
  - Redirect `/terms-of-service/` ➡️ `/terms-and-conditions/`
  - Redirect `/qibla/` ➡️ `/qibla-finder/`
  - Redirect `/countries/saudi-arabia/makkah/` ➡️ `/countries/saudi-arabia/mecca/`
  - Redirect `/sitemap_index.xml` ➡️ `/sitemap.xml`
- [ ] **8. Setup Static Asset Caching:**
  - Enable 1-year immutable caching for `.css`, `.js`, `.webp`, `.png`, and `.woff2` files.
  - Ensure HTML has `Cache-Control: public, max-age=0, must-revalidate`.

---

## 📋 Phase 3: DNS Cutover & SSL Configuration

- [ ] **9. Point DNS Records:**
  - Set Apex `globalsalah.com` `A` record ➡️ Production Server IP.
  - Set `www.globalsalah.com` `CNAME` ➡️ `globalsalah.com`.
  - Enforce automatic 301 redirect from `http://` ➡️ `https://` and `www` ➡️ non-`www` (or vice versa).
- [ ] **10. Provision SSL / TLS Certificate:**
  - Ensure Let's Encrypt / ZeroSSL certificate covers both `globalsalah.com` and `www.globalsalah.com` with auto-renewal enabled.

---

## 📋 Phase 4: Post-Launch Search Engine & Tracking Verification

- [ ] **11. Google Search Console Setup:**
  - Add Domain Property for `globalsalah.com`.
  - Submit Primary Sitemap Index: `https://globalsalah.com/sitemap.xml`.
  - Verify zero errors across all 32 sub-sitemaps.
- [ ] **12. Bing Webmaster Tools Setup:**
  - Import verified property from Google Search Console.
  - Submit sitemap index.
- [ ] **13. Rich Results Testing Validation:**
  - Test Homepage, City Prayer Page, Zakat Calculator, and Blog Post in [Google Rich Results Test](https://search.google.com/test/rich-results).
  - Verify all schema entities validate without errors.
- [ ] **14. Protect Staging Environment:**
  - Add HTTP Basic Authentication to `https://crmapi.designstime.com` or set `X-Robots-Tag: noindex, nofollow` to prevent staging from competing with production in Google.
