# Smart Crops (Agri Lynk) - Comprehensive Project Planning & Handoff Document

## 1. Executive Summary & Product Vision
**Smart Crops** (by *Agri Lynk*) is an AI-powered digital crop monitoring and early disease detection mobile application designed for farmers across Android and iOS. Built with **Flutter** (frontend) and **Supabase** (backend), the system enables farmers to snap or upload photos of crops, instantly identify pests and diseases using a managed pool of AI model API keys (ChatGPT/Gemini vision), track farm health, receive tailored recommendations, and maintain a complete historical log of farm interventions—all while operating on a **0-cost infrastructure tier** for initial deployment and bootstrapping.

---

## 2. SDLC & Development Methodology
- **Methodology:** Agile Scrum with 2-week iterative sprints.
- **Development Lifecycle Stages:**
  1. *Inception & Planning:* Requirements gathering, UI/UX refinement (PDF workflows), ERD & DFD design.
  2. *MVP Development (Sprint 1–3):* Supabase core schema setup, Flutter project scaffolding, Auth (Google, Facebook, Email, Phone/OTP), Profile creation with multiple crop selection.
  3. *Core Feature Implementation (Sprint 4–6):* Scan Crop module, Multi-API key rotation engine for AI vision, My Crops management, History logging, Recommendations engine.
  4. *Testing & QA (Sprint 7):* Unit testing, widget testing (Flutter TDD), RLS security audits (Supabase).
  5. *Deployment & Soft Launch (Sprint 8):* Play Store & App Store release, monitoring 0-cost resource quotas.
  6. *Monetization & Scaling (Phase 2):* Freemium tiers, sponsored agricultural product recommendations, enterprise/cooperative management.

---

## 3. Stacks & Technology Architecture (0-Cost Approach)

| Layer | Technology | Purpose & 0-Cost Strategy |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Cross-platform mobile app (Android & iOS) with a single codebase. Native camera & storage plugins. |
| **Backend & DB** | Supabase (PostgreSQL) | Managed Postgres database, Row Level Security (RLS), real-time subscriptions, and auto-generated REST/GraphQL APIs (Free Tier: up to 500MB DB, 2GB bandwidth, 50k monthly active users). |
| **Authentication** | Supabase Auth | Email/Password, OAuth (Google, Facebook), and SMS/Phone OTP authentication. |
| **Storage** | Supabase Storage | Secure storage buckets for user avatars and crop scan images (Free Tier: 1GB storage). |
| **AI Vision & Scanning** | Multi-API Key Pool (OpenAI GPT-4o / Google Gemini Flash) | Rotational key pool managed via Supabase Edge Functions to distribute free-tier or low-cost API quotas across users without incurring single-key rate limits or high costs. |
| **Hosting & CI/CD** | GitHub Actions + Supabase Edge Functions | Automated testing, builds, and serverless logic running at zero cost. |

---

## 4. MVP First Approach & Phased Roadmap

| Phase | Scope & Features | Timeline | Cost / Infrastructure |
| :--- | :--- | :--- | :--- |
| **Phase 1: MVP (Minimum Viable Product)** | • Onboarding & Auth (Google, Facebook, Email, Phone)<br>• Profile & Multiple Crop Selection (Page 4 & 5)<br>• Dashboard Home & Weather Widget (Page 6)<br>• Scan Crop with Multi-API Key AI Fallback & Analysis<br>• History log of past scans & Notification Bell with recent scan feedback<br>• Basic "My Crops" and "Recommendations" views | Weeks 1–4 | **$0 / month** (Supabase Free Tier + Free/Trial AI API Keys) |
| **Phase 2: Growth & Enhancement** | • Push notifications (FCM / Supabase Realtime)<br>• Enhanced offline caching (Hive / Isar)<br>• Localized language support (Tagalog, Cebuano, English, etc.)<br>• Advanced crop growth timeline tracker | Weeks 5–6 | **$0 / month** |
| **Phase 3: Monetization & Scale** | • Premium subscription tier (unlimited AI scans, priority queue)<br>• Agri-marketplace affiliate integration (fertilizers, seeds, pesticides recommendation links)<br>• Cooperative / Enterprise dashboard | Weeks 7–8+ | **Revenue Generating** (Self-sustaining) |

