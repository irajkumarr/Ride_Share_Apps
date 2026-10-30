# RideNest Platform — Architecture & System Structure

Comprehensive technical blueprint of the RideNest ride-sharing ecosystem, detailing system topology, repository layout, layered design patterns, real-time messaging protocols, and state machines.

---

## 1. System Topology & Architecture

RideNest operates as a distributed system with a centralized Spring Boot backend, Redis geospatial indexing, PostgreSQL persistence, and two Flutter mobile clients (Rider App and Driver App) powered by a unified `shared_core` library.

```mermaid
graph TD
    subgraph Clients["Mobile Client Layer (Flutter)"]
        Rider["📱 Rider App<br/>(Passenger UX)"]
        Driver["🚗 Driver App<br/>(Driver Partner UX)"]
        SharedCore["📦 shared_core<br/>(Networking, Theme, DTOs, DI)"]
        Rider --> SharedCore
        Driver --> SharedCore
    end

    subgraph Gateway["Edge & Network Layer"]
        HTTP["REST APIs<br/>(HTTPS / JSON)"]
        WS["WebSocket STOMP Broker<br/>(SockJS / WSS)"]
        Maps["Google Maps Platform<br/>(Directions, Places, Geocoding)"]
    end

    subgraph Backend["Backend Service Layer (Spring Boot 4 / Java 17)"]
        Security["JWT Auth & Security Filter"]
        AuthCtrl["Auth & User Controllers"]
        RideCtrl["Ride & Dispatch Controllers"]
        WSCtrl["WebSocket Dispatch Controller"]
        VehicleCtrl["Vehicle Management Controller"]
        LocCtrl["Geospatial Location Controller"]

        RideService["Ride Management & Dispatch Service"]
        GeoService["Geospatial Matching Engine"]
        FareService["Dynamic Fare & Surge Engine"]
    end

    subgraph Data["Persistence & In-Memory Layer"]
        Postgres[("🐘 PostgreSQL<br/>Users, Rides, Vehicles, Receipts")]
        Redis[("⚡ Redis<br/>Geo-Radius Driver Coordinates & Caching")]
    end

    Rider -->|REST / JSON| HTTP
    Rider -->|STOMP Subscriptions| WS
    Driver -->|REST / JSON| HTTP
    Driver -->|STOMP Subscriptions| WS
    Rider -.->|Tile Rendering & Routes| Maps
    Driver -.->|Navigation & Polylines| Maps

    HTTP --> Security
    WS --> Security
    Security --> AuthCtrl
    Security --> RideCtrl
    Security --> VehicleCtrl
    Security --> LocCtrl
    Security --> WSCtrl

    RideCtrl --> RideService
    LocCtrl --> GeoService
    WSCtrl --> RideService

    RideService --> FareService
    RideService --> GeoService
    RideService --> Postgres
    GeoService --> Redis
```

---

## 2. Workspace Monorepo Layout

The workspace is organized into four distinct modules:

```
ride-share-workspace/
├── ride-share/              # Spring Boot 4 Backend Service (Java 17, Maven)
├── rider_app/               # Flutter Mobile Client for Passengers
├── driver_app/              # Flutter Mobile Client for Driver Partners
├── shared_core/             # Shared Dart Package (Networking, Storage, Design System)
├── screenshots/             # Production Screen Captures & Visual Documentation
│   ├── rider_app/           # Complete Rider UI Flow (00-11)
│   └── driver_app/          # Complete Driver UI Flow (00-12)
├── README.md                # Project Overview & Visual Showcase
└── structure.md             # Architecture & Technical Reference (This Document)
```

---

## 3. Module Breakdown

### 3.1. Backend Service (`ride-share/`)

The backend follows the Spring Boot Layered Clean Architecture pattern with explicit boundary separation between HTTP handling, business logic, persistence, and messaging.

```
ride-share/src/main/java/com/rajkumartimalsina/rideShare/
├── config/                  # App configurations: Web, Security, WebSocket, Redis, Swagger
│   ├── RedisConfig.java
│   ├── SecurityConfig.java
│   └── WebSocketConfig.java
├── controllers/             # REST & STOMP Endpoints
│   ├── AuthController.java           # POST /api/auth/register, /api/auth/login
│   ├── UserController.java           # GET/PUT /api/users/profile
│   ├── VehicleController.java        # CRUD /api/vehicles
│   ├── LocationController.java       # POST /api/location/driver/update
│   ├── RideController.java           # POST /api/rides/estimate, /request, /cancel
│   └── RideWebSocketController.java  # STOMP /app/ride.status.update, /app/driver.location
├── services/                # Business logic contracts
│   ├── AuthService.java
│   ├── UserService.java
│   ├── VehicleService.java
│   ├── LocationService.java
│   ├── RideService.java
│   └── impl/                         # Concrete service implementations
├── repositories/            # Spring Data JPA interfaces
│   ├── UserRepository.java
│   ├── VehicleRepository.java
│   ├── RideRepository.java
│   └── DriverLocationRepository.java
├── entities/                # Relational JPA entities
│   ├── User.java                     # Rider & Driver identities
│   ├── Vehicle.java                  # Registered vehicles (Make, Model, Plate, Category)
│   ├── Ride.java                     # Trips, locations, fares, status transitions
│   └── Enums.java                    # RideStatus, Role, VehicleType, PaymentType
├── dto/                     # Strongly typed Request / Response DTOs
│   ├── auth/
│   ├── ride/
│   ├── vehicle/
│   └── location/
├── security/                # JWT Token provider, AuthFilter, UserDetails implementation
│   ├── JwtTokenProvider.java
│   └── JwtAuthenticationFilter.java
└── exception/               # Global exception handlers & custom domain exceptions
    ├── GlobalExceptionHandler.java
    └── ResourceNotFoundException.java
```

