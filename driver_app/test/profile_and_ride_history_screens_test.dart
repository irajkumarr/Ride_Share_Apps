import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/data/remote/dto/driver_ride_history_dto.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:driver_app/src/modules/home/views/profile_screen.dart';
import 'package:driver_app/src/modules/ride_history/blocs/driver_ride_history_cubit.dart';
import 'package:driver_app/src/modules/ride_history/views/ride_history_screen.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';

class FakeCurrentUserCubit extends Cubit<CurrentUserState>
    implements CurrentUserCubit {
  FakeCurrentUserCubit(super.initialState);

  bool getCurrentUserCalled = false;

  @override
  Future<void> getCurrentUser() async {
    getCurrentUserCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVehicleCubit extends Cubit<VehicleState> implements VehicleCubit {
  FakeVehicleCubit(super.initialState);

  bool fetchMyVehiclesCalled = false;

  @override
  Future<void> fetchMyVehicles() async {
    fetchMyVehiclesCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDriverRideHistoryCubit extends Cubit<DriverRideHistoryState>
    implements DriverRideHistoryCubit {
  FakeDriverRideHistoryCubit(super.initialState);

  bool fetchRidesCalled = false;

  @override
  Future<void> fetchRides() async {
    fetchRidesCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Driver ProfileScreen Tests', () {
    testWidgets('renders skeleton during loading state', (tester) async {
      final fakeUserCubit = FakeCurrentUserCubit(CurrentUserLoading());
      final fakeVehicleCubit = FakeVehicleCubit(VehicleInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CurrentUserCubit>.value(value: fakeUserCubit),
              BlocProvider<VehicleCubit>.value(value: fakeVehicleCubit),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Driver Profile'), findsOneWidget);
      expect(fakeUserCubit.getCurrentUserCalled, isTrue);
    });

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      final fakeUserCubit = FakeCurrentUserCubit(
        CurrentUserFailure('Network connection refused'),
      );
      final fakeVehicleCubit = FakeVehicleCubit(VehicleInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CurrentUserCubit>.value(value: fakeUserCubit),
              BlocProvider<VehicleCubit>.value(value: fakeVehicleCubit),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Unable to Load Driver Profile'), findsOneWidget);
      expect(find.text('Network connection refused'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(fakeUserCubit.getCurrentUserCalled, isTrue);
    });

    testWidgets('renders real authoritative driver data without fake data', (
      tester,
    ) async {
      final user = const UserDataDto(
        id: 'drv_99881122',
        fullName: 'Ram Bahadur',
        phone: '+977 9841234567',
        email: 'ram.driver@ridenest.com',
        role: 'DRIVER',
        status: 'ACTIVE',
        rating: 4.85,
        totalRides: 142,
      );

      final vehicle = const VehicleDto(
        id: 'veh_001',
        make: 'Hyundai',
        model: 'i20',
        year: '2022',
        licensePlate: 'BA 1 PA 9999',
        type: 'ECONOMY',
        approved: true,
      );

      final fakeUserCubit = FakeCurrentUserCubit(
        CurrentUserSuccess(user, 'Fetched successfully'),
      );
      final fakeVehicleCubit = FakeVehicleCubit(
        VehicleLoaded(vehicles: [vehicle], activeVehicle: vehicle),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CurrentUserCubit>.value(value: fakeUserCubit),
              BlocProvider<VehicleCubit>.value(value: fakeVehicleCubit),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify real data is present
      expect(find.text('Ram Bahadur'), findsOneWidget);
      expect(find.text('+977 9841234567'), findsOneWidget);
      expect(find.text('4.85'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('Hyundai i20 • BA 1 PA 9999 (Active)'), findsOneWidget);

      // Verify no fake placeholder data is displayed
      expect(find.text('+977 9804040404'), findsNothing);
      expect(find.text('RN-8842'), findsNothing);
      expect(find.text('Toyota Corolla • BA 2 KHA 1234 (Active)'), findsNothing);
      expect(find.text('486'), findsNothing);
      expect(find.text('4.92'), findsNothing);
    });

    testWidgets(
      'handles null rating, null total rides, and null vehicle cleanly without inventing fake numbers',
      (tester) async {
        final user = const UserDataDto(
          id: 'drv_new_1',
          fullName: 'New Partner',
          phone: '+977 9800000001',
          rating: null,
          totalRides: null,
        );

        final fakeUserCubit = FakeCurrentUserCubit(
          CurrentUserSuccess(user, 'Fetched successfully'),
        );
        final fakeVehicleCubit = FakeVehicleCubit(
          VehicleLoaded(vehicles: const [], activeVehicle: null),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<CurrentUserCubit>.value(value: fakeUserCubit),
                BlocProvider<VehicleCubit>.value(value: fakeVehicleCubit),
              ],
              child: const ProfileScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Rating should be 'New' and 'No ratings yet'
        expect(find.text('New'), findsOneWidget);
        expect(find.text('No ratings yet'), findsOneWidget);

        // Completed should be '0'
        expect(find.text('0'), findsOneWidget);

        // Vehicle subtitle should show 'No vehicle registered • Tap to add'
        expect(find.text('No vehicle registered • Tap to add'), findsOneWidget);

        // Ensure fake numbers are never displayed
        expect(find.text('4.92'), findsNothing);
        expect(find.text('486'), findsNothing);
      },
    );
  });

  group('Driver RideHistoryScreen Tests', () {
    testWidgets('renders shimmer skeleton during loading state', (tester) async {
      final fakeHistoryCubit = FakeDriverRideHistoryCubit(
        DriverRideHistoryLoading(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverRideHistoryCubit>.value(
            value: fakeHistoryCubit,
            child: const RideHistoryScreen(),
          ),
        ),
      );

      expect(find.text('Ride History & Trips'), findsOneWidget);
      expect(fakeHistoryCubit.fetchRidesCalled, isTrue);
    });

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      final fakeHistoryCubit = FakeDriverRideHistoryCubit(
        DriverRideHistoryFailure('Failed to retrieve driver history'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverRideHistoryCubit>.value(
            value: fakeHistoryCubit,
            child: const RideHistoryScreen(),
          ),
        ),
      );

      expect(find.text('Unable to Load Trips'), findsOneWidget);
      expect(find.text('Failed to retrieve driver history'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(fakeHistoryCubit.fetchRidesCalled, isTrue);
    });

    testWidgets('renders empty state when no rides exist', (tester) async {
      final fakeHistoryCubit = FakeDriverRideHistoryCubit(
        DriverRideHistoryLoaded(rides: const []),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverRideHistoryCubit>.value(
            value: fakeHistoryCubit,
            child: const RideHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No trip history yet'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Rs. 0'), findsOneWidget);
    });

    testWidgets(
      'renders real rides, accurate statuses, passenger info, and earnings calculations',
      (tester) async {
        final rides = [
          const DriverRideHistoryDto(
            id: 'ride_d101',
            status: 'COMPLETED',
            riderName: 'Hari Prasad',
            riderPhone: '+977 9811223344',
            licensePlate: 'BA 1 PA 1234',
            pickupAddress: 'Thamel Chowk, Kathmandu',
            dropoffAddress: 'Patan Durbar Square, Lalitpur',
            finalFare: 350.0,
            estimatedFare: 350.0,
            createdAt: '2026-10-30T10:15:00.000Z',
          ),
          const DriverRideHistoryDto(
            id: 'ride_d102',
            status: 'CANCELLED',
            riderName: 'Sita Sharma',
            licensePlate: 'BA 1 PA 1234',
            pickupAddress: 'Baluwatar Prime',
            dropoffAddress: 'Tribhuvan International Airport',
            finalFare: 0.0,
            estimatedFare: 420.0,
            createdAt: '2026-10-30T12:30:00.000Z',
          ),
        ];

        final fakeHistoryCubit = FakeDriverRideHistoryCubit(
          DriverRideHistoryLoaded(rides: rides),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<DriverRideHistoryCubit>.value(
              value: fakeHistoryCubit,
              child: const RideHistoryScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check filter chips and counts
        expect(find.text('ALL'), findsOneWidget);
        expect(find.text('COMPLETED'), findsNWidgets(2)); // filter tab + card badge
        expect(find.text('CANCELLED'), findsNWidgets(2)); // filter tab + card badge

        // Check total earnings section
        expect(find.text('TOTAL EARNED'), findsOneWidget);

        // Check passenger names and addresses
        expect(find.text('Hari Prasad'), findsOneWidget);
        expect(find.text('Thamel Chowk, Kathmandu'), findsOneWidget);
        expect(find.text('Patan Durbar Square, Lalitpur'), findsOneWidget);

        expect(find.text('Sita Sharma'), findsOneWidget);
        expect(find.text('Baluwatar Prime'), findsOneWidget);
        expect(find.text('Tribhuvan International Airport'), findsOneWidget);

        // Check individual fares
        expect(find.text('Rs. 350'), findsNWidgets(2)); // summary + card fare
        expect(find.text('Rs. 0'), findsOneWidget); // cancelled card fare
      },
    );
  });
}
