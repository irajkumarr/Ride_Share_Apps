import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/data/remote/dto/rider_ride_history_dto.dart';
import 'package:rider_app/src/data/remote/dto/user_dto.dart';
import 'package:rider_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:rider_app/src/modules/home/profile_screen.dart';
import 'package:rider_app/src/modules/ride_history/blocs/rider_ride_history_cubit.dart';
import 'package:rider_app/src/modules/ride_history/views/rider_ride_history_screen.dart';

class FakeCurrentUserCubit extends Cubit<CurrentUserState>
    implements CurrentUserCubit {
  FakeCurrentUserCubit(super.initialState);

  bool getProfileCalled = false;

  @override
  Future<void> getCurrentUser() async {
    getProfileCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRiderRideHistoryCubit extends Cubit<RiderRideHistoryState>
    implements RiderRideHistoryCubit {
  FakeRiderRideHistoryCubit(super.initialState);

  bool fetchRidesCalled = false;

  @override
  Future<void> fetchRides() async {
    fetchRidesCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProfileScreen Tests', () {
    testWidgets('renders skeleton during loading state', (tester) async {
      final fakeCubit = FakeCurrentUserCubit(CurrentUserLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CurrentUserCubit>.value(
            value: fakeCubit,
            child: const ProfileScreen(),
          ),
        ),
      );

      // Skeletons are rendered and title is present
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(fakeCubit.getProfileCalled, isTrue);
    });

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      final fakeCubit = FakeCurrentUserCubit(
        CurrentUserFailure('Network connection refused'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CurrentUserCubit>.value(
            value: fakeCubit,
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Unable to Load Profile'), findsOneWidget);
      expect(find.text('Network connection refused'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(fakeCubit.getProfileCalled, isTrue);
    });

    testWidgets('renders real authoritative data without fake data', (
      tester,
    ) async {
      final user = const UserDataDto(
        id: 'usr_88234912',
        fullName: 'Jane Doe',
        phone: '+977 9811223344',
        email: 'jane.doe@example.com',
        role: 'RIDER',
        status: 'ACTIVE',
        rating: 4.8,
        totalRides: 12,
      );

      final fakeCubit = FakeCurrentUserCubit(
        CurrentUserSuccess(user, 'Fetched successfully'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CurrentUserCubit>.value(
            value: fakeCubit,
            child: const ProfileScreen(),
          ),
        ),
      );

      // Verify authentic values
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('+977 9811223344'), findsOneWidget);
      expect(find.text('ID: #USR_8823'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      // Ensure no hardcoded fake fallback data is displayed
      expect(find.text('4.98'), findsNothing);
      expect(find.text('34'), findsNothing);
      expect(find.text('+977 9800000000'), findsNothing);
      expect(find.text('RN-4912'), findsNothing);
    });

    testWidgets(
      'handles null rating and null total rides cleanly without inventing fake numbers',
      (tester) async {
        final user = const UserDataDto(
          id: 'user_1',
          fullName: null,
          phone: null,
          email: 'test@example.com',
          role: 'RIDER',
          status: 'ACTIVE',
          rating: null,
          totalRides: null,
        );

        final fakeCubit = FakeCurrentUserCubit(
          CurrentUserSuccess(user, 'Fetched successfully'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CurrentUserCubit>.value(
              value: fakeCubit,
              child: const ProfileScreen(),
            ),
          ),
        );

        // Displays "—" for rating and "0" for trips
        expect(find.text('—'), findsOneWidget);
        expect(find.text('No ratings yet'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
        expect(find.text('Rider'), findsOneWidget);

        // Never shows 4.98 or 34
        expect(find.text('4.98'), findsNothing);
        expect(find.text('34'), findsNothing);
      },
    );
  });

  group('RiderRideHistoryScreen Tests', () {
    testWidgets('renders shimmer skeleton during loading state', (
      tester,
    ) async {
      final fakeCubit = FakeRiderRideHistoryCubit(RiderRideHistoryLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RiderRideHistoryCubit>.value(
            value: fakeCubit,
            child: const RiderRideHistoryScreen(),
          ),
        ),
      );

      expect(find.text('My Rides & Trips'), findsOneWidget);
      expect(fakeCubit.fetchRidesCalled, isTrue);
    });

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      final fakeCubit = FakeRiderRideHistoryCubit(
        RiderRideHistoryFailure('Failed to fetch rides from server'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RiderRideHistoryCubit>.value(
            value: fakeCubit,
            child: const RiderRideHistoryScreen(),
          ),
        ),
      );

      expect(find.text('Unable to Load Rides'), findsOneWidget);
      expect(find.text('Failed to fetch rides from server'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(fakeCubit.fetchRidesCalled, isTrue);
    });

    testWidgets('renders empty state when no rides exist', (tester) async {
      final fakeCubit = FakeRiderRideHistoryCubit(
        RiderRideHistoryLoaded(rides: []),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RiderRideHistoryCubit>.value(
            value: fakeCubit,
            child: const RiderRideHistoryScreen(),
          ),
        ),
      );

      expect(find.text('No Rides Yet'), findsOneWidget);
      expect(find.text('Book a Ride'), findsOneWidget);
    });

    testWidgets(
      'renders real rides, accurate statuses, and fare calculations',
      (tester) async {
        final rides = [
          const RiderRideHistoryDto(
            id: 'ride_1001',
            status: 'COMPLETED',
            pickupAddress: 'Thamel, Kathmandu',
            dropoffAddress: 'Patan Durbar Square, Lalitpur',
            driverName: 'Suresh Shrestha',
            licensePlate: 'BA 2 PA 1234',
            finalFare: 250.0,
            createdAt: '2026-10-30T10:30:00Z',
          ),
          const RiderRideHistoryDto(
            id: 'ride_2002',
            status: 'CANCELLED_BY_RIDER',
            pickupAddress: 'Baneshwor',
            dropoffAddress: 'Koteshwor',
            estimatedFare: 120.0,
            createdAt: '2026-10-29T14:15:00Z',
          ),
        ];

        final fakeCubit = FakeRiderRideHistoryCubit(
          RiderRideHistoryLoaded(rides: rides),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<RiderRideHistoryCubit>.value(
              value: fakeCubit,
              child: const RiderRideHistoryScreen(),
            ),
          ),
        );

        // Real addresses and IDs
        expect(find.text('Thamel, Kathmandu'), findsOneWidget);
        expect(find.text('Patan Durbar Square, Lalitpur'), findsOneWidget);
        expect(find.text('Trip #RIDE_1001'), findsOneWidget);
        expect(find.text('Trip #RIDE_2002'), findsOneWidget);
        expect(find.text('Suresh Shrestha'), findsOneWidget);
        expect(find.text('Rs. 250'), findsOneWidget);

        // Status badges (present on both filter tab and ride card)
        expect(find.text('COMPLETED'), findsNWidgets(2));
        expect(find.text('CANCELLED'), findsNWidgets(2));

        // Total spent calculation for completed rides
        expect(find.text('Total Spent: Rs. 250'), findsOneWidget);
      },
    );
  });
}
