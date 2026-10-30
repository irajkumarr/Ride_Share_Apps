import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/ride/views/ride_request_sheet.dart';
import 'package:driver_app/src/modules/trip/views/active_trip_panel.dart';
import 'package:driver_app/src/modules/trip/views/trip_summary_sheet.dart';

class FakeRideDispatchCubit extends Cubit<RideDispatchState>
    implements RideDispatchCubit {
  FakeRideDispatchCubit(super.initialState);

  bool acceptRideCalled = false;
  bool declineRideCalled = false;
  String? updatedStatus;
  bool dismissSummaryCalled = false;

  @override
  Future<void> acceptRide(RideRequestPayloadDto request) async {
    acceptRideCalled = true;
  }

  @override
  Future<void> declineRide(String rideId, {bool isTimeout = false}) async {
    declineRideCalled = true;
  }

  @override
  Future<void> updateStatus(String status) async {
    updatedStatus = status;
  }

  @override
  void dismissTripSummary() {
    dismissSummaryCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RideRequestSheet Tests', () {
    testWidgets(
      'renders real authoritative request data including surge and note when present',
      (tester) async {
        final cubit = FakeRideDispatchCubit(RideDispatchIdle());
        const req = RideRequestPayloadDto(
          rideId: 'ride-1234',
          riderName: 'Bikash Thapa',
          pickupAddress: 'Thamel Chowk, Kathmandu',
          dropoffAddress: 'Patan Durbar Square, Lalitpur',
          estimatedFare: 250.0,
          surgeBonus: 50.0,
          paymentType: 'Cash on Arrival',
          riderRating: 4.8,
          riderTripsCount: 45,
          riderNote: 'Waiting near the bookstore',
          distanceToPickupKm: 1.5,
          estimatedDurationMin: 18,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<RideDispatchCubit>.value(
                value: cubit,
                child: const RideRequestSheet(
                  request: req,
                  remainingSeconds: 12,
                ),
              ),
            ),
          ),
        );

        // Verifies real data
        expect(find.text('DISPATCH OFFER'), findsOneWidget);
        expect(find.text('Rs. 250'), findsOneWidget);
        expect(find.text('+Rs. 50 Surge'), findsOneWidget);
        expect(find.text('Cash on Arrival'), findsOneWidget);
        expect(find.text('Thamel Chowk, Kathmandu'), findsOneWidget);
        expect(find.text('Patan Durbar Square, Lalitpur'), findsOneWidget);
        expect(find.text('Bikash Thapa'), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text('45 verified trips'), findsOneWidget);
        expect(find.text('Note: "Waiting near the bookstore"'), findsOneWidget);
        expect(find.text('PICKUP • 1.5 KM AWAY'), findsOneWidget);
        expect(find.text('ACCEPT (12s)'), findsOneWidget);
      },
    );

    testWidgets(
      'renders cleanly without fake data when optional fields are null',
      (tester) async {
        final cubit = FakeRideDispatchCubit(RideDispatchIdle());
        const req = RideRequestPayloadDto(
          rideId: 'ride-999',
          riderName: null,
          pickupAddress: 'Koteshwor Chowk',
          dropoffAddress: 'Baneshwor',
          estimatedFare: 120.0,
          surgeBonus: null,
          riderRating: null,
          riderTripsCount: null,
          riderNote: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<RideDispatchCubit>.value(
                value: cubit,
                child: const RideRequestSheet(
                  request: req,
                  remainingSeconds: 8,
                ),
              ),
            ),
          ),
        );

        // Verifies fallback to Passenger and no fake data invented
        expect(find.text('Passenger'), findsOneWidget);
        expect(find.text('Aarav Shrestha'), findsNothing);
        expect(find.textContaining('Surge'), findsNothing);
        expect(find.text('4.9'), findsNothing);
        expect(find.textContaining('I have exact cash'), findsNothing);
        expect(find.text('Koteshwor Chowk'), findsOneWidget);
        expect(find.text('Baneshwor'), findsOneWidget);
      },
    );

    testWidgets('triggers decline and accept cubit actions', (tester) async {
      final cubit = FakeRideDispatchCubit(RideDispatchIdle());
      const req = RideRequestPayloadDto(
        rideId: 'ride-abc',
        pickupAddress: 'Location A',
        dropoffAddress: 'Location B',
        estimatedFare: 100.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<RideDispatchCubit>.value(
              value: cubit,
              child: const RideRequestSheet(request: req, remainingSeconds: 10),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Decline'));
      await tester.pump();
      expect(cubit.declineRideCalled, isTrue);

      await tester.tap(find.text('ACCEPT (10s)'));
      await tester.pump();
      expect(cubit.acceptRideCalled, isTrue);
    });
  });

  group('ActiveTripPanel Tests', () {
    testWidgets(
      'shows proximity indicator when outside 150m and allows manual override',
      (tester) async {
        final cubit = FakeRideDispatchCubit(RideDispatchIdle());
        final tripState = ActiveTripState(
          rideId: 'ride-123',
          currentStatus: 'ACCEPTED',
          request: const RideRequestPayloadDto(
            rideId: 'ride-123',
            riderName: 'Sunita Rai',
            pickupAddress: 'Jawalakhel, Lalitpur',
            dropoffAddress: 'Pulchowk, Lalitpur',
            estimatedFare: 180.0,
            riderRating: 4.9,
            riderTripsCount: 30,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<RideDispatchCubit>.value(
                value: cubit,
                child: ActiveTripPanel(
                  tripState: tripState,
                  distanceToPickupMeters: 800.0,
                ),
              ),
            ),
          ),
        );

        expect(find.textContaining('EN ROUTE TO PICKUP'), findsOneWidget);
        expect(find.text('Sunita Rai'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
        expect(find.text('30 rides'), findsOneWidget);
        expect(find.text('Jawalakhel, Lalitpur'), findsOneWidget);
        expect(
          find.textContaining('Approaching pickup: 800 m away'),
          findsOneWidget,
        );

        // Tap manual arrival fallback
        await tester.tap(find.text('Arrived but GPS stuck? Tap to confirm'));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Arrival at Pickup'), findsOneWidget);
        await tester.tap(find.text('Yes, I Have Arrived'));
        await tester.pumpAndSettle();

        expect(cubit.updatedStatus, equals('ARRIVED'));
      },
    );

    testWidgets('shows arrived status and destination when in-progress', (
      tester,
    ) async {
      final cubit = FakeRideDispatchCubit(RideDispatchIdle());
      final tripState = ActiveTripState(
        rideId: 'ride-456',
        currentStatus: 'IN_PROGRESS',
        request: const RideRequestPayloadDto(
          rideId: 'ride-456',
          riderName: 'Ramesh KC',
          pickupAddress: 'Kalanki Chowk',
          dropoffAddress: 'Tribhuvan International Airport',
          estimatedFare: 450.0,
        ),
      );

      bool openMapsCalled = false;
      bool toggleFullScreenCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<RideDispatchCubit>.value(
              value: cubit,
              child: ActiveTripPanel(
                tripState: tripState,
                distanceToPickupMeters: 4200.0,
                onOpenGoogleMaps: () => openMapsCalled = true,
                onToggleFullScreen: () => toggleFullScreenCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('TRIP IN PROGRESS'), findsOneWidget);
      expect(find.text('Ramesh KC'), findsOneWidget);
      expect(find.text('Tribhuvan International Airport'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Live In-App'), findsOneWidget);

      await tester.tap(find.text('Google Maps'));
      await tester.pump();
      expect(openMapsCalled, isTrue);

      await tester.tap(find.text('Live In-App'));
      await tester.pump();
      expect(toggleFullScreenCalled, isTrue);
    });
  });

  group('TripSummarySheet Tests', () {
    testWidgets(
      'renders authoritative fare, route recap, interactive star rating, and go online button',
      (tester) async {
        final cubit = FakeRideDispatchCubit(RideDispatchIdle());
        final summaryState = TripCompletedSummaryState(
          rideId: 'ride-complete-777',
          fare: 320.0,
          message: 'Trip completed successfully',
          request: const RideRequestPayloadDto(
            rideId: 'ride-complete-777',
            riderName: 'Anita Gurung',
            pickupAddress: 'Balkumari, Lalitpur',
            dropoffAddress: 'Maitighar Mandala, Kathmandu',
            estimatedFare: 320.0,
            surgeBonus: 40.0,
            paymentType: 'Cash',
            pickupLat: 27.6740,
            pickupLng: 85.3400,
            dropoffLat: 27.6920,
            dropoffLng: 85.3210,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<RideDispatchCubit>.value(
                value: cubit,
                child: TripSummarySheet(summary: summaryState),
              ),
            ),
          ),
        );

        expect(find.text('Trip Completed'), findsOneWidget);
        expect(
          find.text('Dropped off Anita Gurung at Maitighar Mandala'),
          findsOneWidget,
        );
        expect(find.text('Rs. 320'), findsOneWidget);
        expect(find.text('Cash'), findsOneWidget);
        expect(find.text('Balkumari, Lalitpur'), findsOneWidget);
        expect(find.text('Maitighar Mandala, Kathmandu'), findsOneWidget);
        expect(find.text('Rate Anita Gurung'), findsOneWidget);

        // Tap Return online button
        await tester.tap(find.text('COLLECTED FARE & GO ONLINE'));
        await tester.pump();
        expect(cubit.dismissSummaryCalled, isTrue);
      },
    );
  });
}
