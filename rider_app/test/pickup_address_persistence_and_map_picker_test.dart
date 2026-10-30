import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/data/local/recent_places_local_data_source.dart';
import 'package:rider_app/src/data/remote/places_api_service.dart';
import 'package:rider_app/src/data/repo/places_repo.dart';
import 'package:rider_app/src/modules/home/blocs/ride_search_cubit.dart';
import 'package:rider_app/src/modules/home/widgets/destination_search_sheet.dart';
import 'package:rider_app/src/modules/home/widgets/pickup_address_picker_sheet.dart';
import 'package:shared_core/models/location/address_model.dart';
import 'package:shared_core/models/location/lat_lng_model.dart';
import 'package:shared_core/shared_core.dart';

class MockLocalStorageService implements LocalStorageService {
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
  bool has(String key) => _storage.containsKey(key);

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlacesApiService implements PlacesApiService {
  @override
  Future<List<AddressModel>> searchPlaces(
    String query, {
    LatLngModel? proximity,
  }) async {
    return [
      AddressModel(
        id: 'place_thamel',
        title: 'Thamel Chowk',
        formattedAddress: 'Thamel, Kathmandu, Nepal',
        coordinates: const LatLngModel(latitude: 27.7154, longitude: 85.3123),
        country: 'Nepal',
      ),
    ];
  }

  @override
  Future<AddressModel?> reverseGeocode(LatLngModel coordinates) async {
    return AddressModel(
      id: 'rev_geo',
      title: 'Jhamsikhel, Lalitpur',
      formattedAddress: 'Jhamsikhel Road, Lalitpur, Nepal',
      coordinates: coordinates,
      country: 'Nepal',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRecentPlacesLocalDataSource implements RecentPlacesLocalDataSource {
  @override
  Future<List<AddressModel>> getRecentPlaces() async => [
    const AddressModel(
      id: 'rec_1',
      title: 'Civil Mall, Sundhara',
      formattedAddress: 'Sundhara, Kathmandu',
      coordinates: LatLngModel(latitude: 27.7000, longitude: 85.3120),
      country: 'Nepal',
    ),
  ];

  @override
  List<AddressModel> getRecentPlacesSync() => [];

  @override
  Future<void> saveRecentPlace(AddressModel place) async {}

  @override
  Future<void> clearRecentPlaces() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalStorageService mockStorage;
  late FakePlacesApiService fakeApi;
  late FakeRecentPlacesLocalDataSource fakeLocal;
  late PlacesRepo placesRepo;

  setUp(() {
    mockStorage = MockLocalStorageService();
    fakeApi = FakePlacesApiService();
    fakeLocal = FakeRecentPlacesLocalDataSource();
    placesRepo = PlacesRepo(
      api: fakeApi,
      local: fakeLocal,
      storage: mockStorage,
    );

    // Register into sl if not present
    if (!sl.isRegistered<PlacesRepo>()) {
      sl.registerSingleton<PlacesRepo>(placesRepo);
    }
  });

  tearDown(() {
    if (sl.isRegistered<PlacesRepo>()) {
      sl.unregister<PlacesRepo>();
    }
  });

  group('Pickup Address Persistence Tests', () {
    test('saveSavedPickupAddress stores JSON and getSavedPickupAddress restores it', () async {
      const address = AddressModel(
        id: 'custom_pickup_1',
        title: 'Durbar Marg',
        formattedAddress: 'Durbar Marg, Kathmandu, Nepal',
        coordinates: LatLngModel(latitude: 27.7100, longitude: 85.3175),
        country: 'Nepal',
      );

      // Verify initially empty
      expect(placesRepo.getSavedPickupAddress(), isNull);

      // Save custom pickup address
      await placesRepo.saveSavedPickupAddress(address);

      // Verify it is saved in local storage under LocalStorageKeys.savedPickupAddress
      final storedRaw = mockStorage.getString(
        LocalStorageKeys.savedPickupAddress,
      );
      expect(storedRaw, isNotNull);

      // Retrieve via repo
      final retrieved = placesRepo.getSavedPickupAddress();
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'custom_pickup_1');
      expect(retrieved.title, 'Durbar Marg');
      expect(retrieved.coordinates.latitude, 27.7100);
      expect(retrieved.coordinates.longitude, 85.3175);
    });

    test('clearSavedPickupAddress removes the saved address', () async {
      const address = AddressModel(
        id: 'custom_pickup_2',
        title: 'New Baneshwor',
        formattedAddress: 'Baneshwor, Kathmandu',
        coordinates: LatLngModel(latitude: 27.6915, longitude: 85.3420),
        country: 'Nepal',
      );

      await placesRepo.saveSavedPickupAddress(address);
      expect(placesRepo.getSavedPickupAddress(), isNotNull);

      await placesRepo.clearSavedPickupAddress();
      expect(placesRepo.getSavedPickupAddress(), isNull);
    });
  });

  group('DestinationSearchSheet with Chosen Pickup Address Tests', () {
    testWidgets('populates chosen pickup address in pickup field when opened', (
      tester,
    ) async {
      const chosenPickup = AddressModel(
        id: 'p_101',
        title: 'Baluwatar Prime',
        formattedAddress: 'Baluwatar Ward 4, Kathmandu',
        coordinates: LatLngModel(latitude: 27.7280, longitude: 85.3320),
        country: 'Nepal',
      );

      final cubit = RideSearchCubit(placesRepo);
      cubit.setPickup(chosenPickup);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RideSearchCubit>.value(
            value: cubit,
            child: const Scaffold(
              body: DestinationSearchSheet(initialFocusDestination: true),
            ),
          ),
        ),
      );

      // The pickup text field must display the chosen address title
      expect(find.text('Baluwatar Prime'), findsOneWidget);

      // Verify that no fake placeholder like 'Udaypur fresh butcher shop' is displayed
      expect(find.text('Udaypur fresh butcher shop'), findsNothing);

      // Verify "Choose destination on map" shortcut is present
      expect(find.text('Choose destination on map'), findsOneWidget);
    });
  });

  group('PickupAddressPickerSheet Tests', () {
    testWidgets(
      'renders search bar, Choose on Map, Current Location, and recent places',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PickupAddressPickerSheet(
                currentCoordinates: const LatLng(27.7172, 85.3240),
              ),
            ),
          ),
        );

        // Verify header and action options
        expect(find.text('Choose Pickup Location'), findsOneWidget);
        expect(find.text('Choose on Map'), findsOneWidget);
        expect(find.text('Pinpoint on map'), findsOneWidget);
        expect(find.text('Current Location'), findsOneWidget);

        // Verify recent places section
        await tester.pumpAndSettle();
        expect(find.text('SAVED & RECENT PLACES'), findsOneWidget);
        expect(find.text('Civil Mall, Sundhara'), findsOneWidget);
      },
    );
  });
}
