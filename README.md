# RideNest — Ride-Sharing Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-4.1.1-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-Geo-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![WebSockets](https://img.shields.io/badge/STOMP-WebSockets-010101?style=for-the-badge&logo=socketdotio&logoColor=white)](https://stomp.github.io/)
[![Google Maps](https://img.shields.io/badge/Google_Maps-Platform-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)](https://cloud.google.com/maps-platform)

A full-stack ride-sharing platform engineered with **Flutter**, **Spring Boot**, **PostgreSQL**, **Redis Geospatial Indexing**, and **STOMP WebSockets**. RideNest provides a dual-application experience — a streamlined **Rider App** for passengers and an optimized **Driver Partner App** for drivers — coordinated in real time with sub-second dispatching, authoritative GPS telemetry, and zero artificial mock data.

> 📖 **Architectural Details**: For class structures, sequence diagrams, and module hierarchies, refer to [structure.md](structure.md).

---

## 🌟 Key Highlights

- **⚡ Real-Time STOMP Dispatch Engine**: Ultra-low-latency bidirectional trip negotiation over WebSockets with 15-second timed dispatch offers and automated cascading fallbacks.
- **📍 Live GPS Telemetry & Geospatial Matching**: Redis `GEOADD` and `GEORADIUS` algorithms match riders to nearby active drivers within configurable kilometer radiuses.
- **🛡️ 150m Proximity Geofencing**: Strict server and client-side geofence boundaries prevent premature arrival triggers, with manual fallback handling for urban GPS drift.
- **🗺️ Interactive Map Address Picker & Local Caching**: Riders can select pickup locations via address search or interactive map drag-and-pin, with offline persistent caching.
- **💳 Authoritative Fare Engine**: Transparent price calculations based on distance, duration, vehicle tier (Bike Moto, Fastest, Economy), and real surge bonuses.
- **✅ Zero Mock Data Policy**: All distances, ETAs, fares, ratings, and driver shifts derive from authoritative GPS coordinates and backend databases.

---

## 📱 Visual Showcase

### 1. Rider Mobile Application

Complete end-to-end passenger journey from onboarding to destination dropoff.

| 01. Welcome & Splash | 02. Login | 03. Account Registration |
|:---:|:---:|:---:|
| <img src="screenshots/rider_app/00_rider_splash.jpeg" width="260" alt="Rider Splash" /> | <img src="screenshots/rider_app/01_rider_login.jpeg" width="260" alt="Rider Login" /> | <img src="screenshots/rider_app/02_rider_register.jpeg" width="260" alt="Rider Register" /> |
| **Branded Splash**<br/>Fast initialization & version verification | **OTP / Password Login**<br/>Phone number authentication | **Rider Onboarding**<br/>Account setup with Terms & Privacy |

| 04. Home & Search | 05. Vehicle & Fare Selection | 06. Finding Nearby Driver |
|:---:|:---:|:---:|
| <img src="screenshots/rider_app/03_rider_home.jpeg" width="260" alt="Rider Home" /> | <img src="screenshots/rider_app/04_rider_select_ride.jpeg" width="260" alt="Select Ride" /> | <img src="screenshots/rider_app/05_rider_finding_driver.jpeg" width="260" alt="Finding Driver" /> |
| **Dashboard**<br/>Persistent pickup location & recents | **Fare Estimator**<br/>Route polylines & vehicle categories | **Radar Match**<br/>Real-time pulsing geospatial search |

| 07. Driver On The Way | 08. Driver Arrived | 09. Trip In Progress |
|:---:|:---:|:---:|
| <img src="screenshots/rider_app/06_rider_driver_on_the_way.jpeg" width="260" alt="Driver On The Way" /> | <img src="screenshots/rider_app/07_rider_driver_arrived.jpeg" width="260" alt="Driver Arrived" /> | <img src="screenshots/rider_app/08_rider_trip_in_progress.jpeg" width="260" alt="Trip In Progress" /> |
| **En Route Tracking**<br/>Driver vehicle specs & live ETA | **Pickup Alert**<br/>Driver arrived at pickup notification | **Live Navigation**<br/>Heading to destination & trip sharing |

| 10. Ride Completed | 11. Ride History | 12. Profile & Settings |
|:---:|:---:|:---:|
| <img src="screenshots/rider_app/09_rider_trip_completed.jpeg" width="260" alt="Ride Completed" /> | <img src="screenshots/rider_app/10_rider_ride_history.jpeg" width="260" alt="Ride History" /> | <img src="screenshots/rider_app/11_rider_profile.jpeg" width="260" alt="Rider Profile" /> |
| **Trip Receipt**<br/>Cash settlement | **Past Journeys**<br/>Detailed filters & trip breakdown | **Preferences**<br/>Safety guidelines & account controls |

---

### 2. Driver Partner Mobile Application

Built for professional drivers with high-contrast UI, shift management, and safe driving ergonomics.

| 01. Driver Partner Portal | 02. Partner Login | 03. Partner Registration |
|:---:|:---:|:---:|
| <img src="screenshots/driver_app/00_driver_splash.jpeg" width="260" alt="Driver Splash" /> | <img src="screenshots/driver_app/01_driver_login.jpeg" width="260" alt="Driver Login" /> | <img src="screenshots/driver_app/02_driver_register.jpeg" width="260" alt="Driver Register" /> |
| **RideNest PRO**<br/>Dedicated driver partner gateway | **Portal Access**<br/>Secure phone credentials | **Driver Onboarding**<br/>Signup & Vehicle setup |

| 04. Fleet & Vehicles | 05. Online Shift Dashboard | 06. Incoming Dispatch Offer |
|:---:|:---:|:---:|
| <img src="screenshots/driver_app/03_driver_my_vehicles.jpeg" width="260" alt="My Vehicles" /> | <img src="screenshots/driver_app/04_driver_home_online.jpeg" width="260" alt="Driver Online" /> | <img src="screenshots/driver_app/05_driver_dispatch_offer.jpeg" width="260" alt="Dispatch Offer" /> |
| **Vehicle Management**<br/>Select active vehicle on duty | **Shift Control**<br/>Live radar puck & slide to go offline | **15s Dispatch Offer**<br/>Countdown ring, route & guaranteed fare |

| 07. En Route to Pickup | 08. At Pickup Location | 09. Trip In Progress |
|:---:|:---:|:---:|
| <img src="screenshots/driver_app/06_driver_en_route_to_pickup.jpeg" width="260" alt="En Route Pickup" /> | <img src="screenshots/driver_app/07_driver_arrived_at_pickup.jpeg" width="260" alt="Arrived Pickup" /> | <img src="screenshots/driver_app/08_driver_trip_in_progress.jpeg" width="260" alt="Trip In Progress" /> |
| **Geofenced Approach**<br/>Slide unlocks within 150m radius | **Passenger Pickup**<br/>Waiting verification & slide to start | **Navigation HUD**<br/>Live in-app & Google Maps launch |

| 10. Completed Trip Summary | 11. Earnings & Trip History | 12. Verified Driver Profile |
|:---:|:---:|:---:|
| <img src="screenshots/driver_app/09_driver_trip_completed.jpeg" width="260" alt="Trip Completed" /> | <img src="screenshots/driver_app/10_driver_ride_history.jpeg" width="260" alt="Driver History" /> | <img src="screenshots/driver_app/11_driver_profile.jpeg" width="260" alt="Driver Profile" /> |
| **Cash Collection**<br/>Exact fare due & passenger rating | **Shift Performance**<br/>Total earned & completed trip records | **Verified Partner**<br/>Account details |

---

## 🏗️ System Architecture

RideNest uses a multi-tier decoupled architecture:

```
[ Rider App (Flutter) ]       [ Driver App (Flutter) ]
          │                               │
          └───────────────┬───────────────┘
                          │ (Shared Models, Theme & Networking)
                [ shared_core Package ]
                          │
         ┌────────────────┴────────────────┐
         │ HTTPS / REST      WSS / STOMP   │
         ▼                                 ▼
┌──────────────────────────────────────────────────────────┐
│              Spring Boot 4 Application                   │
│  ┌───────────────────────┐   ┌────────────────────────┐  │
│  │ Security & JWT Filter │   │ WebSocket STOMP Broker │  │
│  └───────────────────────┘   └────────────────────────┘  │
│  ┌───────────────────────┐   ┌────────────────────────┐  │
│  │ Ride & Fare Service   │   │ Geospatial Engine      │  │
│  └───────────────────────┘   └────────────────────────┘  │
└────────────┬─────────────────────────────┬───────────────┘
             │                             │
             ▼                             ▼
   [ PostgreSQL Database ]       [ Redis In-Memory Geo ]
   - Users & Profiles            - Live Driver Coordinates
   - Vehicle Registrations       - Fast Radius Queries
   - Completed Trip Receipts     - Active Session Tokens
```

---

## 🔄 End-to-End Ride Lifecycle

```
[1. Request Ride] ──▶ [2. Redis Match] ──▶ [3. Dispatch Offer]
  Rider chooses         Server searches        15s countdown to
  destination & tier    within 3km radius      nearest driver
                                                     │
                                            Accepted? │
                       ┌─────────────────────────────┴────────┐
                       ▼ YES                                  ▼ NO / Timeout
             [4. Driver En Route]                      [Re-dispatch]
               Real-time tracking                        Offer cascades to
               to pickup coordinate                      next closest driver
                       │
                       ▼ (Within 150m Geofence)
             [5. Arrived at Pickup]
               Slide to Start Trip
                       │
                       ▼
             [6. Trip In Progress]
               Turn-by-turn navigation
               to dropoff point
                       │
                       ▼
             [7. Destination Reached]
               Driver slides Complete Trip
                       │
                       ▼
             [8. Fare & Rating Settlement]
               Authoritative cash collection
               & two-way star ratings
```

---

## 💻 Tech Stack Matrix

| Layer | Technologies & Frameworks |
| :--- | :--- |
| **Backend Service** | Spring Boot 4.1.1, Java 17, Spring Data JPA, Spring Security, Spring WebSocket |
| **Database & Cache** | PostgreSQL 16 (Relational), Redis (Geospatial Indexing & In-memory cache) |
| **Mobile Clients** | Flutter 3.13+, Dart 3.0+, Flutter BLoC/Cubit, Freezed, GoRouter |
| **Shared Core** | Dio (HTTP client), StompDartClient, Hive, SharedPreferences, GetIt (DI) |
| **Mapping & Location** | Google Maps Platform (Maps SDK for Android/iOS, Geocoding API, Directions API) |
| **Authentication** | Stateless JWT (JSON Web Tokens) with Role-Based Access Control (`RIDER`, `DRIVER`) |
| **Build & Tooling** | Maven (Backend), Flutter CLI, Dart Analyzer |

---

## 🚀 Getting Started

### 1. Prerequisites

- **Java JDK**: Version 17 or higher
- **Maven**: Version 3.8+
- **Flutter SDK**: Version 3.13.4+
- **PostgreSQL**: Version 14+
- **Redis**: Version 6+
- **Google Maps API Key**: Enabled for Maps SDK, Directions, Places, and Geocoding

---

### 2. Backend Setup (`ride-share/`)

1. **Configure Environment Variables**:
   Create a `.env` file or update `src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/rideshare
   spring.datasource.username=postgres
   spring.datasource.password=your_password
   spring.data.redis.host=localhost
   spring.data.redis.port=6379
   jwt.secret=your_super_secret_jwt_key_at_least_256_bits_long
   google.maps.api.key=YOUR_GOOGLE_MAPS_API_KEY
   ```

2. **Build and Run**:
   ```bash
   cd ride-share
   mvn clean install -DskipTests
   mvn spring-boot:run
   ```
   The backend service starts on `http://localhost:8080`. API documentation is available at `http://localhost:8080/swagger-ui.html`.

---

### 3. Mobile Setup (`rider_app/` & `driver_app/`)

1. **Install Dependencies for Shared Core**:
   ```bash
   cd shared_core
   flutter pub get
   ```

2. **Launch the Rider App**:
   ```bash
   cd ../rider_app
   flutter pub get
   flutter run
   ```

3. **Launch the Driver Partner App**:
   ```bash
   cd ../driver_app
   flutter pub get
   flutter run
   ```

---

## 🧪 Testing & Verification

All modules include focused unit and widget test suites verifying state machines, UI states, and data contracts without mock data leaks.

```bash
# Run tests for Driver App
cd driver_app
flutter test

# Output:
# 00:03 +14: All tests passed!
# - ProfileScreen Tests (loading skeleton, error retry, real driver metrics)
# - RideHistoryScreen Tests (real earnings, dynamic status tabs, empty state)
# - RideRequestSheet Tests (real distance/ETA, real surge, accept/decline)
# - ActiveTripPanel Tests (150m proximity lock, manual override, arrived/in-progress)
# - TripSummarySheet Tests (authoritative fare receipt, star rating)
```

```bash
# Static Analysis & Format Check
dart analyze lib/
dart format --set-exit-if-changed lib/
```

---

## 📄 License & Attribution

This project is licensed under the MIT License. Developed as a production-grade ride-sharing platform for high-density urban transit ecosystems.