---

## 5. Data Flow Diagram (DFD)

### Level 0 DFD (Context Diagram)
- **External Entities:** Farmer (User), AI Vision Providers (OpenAI/Gemini API key pool), Supabase Auth Provider.
- **System:** Smart Crops Mobile App & Backend.
- **Data Flow:**
  - Farmer provides Credentials/Phone/OAuth $\rightarrow$ Auth verification $\rightarrow$ Token returned.
  - Farmer selects Main Crops & Profile info $\rightarrow$ Stored in Supabase Database.
  - Farmer captures/uploads Crop Image $\rightarrow$ App routes image + prompt to Supabase Edge Function $\rightarrow$ Edge Function selects available API key from Pool $\rightarrow$ AI Provider analyzes image $\rightarrow$ Disease diagnosis & recommendations returned $\rightarrow$ Saved to `scan_history` $\rightarrow$ Displayed in App & Notification Bell.

### Level 1 DFD (Detailed Process Flow)
1. **1.0 User Management & Profile:**
   - User signs in via Email, Phone/OTP, Google, or Facebook.
   - Profile completion: Enters Name, Farm Location, and selects **Multiple Main Crops**. Data stored in `profiles` and `user_crops`.
2. **2.0 Dashboard & Weather Feed:**
   - App fetches local weather based on farm location (via lightweight weather API) and displays dashboard widgets: Weather, My Crops, Recommendations, History, Notification Bell.
3. **3.0 Crop Scanning & AI Analysis Engine:**
   - User initiates **Scan Crop** (camera/gallery).
   - Image uploaded to Supabase Storage.
   - Supabase Edge Function triggers API Key Rotator: checks remaining rate limits across stored keys in `api_keys_pool`, sends image to active AI model (GPT-4o/Gemini), parses structured JSON diagnosis (Disease Name, Confidence %, Recommended Actions).
   - Result is logged in `scan_history` table, triggering an in-app notification in `notifications`.
4. **4.0 History & Recommendations Retrieval:**
   - User clicks Notification Bell or History tab $\rightarrow$ Views chronological list of scan results, disease confidence scores, and tailored care recommendations.

---

## 6. Entity Relationship Diagram (ERD) & Database Schema

### Core Tables & Relations (PostgreSQL / Supabase)

1. **`profiles`**
   - `id` (UUID, Primary Key, references `auth.users`)
   - `full_name` (Text)
   - `email` (Text)
   - `phone_number` (Text)
   - `farm_name` (Text)
   - `location` (Text)
   - `created_at` (Timestamp)

2. **`crops`** (Master list of crops supported by the app)
   - `id` (UUID, Primary Key)
   - `crop_name` (Text - e.g., Pechay, Tomato, Rice)
   - `optimal_conditions` (JSONB)

