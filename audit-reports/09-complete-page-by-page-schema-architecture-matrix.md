# 09. Page-by-Page Schema Architecture & Implementation Matrix

This guide provides a comprehensive mapping of every single page type and template across **Global Salah**, detailing exactly how many schemas and which specific Schema.org types must be included on each page.

---

## 🗺️ Master Page-by-Page Schema Mapping Table

| # | Page Category / URL Pattern | Sample Pages | Total Schemas | Exact Schema Types Required in `@graph` | Google SERP Rich Features Unlocked |
| :-: | :--- | :--- | :-: | :--- | :--- |
| **1** | **City Prayer Pages**<br>`/countries/{country}/{city}/` | `/countries/pakistan/karachi/`<br>`/countries/saudi-arabia/mecca/`<br>`/countries/united-states/new-york/` | **8 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `Place` (with `GeoCoordinates`)<br>4. `WebPage`<br>5. `BreadcrumbList`<br>6. `ItemList` (`#today-prayer-times`)<br>7. `Dataset` (`#monthly-prayer-times`)<br>8. `DataDownload` (PDF) + `FAQPage` | • Direct Prayer Times Rich Cards<br>• Download Monthly PDF Button<br>• Google Assistant / Voice Search Answers<br>• Local SEO Dominance |
| **2** | **Country Hub Pages**<br>`/countries/{country}/` | `/countries/pakistan/`<br>`/countries/saudi-arabia/`<br>`/countries/united-kingdom/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `Place` / `Country`<br>4. `CollectionPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • Country City Directory Carousel<br>• Breadcrumb Trail in SERP |
| **3** | **Global Countries Hub**<br>`/countries/` | `/countries/` | **4 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `CollectionPage`<br>4. `BreadcrumbList` | • Clean Site Directory Structure |
| **4** | **Homepage**<br>`/` | `https://globalsalah.com/` | **4 Schemas** | 1. `Organization` (with `sameAs` social links)<br>2. `WebSite` (with `SearchAction`)<br>3. `WebPage`<br>4. `FAQPage` | • **Google Sitelinks Searchbox**<br>• Knowledge Graph Brand Panel |
| **5** | **Interactive Calculators & Tools**<br>`/{tool-name}/` | `/zakat-calculator/`<br>`/inheritance-calculator/`<br>`/qaza-namaz-calculator/`<br>`/prayer-tracker/`<br>`/islamic-date-converter/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `WebApplication` / `SoftwareApplication`<br>4. `WebPage` / `ItemPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • **Google Web App Rich Badge**<br>• Interactive Calculation Card<br>• High CTR Tool Snippet |
| **6** | **Qibla Finder & Compass**<br>`/qibla-finder/` | `/qibla-finder/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `WebApplication` (`applicationCategory: UtilitiesApplication`)<br>4. `WebPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • Interactive Qibla Tool Badge<br>• Geolocation GPS Feature Highlight |
| **7** | **Quran Reader & Surah Pages**<br>`/quran/`<br>`/quran/{surah}/` | `/quran/`<br>`/quran/surah-al-fatiha/`<br>`/quran/surah-al-baqarah/` | **6 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `CreativeWork` (The Holy Quran)<br>4. `Chapter` (Surah Number & Name)<br>5. `AudioObject` (MP3 Recitation Stream)<br>6. `BreadcrumbList` + `WebPage` | • Audio Recitation Playable Snippet<br>• Sacred Text Knowledge Graph Entity |
| **8** | **Hadith Collections**<br>`/{hadith-book}/` | `/sahih-bukhari/`<br>`/sahih-muslim/`<br>`/jamia-tirmazi/`<br>`/sunan-abu-dawood/`<br>`/sunan-nisai/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `Book` / `CreativeWorkSeries` (`author: Person`)<br>4. `CollectionPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • Islamic Scholarly Book Entity<br>• Author Knowledge Graph Linking |
| **9** | **Special Islamic Days & Ramadan**<br>`/special-islamic-days/{event}/`<br>`/ramadan-calendar/` | `/special-islamic-days/ramadan-2027/`<br>`/special-islamic-days/eid-al-fitr-2027/`<br>`/ramadan-calendar/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `Event` (`startDate`, `endDate`, `eventStatus`)<br>4. `WebPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • **Google Events Rich Carousel**<br>• Ramadan / Eid Countdown Snippet |
| **10** | **Duas Collection**<br>`/duas/`<br>`/duas/{category}/` | `/duas/`<br>`/duas/ablution/`<br>`/duas/sleep/`<br>`/duas/eating/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `HowTo` / `ItemList` (Step-by-step recitation)<br>4. `WebPage`<br>5. `BreadcrumbList`<br>6. `FAQPage` | • Step-by-Step Supplication Cards<br>• Rich FAQ Expanders |
| **11** | **Blog Articles & Guides**<br>`/blog/{slug}/` | `/blog/how-prayer-times-are-calculated/`<br>`/blog/how-to-wake-up-for-fajr/` | **5 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `BlogPosting` / `Article` (`headline`, `image`, `datePublished`)<br>4. `BreadcrumbList`<br>5. `FAQPage` | • Google Discover Feature Eligibility<br>• Google News / Article Rich Card |
| **12** | **Static & Legal Pages**<br>`/about-us/`<br>`/contact-us/`<br>`/privacy-policy/` | `/about-us/`<br>`/contact-us/`<br>`/privacy-policy/`<br>`/terms-and-conditions/` | **4 Schemas** | 1. `Organization`<br>2. `WebSite`<br>3. `WebPage` (`AboutPage` / `ContactPage`)<br>4. `BreadcrumbList` | • Clean Site Identity & E-E-A-T Trust |

---

## 🧪 How to Test in Google Rich Results Tool

1. Open **[Google Rich Results Test](https://search.google.com/test/rich-results)** in your browser.
2. Select the **`CODE`** tab (instead of URL).
3. Copy the entire contents of [`schemas-library/ready-for-google-rich-results-test.json`](../schemas-library/ready-for-google-rich-results-test.json).
4. Paste and click **"TEST CODE"**.
5. You will see green validation ticks for:
   - ✅ **Dataset** (Monthly Timetable & PDF Download)
   - ✅ **Breadcrumbs**
   - ✅ **FAQPage**
   - ✅ **Sitelinks Searchbox**
   - ✅ **Place & ItemList**
