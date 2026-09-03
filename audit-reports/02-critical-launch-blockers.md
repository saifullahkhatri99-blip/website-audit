# 02. Critical Launch Blockers (P0 Issues)

> [!CAUTION]
> **DO NOT POINT THE LIVE DOMAIN `globalsalah.com` UNTIL ALL 5 ITEMS IN THIS DOCUMENT ARE FIXED.**  
> Launching with these issues will cause catastrophic indexing errors, broken schemas, and permanent crawl damage in Google Search Console.

---

## 1. 🔴 Sitemaps Hardcoded with `localhost` Development URLs

### 📍 Where Found:
- `https://crmapi.designstime.com/blog-sitemap.xml`
- `https://crmapi.designstime.com/forum-sitemap.xml`

### 🔍 Evidence from Live Server:
```xml
<!-- blog-sitemap.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://localhost/Global_Salah_New/site/public/blog/</loc>
    <lastmod>2026-09-03</lastmod>
  </url>
  <url>
    <loc>http://localhost/Global_Salah_New/site/public/blog/how-prayer-times-are-calculated/</loc>
    <lastmod>2026-08-13</lastmod>
  </url>
  <url>
    <loc>http://localhost/Global_Salah_New/site/public/category/daily-worship/</loc>
    <lastmod>2026-09-03</lastmod>
  </url>
  <!-- 18+ other entries pointing to localhost -->
</urlset>
```

### 💥 Impact:
1. Googlebot and Bingbot will attempt to crawl `http://localhost/...`, causing a **100% Crawl Error Rate** in Search Console.
2. Blog posts, worship guides, categories, tags, and forum threads will **never be indexed**.
3. It exposes the internal developer local machine folder structure (`Global_Salah_New/site/public/`).

### 🛠️ Actionable Fix:
In your sitemap generator script or configuration (e.g. `config.php`, `.env`, or build script), change the base URL parameter from `http://localhost/Global_Salah_New/site/public/` to `https://globalsalah.com/`.

```diff
- <loc>http://localhost/Global_Salah_New/site/public/blog/how-prayer-times-are-calculated/</loc>
+ <loc>https://globalsalah.com/blog/how-prayer-times-are-calculated/</loc>
```

---

## 2. 🔴 Hardcoded `localhost` inside JSON-LD Structured Data

### 📍 Where Found:
All blog article HTML templates (e.g., `https://crmapi.designstime.com/blog/how-prayer-times-are-calculated/`).

### 🔍 Evidence from Live Server:
```json
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "BlogPosting",
      "headline": "How Prayer Times Are Calculated: Sun Position, Methods and Local Checks",
      "url": "http://localhost/Global_Salah_New/site/public/blog/how-prayer-times-are-calculated/",
      "image": "http://localhost/Global_Salah_New/site/public/assets/images/blog/how-prayer-times-are-calculated.webp",
      "datePublished": "2026-08-13",
      "dateModified": "2026-08-13",
      "author": { "@type": "Organization", "name": "Global Salah Research Team" },
      "publisher": { "@type": "Organization", "name": "Global Salah" }
    },
    {
      "@type": "FAQPage",
      "@id": "http://localhost/Global_Salah_New/site/public/blog/how-prayer-times-are-calculated/#faq"
    }
  ]
}
```

### 💥 Impact:
- Schema validation in Google Rich Results Test fails.
- Google will discard the structured data and refuse to render Article rich snippets.
- Broken image URLs inside the schema mean Google Discover and Google News cannot feature the articles.

### 🛠️ Actionable Fix:
Update the template helper responsible for rendering blog post schemas to use dynamic domain canonicalization or the production environment variable `https://globalsalah.com`.

```diff
- "url": "http://localhost/Global_Salah_New/site/public/blog/{{slug}}/"
- "image": "http://localhost/Global_Salah_New/site/public/assets/images/blog/{{image}}"
- "@id": "http://localhost/Global_Salah_New/site/public/blog/{{slug}}/#faq"
+ "url": "https://globalsalah.com/blog/{{slug}}/"
+ "image": "https://globalsalah.com/assets/images/blog/{{image}}"
+ "@id": "https://globalsalah.com/blog/{{slug}}/#faq"
```

---

## 3. 🔴 Character Encoding Corruption (`` / `?` / `?Ts`)

