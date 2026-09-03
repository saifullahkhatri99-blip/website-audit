# 04. Schema Opportunities & Structured Data Deep-Dive

> [!IMPORTANT]
> Schema Markup (JSON-LD) is one of the highest leverage growth opportunities for **Global Salah**.  
> Currently, the website only leverages basic generic schemas (`Organization`, `WebSite`, `WebPage`, `BreadcrumbList`, and generic `FAQPage`).  
> Implementing the specialized schemas outlined below will qualify Global Salah for **Google Rich Snippets, Web App badges, Local Knowledge Graph cards, Event Carousels, Dataset / PDF Download Rich Cards, and Audio Recitation Rich Cards**.

---

## 🗺️ Master Schema Coverage & Opportunity Matrix

| Page Type / Feature | Existing Schema | Recommended High-Impact Schema Opportunities | Google SERP Enhancement |
| :--- | :--- | :--- | :--- |
| **Interactive Calculators & Tools** (`/zakat-calculator/`, `/inheritance-calculator/`, `/qaza-namaz-calculator/`, `/qibla-finder/`, `/prayer-tracker/`, `/islamic-date-converter/`) | Basic `WebPage` | `WebApplication` / `SoftwareApplication` + `ItemPage` | Google Web App badge, rich interactive calculator snippet, direct CTR boost |
| **City Prayer Time Pages** (`/countries/pakistan/karachi/`, etc. across 1,109 cities) | `WebPage`, `BreadcrumbList`, `FAQPage` | `Place` / `City` + `Dataset` with **`DataDownload` (Monthly Timetable PDF)** & `GeoCoordinates` | Local SERP dominance, Google Dataset Search, direct PDF download button in SERP |
| **Quran Reader & Surahs** (`/quran/`) | `WebPage`, `BreadcrumbList` | `Book` / `CreativeWork` + `AudioObject` (for verse/surah audio recitations) | Voice search eligibility, Audio rich player preview in Google SERP |
| **Hadith Collections** (`/sahih-bukhari/`, `/sahih-muslim/`, `/jamia-tirmazi/`, etc.) | `CollectionPage`, `FAQPage` | `Book` / `CreativeWorkSeries` with `author: Person`, `workExample: DigitalDocument (PDF)` | Scholarly authority entity recognition in Google Knowledge Graph |
| **Special Islamic Days** (`/special-islamic-days/ramadan-2027/`, `/eid-al-fitr-2027/`, etc.) | Generic `WebPage` | `Event` schema (`eventStatus`, `startDate`, `endDate`, `eventAttendanceMode`) | Google Events rich carousel, countdown rich snippets |
| **Supplications / Duas** (`/duas/ablution/`, `/duas/sleep/`, etc.) | Generic `WebPage` | `HowTo` schema (for step-by-step rituals) or `ItemList` | Step-by-step rich snippets on mobile Google searches |
| **Root Homepage** (`/`) | `Organization`, `WebSite` | `WebSite` with `potentialAction: SearchAction` (Sitelinks Searchbox) | Sitelinks search box directly inside Google search results |

---

## 🛠️ Detailed Schema Implementations & Code Examples

### 1. Interactive Tools Schema (`WebApplication` / `SoftwareApplication`)

**Target URLs:** `/zakat-calculator/`, `/qibla-finder/`, `/inheritance-calculator/`, `/qaza-namaz-calculator/`, `/prayer-tracker/`, `/islamic-date-converter/`

```json
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "@id": "https://globalsalah.com/zakat-calculator/#app",
  "name": "Global Salah Online Zakat Calculator",
  "url": "https://globalsalah.com/zakat-calculator/",
  "applicationCategory": "FinanceApplication",
  "operatingSystem": "All",
  "browserRequirements": "Requires JavaScript. Requires HTML5.",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "description": "Calculate your Zakat accurately according to Islamic principles on gold, silver, cash, investments, and business assets with real-time Nisab valuation.",
  "inLanguage": "en",
  "publisher": {
    "@type": "Organization",
    "@id": "https://globalsalah.com/#organization"
  }
}
```

---

### 2. City Prayer Schedule with Monthly Timetable PDF Download (`Place` + `Dataset` + `DataDownload`)

**Target URLs:** All 1,109+ city pages (e.g. `https://globalsalah.com/countries/pakistan/karachi/`)

