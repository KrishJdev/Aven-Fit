# Aven Fit ⚡

> **High-Performance, Offline-First Workout Tracker & Nutrition Engine**  
> Engineered for speed, precision, and sharp glassmorphism clarity on Android.

---

[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-ED8B00?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![SQLite](https://img.shields.io/badge/SQLite-Offline--First-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![License](https://img.shields.io/badge/License-MIT-black)](#)

---

## 🎯 Overview

**Aven Fit** is an athletic, technical, and distraction-free fitness tracking application designed to eliminate friction in the gym. Built with an **offline-first** architecture and high-contrast editorial aesthetics, Aven Fit ensures that logging a set takes **less than 3 seconds**, even without internet connectivity.

---

## ✨ Key Features

### 🏋️‍♂️ 1. Workout & Routine Logging
- **Ultra-Fast Set Logging (<3s):** 1-tap logging with previous workout history pre-fill (`PREV`), weight, reps, RPE, and set classifications (`WARMUP`, `NORMAL`, `DROP`, `FAILURE`).
- **Custom Routine Builder:** Create, organize, and re-order workout routines with pre-configured targets and rest intervals.
- **200+ Exercise Library:** Comprehensive directory of compound and isolation movements tagged by primary and secondary muscle groups.
- **Custom Exercises:** Add bespoke movements with equipment and muscle group assignments.

### ⏱️ 2. Rest Timer & Background Notifications
- **Automatic Rest Timer:** Triggers seamlessly upon logging a set with per-exercise interval memory.
- **Quick Controls:** `+30s`, `-30s`, `Skip`, and instant background countdown alerts.

### 📊 3. Analytics & Personal Record (PR) Vault
- **Automatic PR Detection:** Real-time celebration and ledger recording for `MAX_WEIGHT`, `MAX_REPS`, and `EST_1RM` (calculated via Brzycki formula).
- **Progress Tracking:** Interactive historical progression charts, consistency streaks, and muscle volume analytics.

### 🍎 4. Indian Nutrition & Macro Engine
- **Curated Food Database:** Tailored specifically for Indian dietary habits (Roti, Dal, Paneer Tikka, Chicken Curry, Oats, Rice, etc.) alongside international staples.
- **Regional Serving Units:** Track intake accurately using standard units (`katori`, `roti`, `scoop`, `grams`, `bowl`).
- **High-Density Macro Ledgers:** Real-time tracking of calories, protein, carbohydrates, and fats.

### 🔄 5. Offline-First Architecture & Cloud Sync
- **Local-First Speed:** Instant local reads and writes powered by high-performance SQLite.
- **Background Sync Engine:** Automatic change queueing (`sync_queue`) with conflict resolution and bi-directional server synchronization when connectivity is restored.

---

## 🛠️ Technology Stack

| Layer | Technology | Description |
|:---|:---|:---|
| **Mobile Client** | Flutter + Dart | High-performance Android application with Sharp Glassmorphism UI |
| **State Management** | Riverpod | Reactive state management and dependency injection |
| **Local Database** | SQLite (`sqflite`) | High-speed native bindings for offline persistence |
| **Backend API** | Spring Boot 3.3 + Java 21 | Modular REST architecture with clean domain separation |
| **Security & Auth** | Spring Security + JWT | Phone OTP and OAuth token rotation |
| **Server Database** | PostgreSQL 16 + Flyway | Scalable relational storage with version-controlled migrations |

---

## 📁 Repository Structure

```
aven-fit/
├── mobile/                      # Flutter Android application
│   ├── android/                 # Native Android project files
│   ├── lib/
│   │   ├── components/          # Reusable UI primitives & feature components
│   │   ├── database/            # SQLite schema, migrations & local repositories
│   │   ├── navigation/          # Router and navigation setup
│   │   ├── screens/             # Today, Train, Workout, Nutrition, Progress
│   │   ├── services/            # API clients & background SyncEngine
│   │   ├── providers/           # Riverpod state providers
│   │   └── theme/               # Sharp Glassmorphism design system, typography & palette
│   └── main.dart                # Application entry & initialization
│
└── backend/                     # Spring Boot application
    ├── src/main/java/com/avenfit/
    │   ├── auth/                # Security, JWT & OTP services
    │   ├── exercise/            # Exercise & muscle group domain
    │   ├── workout/             # Live workout & set logging services
    │   ├── routine/             # Routine templates & sets
    │   ├── nutrition/           # Food items & meal logging
    │   ├── analytics/           # PR tracking & volume summaries
    │   └── sync/                # Push/pull synchronization controllers
    └── src/main/resources/
        └── db/migration/        # Flyway schema migrations (V1–V10)
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: `v3.24+`
- **JDK**: `Java 21`
- **Android Studio**: Android SDK & Android 14/15 Virtual Device (Pixel 8 recommended)
- **PostgreSQL**: `v16+` (for backend development)

---

### 📱 Mobile Setup (Flutter)

1. **Navigate to the mobile directory:**
   ```bash
   cd mobile
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure local Android SDK path:**  
   Create `mobile/android/local.properties` (if not already present):
   ```properties
   sdk.dir=C\:\\Users\\<YourUsername>\\AppData\\Local\\Android\\Sdk
   ```

4. **Launch on Android Emulator / Device:**
   ```bash
   flutter run
   ```

---

### ☕ Backend Setup (Spring Boot)

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Setup PostgreSQL Database:**
   ```sql
   CREATE USER avenfit WITH PASSWORD 'avenfit_dev_password';
   CREATE DATABASE avenfit_dev OWNER avenfit;
   GRANT ALL PRIVILEGES ON DATABASE avenfit_dev TO avenfit;
   ```

3. **Build and Run:**
   ```bash
   ./gradlew bootRun
   ```
   *Flyway will automatically execute database migrations upon startup.*

---

## 🎨 Design Philosophy

Aven Fit adheres to a **Sharp Glassmorphism** design language:
- **OLED Surface & Translucency:** Pitch-black background with translucent glass cards and crisp, precise edges.
- **High-Contrast Palette:** Neon Cyan (`#00F0FF`) primary accent, Volt Green (`#E2F835`) for PRs/deltas, and Burnt Orange (`#E85D04`) for warnings/destructive actions.
- **Dense, Technical Typography:** Monospaced tabular numerical alignment for effortless set scanning.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).