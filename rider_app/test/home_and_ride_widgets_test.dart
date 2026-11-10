import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/data/local/recent_places_local_data_source.dart';
import 'package:rider_app/src/data/remote/places_api_service.dart';
import 'package:rider_app/src/data/remote/ride_api_service.dart';
import 'package:rider_app/src/data/repo/places_repo.dart';
import 'package:rider_app/src/modules/home/blocs/ride_search_cubit.dart';
import 'package:rider_app/src/modules/home/widgets/active_driver_card.dart';
import 'package:rider_app/src/modules/home/widgets/home_header.dart';
import 'package:rider_app/src/modules/home/widgets/home_idle_view.dart';
import 'package:rider_app/src/modules/home/widgets/location_pill.dart';
import 'package:rider_app/src/modules/home/widgets/where_to_search_bar.dart';
import 'package:rider_app/src/modules/ride/views/ride_state_overlay.dart';
import 'package:rider_app/src/modules/ride/widgets/map/map_controls.dart';
import 'package:rider_app/src/modules/ride/widgets/map/ride_markers.dart';
import 'package:rider_app/src/modules/ride/widgets/map/ride_polylines.dart';
import 'package:shared_core/shared_core.dart';

class _FakeLocalStorageService implements LocalStorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> setString(String key, {required String value}) async {
    _storage[key] = value;
  }

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlacesApiService implements PlacesApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecentPlacesLocalDataSource implements RecentPlacesLocalDataSource {
  @override
  Future<List<AddressModel>> getRecentPlaces() async => [];

  @override
  List<AddressModel> getRecentPlacesSync() => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlacesRepo fakePlacesRepo;
  late RideSearchCubit rideSearchCubit;

  setUp(() {
    fakePlacesRepo = PlacesRepo(
      api: _FakePlacesApiService(),
      local: _FakeRecentPlacesLocalDataSource(),
      storage: _FakeLocalStorageService(),
    );
    rideSearchCubit = RideSearchCubit(fakePlacesRepo);
  });

  tearDown(() {
    rideSearchCubit.close();
  });

  group('Home Widgets Tests', () {
    testWidgets('HomeHeader renders RIDENEST and responds to menu tap', (
      tester,
    ) async {
      bool menuPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              onMenuPressed: () {
                menuPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('RIDENEST', findRichText: true), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pump();
      expect(menuPressed, isTrue);
    });

    testWidgets('LocationPill renders formatted title and handles tap', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationPill(
              title: 'Pulchowk, Lalitpur',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Pulchowk, Lalitpur'), findsOneWidget);
      expect(find.byIcon(Icons.place_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.byType(LocationPill));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('WhereToSearchBar renders prompt and handles tap', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhereToSearchBar(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Where to?'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_filled_rounded), findsOneWidget);

      await tester.tap(find.byType(WhereToSearchBar));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('HomeIdleView renders all core idle sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<RideSearchCubit>.value(
              value: rideSearchCubit,
              child: HomeIdleView(
                pickupTitle: 'Thamel, Kathmandu',
                onOpenPickupLocationPicker: () {},
                onOpenSearchSheet: () {},
                onSelectDestination: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(LocationPill), findsOneWidget);
      expect(find.byType(WhereToSearchBar), findsOneWidget);
      expect(find.text('Thamel, Kathmandu'), findsOneWidget);
    });
  });

  group('Ride Map & Overlay Widgets Tests', () {
    test('RideMarkers generates valid marker instances with expected IDs', () {
      final pickup = RideMarkers.createPickupMarker(
        position: const LatLng(27.7, 85.3),
        title: 'Baneshwor',
      );
      expect(pickup.markerId.value, equals('pickup_marker'));
      expect(pickup.position.latitude, equals(27.7));

      final destination = RideMarkers.createDestinationMarker(
        position: const LatLng(27.71, 85.32),
        title: 'Patan Durbar',
      );
      expect(destination.markerId.value, equals('destination_marker'));

      final driverMarker = RideMarkers.createDriverMarker(
        position: const LatLng(27.705, 85.31),
        driver: const DriverModel(
          id: 'd1',
          name: 'Ram Thapa',
          photoUrl: 'https://example.com/driver.png',
          phoneNumber: '9800000000',
          vehicleModel: 'Pulsar 150',
          vehicleColor: 'Black',
          licensePlate: 'BA 2 PA 4092',
          rating: 4.9,
          totalRides: 120,
          location: LatLngModel(latitude: 27.705, longitude: 85.31),
        ),
        heading: 90.0,
      );
      expect(driverMarker.markerId.value, equals('driver_marker'));
      expect(driverMarker.infoWindow.title, equals('Ram Thapa'));
      expect(driverMarker.rotation, equals(90.0));
      expect(driverMarker.flat, isTrue);
      expect(driverMarker.anchor, equals(const Offset(0.5, 0.5)));
      expect(driverMarker.zIndexInt, equals(5));
    });

    test('RidePolylines generates valid animated and backdrop polylines', () {
      final points = [const LatLng(27.7, 85.3), const LatLng(27.71, 85.31)];

      final polylines = RidePolylines.buildAnimatedRoutePolylines(
        fullRoutePoints: points,
        animatedCurrentPoints: points,
      );

      expect(polylines.length, equals(2));
      expect(
        polylines.any((p) => p.polylineId.value == 'trip_route_backdrop'),
        isTrue,
      );
      expect(
        polylines.any((p) => p.polylineId.value == 'trip_route_line'),
        isTrue,
      );
    });

    testWidgets('RideStateOverlay badges render expected text and indicators', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [OnTripHeaderBadge(licensePlate: 'BA 2 PA 4092')],
            ),
          ),
        ),
      );

      expect(find.text('ON TRIP'), findsOneWidget);
      expect(find.text('BA 2 PA 4092'), findsOneWidget);
    });

    testWidgets('DriverArrivedHeaderBadge renders expected status', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DriverArrivedHeaderBadge(licensePlate: 'BA 2 PA 4092'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('DRIVER ARRIVED'), findsOneWidget);
    });

    testWidgets('DestinationFlagPin renders dynamic ETA minutes and title', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DestinationFlagPin(
                  screenOffset: Offset(100, 200),
                  destinationTitle: 'Thamel Chowk',
                  etaMinutes: 14,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Thamel Chowk'), findsOneWidget);
      expect(find.textContaining('14 min'), findsOneWidget);
    });

    testWidgets('ActiveDriverCard renders live calculated ETA and distance', (
      tester,
    ) async {
      const pickup = AddressModel(
        id: 'p1',
        title: 'Baneshwor',
        formattedAddress: 'Baneshwor, Kathmandu',
        coordinates: LatLngModel(latitude: 27.69, longitude: 85.34),
        country: 'Nepal',
      );
      const dest = AddressModel(
        id: 'd1',
        title: 'Patan Durbar',
        formattedAddress: 'Patan, Lalitpur',
        coordinates: LatLngModel(latitude: 27.67, longitude: 85.32),
        country: 'Nepal',
      );

      final booking = RideBookingModel(
        id: 'ride_101',
        pickup: pickup,
        destination: dest,
        vehicleTier: 'Comfort',
        fareNpr: 350.0,
        paymentMethod: 'Khalti',
        route: const RouteModel(
          points: [],
          distanceInMeters: 3500,
          durationInSeconds: 600,
        ),
        status: RideStatus.driverAssigned,
      );

      const driver = DriverModel(
        id: 'd1',
        name: 'Suman Shrestha',
        photoUrl: '',
        phoneNumber: '9841000000',
        vehicleModel: 'Hyundai i20',
        vehicleColor: 'Silver',
        licensePlate: 'BA 3 PA 1234',
        rating: 4.85,
        totalRides: 250,
        location: LatLngModel(latitude: 27.695, longitude: 85.342),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveDriverCard(
              booking: booking,
              driver: driver,
              statusText: 'Driver Accepted',
              onCancel: () {},
              etaMinutes: 7,
              distanceKm: 1.8,
            ),
          ),
        ),
      );

      expect(find.text('Suman Shrestha'), findsOneWidget);
      expect(find.textContaining('Silver Hyundai i20'), findsOneWidget);
      expect(find.textContaining('7 mins'), findsOneWidget);
      expect(find.textContaining('1.8 km'), findsOneWidget);
    });

    testWidgets('TripCompletedHeaderBadge renders expected status', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                TripCompletedHeaderBadge(licensePlate: 'BA 2 PA 4092'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('RIDE COMPLETED'), findsOneWidget);
    });

    testWidgets('MapControls trigger user callbacks', (tester) async {
      bool backPressed = false;
      bool recenterPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingMapBackButton(
                  bottomOffset: 100,
                  onPressed: () {
                    backPressed = true;
                  },
                ),
                FloatingRecenterButton(
                  bottomOffset: 100,
                  onPressed: () {
                    recenterPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FloatingMapBackButton), findsOneWidget);
      expect(find.byType(FloatingRecenterButton), findsOneWidget);

      await tester.tap(find.byType(FloatingMapBackButton));
      await tester.pump();
      expect(backPressed, isTrue);

      await tester.tap(find.byType(FloatingRecenterButton));
      await tester.pump();
      expect(recenterPressed, isTrue);
    });
  });
}
