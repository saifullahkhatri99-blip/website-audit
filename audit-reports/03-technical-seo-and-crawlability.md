# 03. Technical SEO & Crawlability Audit

## 🌐 Sitemap Index & Sub-Sitemaps Hierarchy

The website utilizes a clean XML Sitemap Index structure located at `https://globalsalah.com/sitemap.xml`.

```mermaid
graph TD
    Root[sitemap.xml Index] --> P_EN[pages-en-001.xml]
    Root --> C_EN[countries-en-001.xml]
    Root --> CT_EN[cities-en-001.xml (1,109 Cities)]
    Root --> P_MULTI[pages-{ar,de,es,fr,pt,ru,tr,ur,zh-CN}-001.xml]
    Root --> C_MULTI[countries/cities for 9 Languages]
    Root --> B_SM[blog-sitemap.xml (Requires P0 Fix)]
    Root --> F_SM[forum-sitemap.xml (Requires P0 Fix)]
```

### Sitemap Audit Findings:
- **Index Count:** 32 sub-sitemaps referenced in `sitemap.xml`.
- **City Coverage:** 1,109 cities in English sitemap alone, covering global metropolitan areas with full prayer calculation data.
- **Language Sitemaps:** Sitemaps exist for all 10 language editions.
- **Lastmod Timestamps:** Updated recently (`2026-09-02` / `2026-08-11`).
- **Issues Identified:**
  1. `blog-sitemap.xml` and `forum-sitemap.xml` contain `localhost` URLs (see [02-critical-launch-blockers.md](./02-critical-launch-blockers.md)).
  2. Alternative paths `/sitemap_index.xml` and `/sitemap-index.xml` return 404. It is recommended to add a 301 redirect from `/sitemap_index.xml` to `/sitemap.xml` for crawler compatibility.

---

## 🔗 Canonical Tags & Trailing Slashes

- **Canonical Target:** Canonicals correctly point to the production domain `https://globalsalah.com/...`.
- **Trailing Slash Consistency:** All routes enforce trailing slashes (e.g. `/countries/pakistan/`, `/zakat-calculator/`).
- **Canonical Match Rate:** 100% of tested valid pages have matching self-referential production canonicals.

---

## 🌍 Multilingual Hreflang Implementation

Hreflang tags are declared in the `<head>` of all localized pages.

### Language Tags Present:
```html
<link rel="alternate" hreflang="en" href="https://globalsalah.com/">
<link rel="alternate" hreflang="ar" href="https://globalsalah.com/ar/">
<link rel="alternate" hreflang="de" href="https://globalsalah.com/de/">
<link rel="alternate" hreflang="es" href="https://globalsalah.com/es/">
<link rel="alternate" hreflang="fr" href="https://globalsalah.com/fr/">
<link rel="alternate" hreflang="pt" href="https://globalsalah.com/pt/">
<link rel="alternate" hreflang="ru" href="https://globalsalah.com/ru/">
<link rel="alternate" hreflang="tr" href="https://globalsalah.com/tr/">
<link rel="alternate" hreflang="ur" href="https://globalsalah.com/ur/">
<link rel="alternate" hreflang="zh-CN" href="https://globalsalah.com/zh-CN/">
<link rel="alternate" hreflang="x-default" href="https://globalsalah.com/">
```

### Hreflang Best Practice Checklist:
- [x] Includes `x-default` pointing to default English homepage.
- [x] Correct ISO 639-1 language codes (`en`, `ar`, `de`, `es`, `fr`, `pt`, `ru`, `tr`, `ur`) and ISO 3166-1 country code (`zh-CN`).
- [x] Absolute URLs used in hreflang definitions.
- [!] **Warning:** Sub-pages (like `/countries/pakistan/` and individual tool pages) should only declare hreflang alternates if the corresponding translated page exists. If a tool only exists in English, do not output alternate tags pointing to non-existent translated tool URLs.

---

## 🏷️ Title Tags & Meta Descriptions Audit

### Title Tag Health:
- **Average Title Length:** 45–58 characters (optimal, under 60 char truncation threshold).
- **Brand Consistency:** Appends `| Global Salah` consistently.
- **Keyword Targeting:** Includes high-intent search terms (`Prayer Times`, `Qibla Direction`, `Quran Online`, `Zakat Calculator`).

### Meta Description Health:
- **Homepage Meta Description:** Currently **272 characters** (Over Google's ~160 character limit).
  - *Current:* `"Get the most accurate Prayer times, Qibla direction for more than 1 million places. Read Quran o Hadees, Duas and check today’s date from Hijri Gregorian calendar. Global Salah shows the most accurate/authentic Sehar time and iftar time in the holy month of Ramadan Kareem"`
  - *Recommended (154 characters):* `"Get accurate prayer times, Qibla direction, Quran with audio, authentic Hadith, and Islamic calendar converter for over 1 million cities worldwide."`
- **Sub-pages Meta Descriptions:** Consistently 145–158 characters (optimal).

---

## 🔀 URL Redirects & Legacy Route Mapping (301 Redirects Needed)

During the audit, common user and search engine URL variations were tested. The following legacy routes must have 301 permanent redirects in `.htaccess` / server config:

| Requested URL | Current Status | Desired Destination URL | Action Required |
| :--- | :---: | :--- | :--- |
| `/about/` | 404 NotFound | `https://globalsalah.com/about-us/` | Add 301 Redirect |
| `/contact/` | 404 NotFound | `https://globalsalah.com/contact-us/` | Add 301 Redirect |
| `/terms-of-service/` | 404 NotFound | `https://globalsalah.com/terms-and-conditions/` | Add 301 Redirect |
| `/terms/` | 404 NotFound | `https://globalsalah.com/terms-and-conditions/` | Add 301 Redirect |
| `/qibla/` | 404 NotFound | `https://globalsalah.com/qibla-finder/` | Add 301 Redirect |
| `/qibla-direction/` | 404 NotFound | `https://globalsalah.com/qibla-finder/` | Add 301 Redirect |
| `/tasbeeh-counter/` | 404 NotFound | `https://globalsalah.com/tasbeeh-counter/` | Verify route or redirect |
| `/countries/saudi-arabia/makkah/` | 404 NotFound | `https://globalsalah.com/countries/saudi-arabia/mecca/` | Add 301 Redirect (Makkah -> Mecca) |
| `/sitemap_index.xml` | 404 NotFound | `https://globalsalah.com/sitemap.xml` | Add 301 Redirect |