### 📍 Where Found:
- Breadcrumb structured data (`Special Islamic Days 2026?"2027`)
- Meta descriptions & Schema descriptions (`sun?Ts position`, `today?Ts date`, `the?`)
- Special Islamic Days pages & Duas pages.

### 🔍 Evidence from Live Server:
```json
// From BreadcrumbList Schema on /special-islamic-days/ramadan-2027/
{
  "@type": "ListItem",
  "position": 2,
  "name": "Special Islamic Days 2026?\"2027",
  "item": "https://globalsalah.com/special-islamic-days/"
}

// From BlogPosting Schema
"description": "Prayer timetables are calculated from the sun?Ts position..."
```

### 💥 Impact:
- Google displays corrupted text (like `sun?Ts position` and `Special Islamic Days 2026?"2027`) directly in search engine snippets.
- Damages website credibility and click-through rates (CTR).
- Indicates a text encoder mismatch during static build or CMS database export.

### 🛠️ Actionable Fix:
1. Ensure all source files and database connections use strict **`UTF-8 without BOM`** (or `utf8mb4`).
2. Replace corrupt characters with standard UTF-8 characters or HTML entities:
   - Replace `?Ts` with `'s` (Apostrophe `&#39;` or `&apos;`)
   - Replace `?\"` with `–` (En-dash `&ndash;` or `&#8211;`)
   - Replace `?` with `…` (Ellipsis `&hellip;` or `&#8230;`)

---

## 4. 🔴 Hazardous `<base href="./">` Tag & Relative `./` Link Collisions

### 📍 Where Found:
- In the `<head>` of all 57+ pages:
  `<base href="./"><script>if(location.protocol==="file:")document.querySelector("base").setAttribute("href","./")</script>`
- In navigation menus and footers:
  `href="./blog/"`, `href="./countries/"`, `href="./special-islamic-days/mawlid-al-nabi-2026/"`, `href="./#monthly-prayer-calendar"`.

### 🔍 Evidence & Mechanism of Failure:
When a user or Googlebot visits a sub-page such as `https://globalsalah.com/countries/pakistan/` and clicks a link written as `href="./blog/"`, the browser resolves the link relative to the current directory path:
`https://globalsalah.com/countries/pakistan/blog/` ➡️ **HTTP 404 NOT FOUND!**

Similarly, clicking `./#monthly-prayer-calendar` from a blog post navigates to `https://globalsalah.com/blog/how-to-wake-up-for-fajr/#monthly-prayer-calendar` instead of the homepage prayer table.

### 💥 Impact:
- Broken internal links across the entire site for both humans and search crawlers.
- Causes Googlebot to discover thousands of phantom 404 URLs.
- Breaks browser bookmarking and in-page anchor navigation.

### 🛠️ Actionable Fix:
1. Completely delete `<base href="./">` from the `<head>` of all templates.
2. Standardize all internal links to root-relative paths starting with `/`:
```diff
- <base href="./"><script>if(location.protocol==="file:")document.querySelector("base").setAttribute("href","./")</script>
- <a href="./blog/">Blog</a>
- <a href="./countries/">Countries</a>
- <a href="./#monthly-prayer-calendar">Prayer Calendar</a>
+ <a href="/blog/">Blog</a>
+ <a href="/countries/">Countries</a>
+ <a href="/#monthly-prayer-calendar">Prayer Calendar</a>
```

---

## 5. 🔴 Staging Domain Indexation Leakage

### 📍 Where Found:
`https://crmapi.designstime.com/robots.txt` and `<meta name="robots" content="index,follow">`.

### 🔍 Evidence from Live Server:
```txt
# Live response from https://crmapi.designstime.com/robots.txt
User-agent: *
Allow: /
Disallow: /ad/
Disallow: /secured-panel-ad/
Disallow: /backend/
Disallow: /blog-data/

Sitemap: https://globalsalah.com/sitemap.xml
```

### 💥 Impact:
- While on staging `crmapi.designstime.com`, Googlebot is permitted to crawl and index all pages.
- Staging pages can get indexed under the wrong domain, creating massive **duplicate content** with `globalsalah.com`.
- Staging backend paths `/backend/`, `/secured-panel-ad/` are publicly disclosed in robots.txt.

### 🛠️ Actionable Fix:
1. Put an `X-Robots-Tag: noindex, nofollow` header on the staging server, or enforce HTTP Basic Authentication (`.htpasswd`).
2. Once the domain is switched to `globalsalah.com`, ensure production `robots.txt` is served.