---

### 3.2. Shared Core Library (`shared_core/`)

A reusable, shared package consumed by both mobile clients to guarantee zero code duplication, unified themes, shared domain DTOs, and consistent network handling.

```
shared_core/lib/
├── core/
│   ├── di/                  # Service Locator setup (get_it)
│   ├── network/             # Dio client, PrettyDioLogger, AuthInterceptors
│   ├── storage/             # SecureStorage, SharedPreferences, Hive local persistence
│   ├── theme/               # Colors, typography, input decorations, button styles
│   └── utils/               # MapUtils, DistanceUtils, DateTimeFormatters
├── data/
│   ├── remote/              # StompClientWrapper, BaseApiService
│   └── models/              # UserDto, VehicleDto, RideDto, CoordinatesDto
└── ui/
    ├── widgets/             # CustomMapView, SlideToActButton, AppAlerts
    └── common/              # SkeletonLoader, LoadingOverlay, StatusPill
```

---

### 3.3. Rider Mobile App (`rider_app/`)

Built using Flutter with BLoC / Cubit state management following a feature-first structure.

```
rider_app/lib/
├── src/
│   ├── core/
│   │   ├── di/              # Rider app dependency injection
│   │   └── routing/         # GoRouter definitions (/, /login, /home, /history, /profile)
│   ├── data/
│   │   ├── local/           # AuthLocalDataSource, LocationCacheDataSource
│   │   ├── remote/          # RiderApiService, RiderStompService
│   │   └── repo/            # RiderRideRepository, UserRepository
│   └── modules/
│       ├── auth/            # Login, Registration, Splash Screens & Cubits
│       ├── home/            # Map Dashboard, Location Picker, Where-to Search
│       │   ├── blocs/       # RiderHomeCubit, LocationSearchCubit
│       │   ├── views/       # HomeScreen, MapAddressPickerModal
│       │   └── widgets/     # AddressSearchBar, LocationPill, RecentsList
│       ├── ride/            # Ride Selection, Fare Estimate, Radar Search
│       │   ├── blocs/       # RideBookingCubit, RideTrackingCubit
│       │   ├── views/       # RideOptionSheet, DriverFoundSheet, ActiveRideHUD
│       │   └── widgets/     # VehicleCategorySelector, RadarPulseWidget
│       ├── ride_history/    # My Rides & Trips
│       │   ├── blocs/       # RiderRideHistoryCubit
│       │   └── views/       # RideHistoryScreen, TripReceiptModal
│       └── profile/         # Rider Profile & Account Settings
│           ├── blocs/       # RiderProfileCubit
│           └── views/       # ProfileScreen
└── main.dart
```

---

### 3.4. Driver Partner App (`driver_app/`)

Engineered for reliability, real-time dispatch alerts, proximity geofencing, and shift management.

```
driver_app/lib/
├── src/
│   ├── core/
│   │   ├── di/              # Driver app dependency injection
│   │   └── routing/         # GoRouter definitions (/, /login, /home, /history, /profile, /vehicles)
│   ├── data/
│   │   ├── local/           # DriverAuthLocalDataSource
│   │   ├── remote/          # DriverRideApiService, DriverStompService
│   │   └── repo/            # DriverRideRepo, VehicleRepo
│   └── modules/
│       ├── auth/            # Partner Portal Login & Registration
│       ├── home/            # Driver Dashboard, Shift Toggle, GPS Tracking
│       │   ├── blocs/       # DriverStatusCubit
│       │   ├── views/       # HomeScreen
│       │   └── widgets/     # DriverStatusTopBar, DriverVehicleCard, CustomPuckMarker
│       ├── ride/            # Incoming Dispatch Modal & Alerts
│       │   ├── blocs/       # RideDispatchCubit
│       │   ├── utils/       # RideNotificationAlertService (Audio & Vibration)
│       │   ├── views/       # RideRequestSheet, RideRequestMapMarkers
│       ├── trip/            # Active Trip Lifecycle & Completion
│       │   ├── utils/       # TripLocationUtils (Haversine distance, ETA calculation)
│       │   ├── views/       # ActiveTripPanel, TripSummarySheet
│       │   └── widgets/     # SlideToActButton, ProximityIndicator
│       ├── vehicle/         # Fleet & Vehicle Management
│       │   ├── blocs/       # VehicleCubit
│       │   └── views/       # MyVehiclesScreen, VehicleRegisterScreen
│       └── ride_history/    # Partner Shift History & Fares
│           ├── blocs/       # DriverRideHistoryCubit
│           └── views/       # RideHistoryScreen
└── main.dart
```