3. **`user_crops`** (Many-to-Many relation for user's selected Main Crops)
   - `id` (UUID, Primary Key)
   - `user_id` (UUID, Foreign Key to `profiles.id`)
   - `crop_id` (UUID, Foreign Key to `crops.id`)
   - `added_at` (Timestamp)

4. **`scan_history`**
   - `id` (UUID, Primary Key)
   - `user_id` (UUID, Foreign Key to `profiles.id`)
   - `image_url` (Text)
   - `disease_detected` (Text)
   - `confidence_score` (Numeric)
   - `common_crop` (Text)
   - `recommended_actions` (JSONB array)
   - `scanned_at` (Timestamp)

5. **`notifications`**
   - `id` (UUID, Primary Key)
   - `user_id` (UUID, Foreign Key to `profiles.id`)
   - `title` (Text)
   - `message` (Text)
   - `scan_id` (UUID, Foreign Key to `scan_history.id`, nullable)
   - `is_read` (Boolean, default `false`)
   - `created_at` (Timestamp)

6. **`ai_keys_pool`** (For managing multiple free/trial API keys securely in backend)
   - `id` (UUID, Primary Key)
   - `provider` (Text - e.g., OpenAI, Gemini)
   - `api_key_encrypted` (Text)
   - `daily_quota_limit` (Integer)
   - `current_usage_count` (Integer)
   - `is_active` (Boolean)

---

## 7. UI/UX Workflow & Screen Specifications

- **Page 1–3: Onboarding & Splash**
  - App intro, value proposition ("Detect Early. Protect Your Harvest.").
- **Page 4: Authentication (Login / Sign Up)**
  - Options: **Continue with Google**, **Continue with Facebook**, **Sign Up with Email**, and newly added **Phone / Mobile Number (with OTP verification)**.
- **Page 5: Create Your Profile & Select Main Crops**
  - Form fields: Full Name, Email/Phone, Password, Farm Name, Location.
  - **Crop Information Section:** Interactive **multiple selection** picker allowing farmers to choose their Main Crops (e.g., Pechay, Corn, Rice, Tomato) to personalize recommendations and disease detection models.
- **Page 6: Main Dashboard ("Start Using Smart Crops")**
  - **Header / Upper-Right:** Notification Bell with badge count (displays brief info for recent scan results; tapping redirects directly to `History -> Selected Scan Crop Review`).
  - **Weather Widget:** Current temperature, weather conditions, and farm location.
  - **Core Grid Buttons:**
    1. **Scan Crop:** Opens camera/upload interface for instant disease detection.
    2. **My Crops:** Detailed information card/view for all user-selected main crops (growth stages, care guides).
    3. **Recommendations:** Tailored care tips, preventive pest management, and best practices based on user's crops and scan history.
    4. **History:** Chronological log of all past Scan Crop interactions and diagnoses (replacing the generic alert container).

---

## 8. Entrepreneurial Strategy & Monetization Streams (0-Cost Startup)

1. **Freemium Scan Quota:**
   - Free tier provides X free AI scans per day/week (powered by the rotated multi-API key pool).
   - Premium tier (subscription) unlocks unlimited instant scans, advanced crop health analytics, and priority queueing during peak farming seasons.
2. **Affiliate & Marketplace Partnerships:**
   - When the AI recommends specific treatments or organic pesticides, embed direct affiliate links or local merchant storefronts (e.g., agricultural supply shops) earning commissions on recommended products.
3. **Data Insights for Cooperatives (B2B):**
   - Provide anonymized, aggregated regional pest outbreak data to agricultural cooperatives or government extension offices as a subscription or partnership service.

---

## 9. Mind Map / App Navigation Route

```text
Smart Crops App
│
├── Auth Flow
│   ├── Login / Sign Up (Google, Facebook, Email, Phone/OTP)
│   └── Profile Setup & Multiple Crop Selection (Page 5)
│
├── Main Dashboard (Home - Page 6)
│   ├── Notification Bell (Recent Scans & Reminders ➔ History Detail)
│   ├── Weather Widget
│   │
│   ├── 1. Scan Crop Flow
│   │   ├── Camera / Gallery Upload
│   │   ├── Edge Function (API Key Rotator)
│   │   └── Scan Result & Recommended Actions ➔ Saved to History
│   │
│   ├── 2. My Crops
│   │   └── Detailed Crop Information & Growth Guides
│   │
│   ├── 3. Recommendations
│   │   └── Tailored Care Tips & Pest Prevention
│   │
│   └── 4. History
│       └── Chronological Log of All Past Scan Interactions & Reviews
│
└── Settings & Profile Management
```