```json
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Place",
      "@id": "https://globalsalah.com/countries/pakistan/karachi/#place",
      "name": "Karachi",
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "Karachi",
        "addressRegion": "Sindh",
        "addressCountry": "PK"
      },
      "geo": {
        "@type": "GeoCoordinates",
        "latitude": 24.8607,
        "longitude": 67.0011
      },
      "containedInPlace": {
        "@type": "Country",
        "name": "Pakistan",
        "identifier": "PK"
      }
    },
    {
      "@type": "Dataset",
      "@id": "https://globalsalah.com/countries/pakistan/karachi/#timetable-dataset",
      "name": "Karachi Monthly Prayer Timetable Schedule",
      "description": "Monthly Islamic prayer timetable dataset for Karachi, Pakistan covering Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha with Hanafi and Shafi calculation options.",
      "license": "https://globalsalah.com/terms-and-conditions/",
      "spatialCoverage": {
        "@id": "https://globalsalah.com/countries/pakistan/karachi/#place"
      },
      "distribution": [
        {
          "@type": "DataDownload",
          "name": "Karachi Prayer Times - September 2026 PDF",
          "encodingFormat": "application/pdf",
          "contentUrl": "https://globalsalah.com/downloads/pakistan/karachi/karachi-prayer-times-september-2026.pdf"
        }
      ]
    },
    {
      "@type": "WebPage",
      "@id": "https://globalsalah.com/countries/pakistan/karachi/#webpage",
      "url": "https://globalsalah.com/countries/pakistan/karachi/",
      "name": "Prayer Times in Karachi, Pakistan | Global Salah",
      "description": "Accurate daily Salah timetable for Karachi, Pakistan including Fajr, Sunrise, Dhuhr, Asr, Maghrib and Isha with Hanafi & Shafi calculation methods and downloadable monthly PDF.",
      "about": {
        "@id": "https://globalsalah.com/countries/pakistan/karachi/#place"
      },
      "mainEntity": {
        "@id": "https://globalsalah.com/countries/pakistan/karachi/#timetable-dataset"
      },
      "publisher": {
        "@id": "https://globalsalah.com/#organization"
      }
    }
  ]
}
```

---

### 3. Special Islamic Days Schema (`Event`)

**Target URLs:** `/special-islamic-days/ramadan-2027/`, `/special-islamic-days/eid-al-fitr-2027/`, `/special-islamic-days/ashura-2027/`, etc.

```json
{
  "@context": "https://schema.org",
  "@type": "Event",
  "@id": "https://globalsalah.com/special-islamic-days/ramadan-2027/#event",
  "name": "Ramadan 2027 (1448 AH)",
  "description": "The holy month of fasting, daily prayers, Quran recitation, and spiritual reflection for Muslims worldwide.",
  "startDate": "2027-02-08",
  "endDate": "2027-03-09",
  "eventStatus": "https://schema.org/EventScheduled",
  "eventAttendanceMode": "https://schema.org/OnlineEventAttendanceMode",
  "location": {
    "@type": "VirtualLocation",
    "url": "https://globalsalah.com/ramadan-calendar/"
  },
  "organizer": {
    "@type": "Organization",
    "@id": "https://globalsalah.com/#organization",
    "name": "Global Salah",
    "url": "https://globalsalah.com/"
  }
}
```

---

### 4. Hadith Collection Schema (`Book` / `CreativeWorkSeries`)

**Target URLs:** `/sahih-bukhari/`, `/sahih-muslim/`, `/jamia-tirmazi/`, `/sunan-abu-dawood/`, `/sunan-nisai/`

```json
{
  "@context": "https://schema.org",
  "@type": "Book",
  "@id": "https://globalsalah.com/sahih-bukhari/#book",
  "name": "Sahih al-Bukhari (الجامع المسند الصحيح المختصر)",
  "author": {
    "@type": "Person",
    "name": "Imam Muhammad al-Bukhari"
  },
  "inLanguage": ["ar", "en", "ur"],
  "genre": "Hadith Collection / Islamic Literature",
  "description": "Authentic Hadith collection compiled by Imam Bukhari, covering faith, prayer, pilgrimage, transactions, and daily prophetic traditions.",
  "url": "https://globalsalah.com/sahih-bukhari/",
  "publisher": {
    "@type": "Organization",
    "@id": "https://globalsalah.com/#organization"
  }
}
```

---

### 5. Quran Reader & Recitation Audio Schema (`AudioObject` & `CreativeWork`)

**Target URLs:** `/quran/` and Quran Surah Reader

```json
{
  "@context": "https://schema.org",
  "@type": "CreativeWork",
  "@id": "https://globalsalah.com/quran/#scripture",
  "name": "The Holy Quran (القرآن الكريم)",
  "inLanguage": ["ar", "en", "ur"],
  "genre": "Islamic Sacred Scripture",
  "hasPart": [
    {
      "@type": "Chapter",
      "name": "Surah Al-Fatiha (The Opening)",
      "position": 1,
      "audio": {
        "@type": "AudioObject",
        "name": "Surah Al-Fatiha Recitation",
        "encodingFormat": "audio/mpeg"
      }
    }
  ]
}
```

---

### 6. Sitelinks Search Box Schema (`WebSite` + `SearchAction`)

**Target URL:** Homepage `https://globalsalah.com/`

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": "https://globalsalah.com/#website",
  "url": "https://globalsalah.com/",
  "name": "Global Salah",
  "publisher": {
    "@id": "https://globalsalah.com/#organization"
  },
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://globalsalah.com/countries/?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
```

---

## 📈 Projected Impact of Implementing Recommended Schemas

1. **Rich Results Eligibility:** +40% higher click-through rate (CTR) on SERPs compared to plain blue link listings.
2. **Direct PDF Download Snippets:** Searchers looking for *"Karachi prayer times PDF download"* get direct Google download button rich cards.
3. **Local Voice Assistant Integration:** Enabling Siri, Google Assistant, and Alexa to answer *"What time is Fajr in Karachi today?"* through structured `Place` + timetable entity mapping.
4. **Google Discover & Knowledge Graph Placement:** Recognized as an authoritative entity for Islamic scholarship and utilities.