---

## 4. Real-Time Dispatch Protocol & Messaging Flow

Real-time interactions between Rider, Driver, and Server utilize WebSockets over STOMP with SockJS fallback.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 📱 Rider App
    participant Server as ⚙️ Spring Boot Backend
    participant Redis as ⚡ Redis Geo
    actor Driver as 🚗 Driver Partner App

    Note over Driver,Server: Driver shifts ONLINE & streams coordinates
    Driver->>Server: STOMP: /app/driver.location {lat, lng, heading}
    Server->>Redis: GEOADD drivers:locations lat lng driverId

    Note over Rider,Server: Rider estimates and requests ride
    Rider->>Server: POST /api/rides/request {pickup, dropoff, category}
    Server->>Redis: GEORADIUS around pickup within 3.0km
    Redis-->>Server: [driverId_1, driverId_2]

    Note over Server,Driver: Server dispatches offer to best matched driver
    Server->>Driver: STOMP: /user/queue/ride-requests {rideId, fare, pickup, dropoff, 15s timer}
    
    alt Driver Accepts within 15s
        Driver->>Server: STOMP: /app/ride.status.update {rideId, status: "ACCEPTED"}
        Server->>Rider: STOMP: /user/queue/ride-status {status: "ACCEPTED", driverData, vehicle}
        
        Note over Driver,Rider: Driver En Route to Pickup
        Driver->>Server: STOMP: /app/ride.status.update {status: "ARRIVED"}
        Server->>Rider: STOMP: /user/queue/ride-status {status: "ARRIVED"}
        
        Note over Driver,Rider: Passenger Boards -> Trip Starts
        Driver->>Server: STOMP: /app/ride.status.update {status: "IN_PROGRESS"}
        Server->>Rider: STOMP: /user/queue/ride-status {status: "IN_PROGRESS"}
        
        Note over Driver,Rider: Destination Reached -> Trip Completes
        Driver->>Server: STOMP: /app/ride.status.update {status: "COMPLETED"}
        Server->>Rider: STOMP: /user/queue/ride-status {status: "COMPLETED", finalFare}
        Server->>Driver: STOMP: /user/queue/ride-summary {fare, receipt}
    else Driver Declines or Times Out
        Driver->>Server: STOMP: /app/ride.status.update {status: "DECLINED"}
        Server->>Server: Auto-re-dispatch to next nearest driver
    end
```

---

## 5. State Machines

### 5.1. Ride Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> REQUESTED: Rider submits destination
    REQUESTED --> SEARCHING: Matching engine evaluates nearby drivers
    SEARCHING --> DISPATCHED: Offer delivered to candidate driver (15s timer)
    
    DISPATCHED --> ACCEPTED: Driver taps Accept
    DISPATCHED --> SEARCHING: Driver declines or timer expires
    
    ACCEPTED --> EN_ROUTE: Driver navigates to pickup
    EN_ROUTE --> ARRIVED: Driver enters 150m geofence / confirms arrival
    
    ARRIVED --> IN_PROGRESS: Passenger boards & driver slides Start Trip
    
    IN_PROGRESS --> COMPLETED: Destination reached & driver slides Complete Trip
    
    REQUESTED --> CANCELLED: Rider cancels before pickup
    ACCEPTED --> CANCELLED: Rider cancels / Emergency cancellation
    
    COMPLETED --> [*]: Cash fare collected & rated
    CANCELLED --> [*]: Fee assessed if past grace period
```

### 5.2. Driver Shift State Machine

```mermaid
stateDiagram-v2
    [*] --> OFFLINE: Initial state / Logged out
    OFFLINE --> ONLINE: Slide to Go Online (Valid vehicle verified)
    ONLINE --> DISPATCH_OFFER: Incoming ride notification (15s countdown)
    DISPATCH_OFFER --> ONLINE: Decline offer / Timeout
    DISPATCH_OFFER --> ON_RIDE: Accept offer
    ON_RIDE --> ONLINE: Ride completed / Summary dismissed
    ONLINE --> OFFLINE: Slide to Go Offline
```

---

## 6. Proximity Geofencing & Safety Guards

1. **150-Meter Urban Geofence**:
   - The driver cannot trigger `ARRIVED` until GPS coordinates place them within 150 meters of the scheduled pickup coordinate.
   - Built-in manual override dialog allows arrival confirmation only after clear driver intent to handle urban concrete canyon GPS drift.
2. **Server-Authoritative Fare Enforcement**:
   - Fares and surges are authoritatively computed on the server. Clients cannot alter fare metrics or inject discount payloads.
3. **Data Protection & Location Privacy**:
   - Ephemeral driver locations in Redis expire after 30 seconds of inactivity.
   - Exact client coordinates are never exposed via unauthenticated endpoints.

