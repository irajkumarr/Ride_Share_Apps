import 'package:shared_core/core/utils/base_cubit.dart';
import 'package:shared_core/models/location/address_model.dart';
import 'package:shared_core/models/location/lat_lng_model.dart';
import '../../../data/repo/places_repo.dart';

abstract class RideSearchState {}

class RideSearchInitial extends RideSearchState {
  final AddressModel? pickup;
  final AddressModel? destination;
  final List<AddressModel> favorites;
  final List<AddressModel> recents;

  RideSearchInitial({
    this.pickup,
    this.destination,
    this.favorites = const [],
    this.recents = const [],
  });
}

class RideSearchLoading extends RideSearchState {}

class RideSearchResultsLoaded extends RideSearchState {
  final List<AddressModel> results;
  final String query;
  final bool isPickup;

  RideSearchResultsLoaded({
    required this.results,
    required this.query,
    required this.isPickup,
  });
}

class RideLocationsSelected extends RideSearchState {
  final AddressModel pickup;
  final AddressModel destination;

  RideLocationsSelected({
    required this.pickup,
    required this.destination,
  });
}

class RideSearchFailure extends RideSearchState {
  final String message;
  RideSearchFailure(this.message);
}

class RideSearchCubit extends BaseCubit<RideSearchState> {
  final PlacesRepo _repo;

  AddressModel? _currentPickup;
  AddressModel? _currentDestination;

  RideSearchCubit(this._repo)
      : super(
          RideSearchInitial(
            favorites: _repo.getFavoritePlaces(),
            recents: _repo.getRecentPlaces(),
          ),
        );

  AddressModel? get currentPickup => _currentPickup;
  AddressModel? get currentDestination => _currentDestination;

  void setPickup(AddressModel pickup) {
    _currentPickup = pickup;
    _checkBothSelected();
  }

  void setDestination(AddressModel destination) {
    _currentDestination = destination;
    _checkBothSelected();
  }

  void clearDestination() {
    _currentDestination = null;
    emit(
      RideSearchInitial(
        pickup: _currentPickup,
        destination: null,
        favorites: _repo.getFavoritePlaces(),
        recents: _repo.getRecentPlaces(),
      ),
    );
  }

  void resetSearch() {
    emit(
      RideSearchInitial(
        pickup: _currentPickup,
        destination: _currentDestination,
        favorites: _repo.getFavoritePlaces(),
        recents: _repo.getRecentPlaces(),
      ),
    );
  }

  Future<void> searchPlaces(
    String query, {
    required bool isPickup,
    LatLngModel? proximity,
  }) async {
    if (query.trim().isEmpty) {
      resetSearch();
      return;
    }

    await safeCall<List<AddressModel>>(
      label: 'SearchPlaces',
      call: () => _repo.searchPlaces(query, proximity: proximity),
      loading: () => RideSearchLoading(),
      success: (results) => RideSearchResultsLoaded(
        results: results,
        query: query,
        isPickup: isPickup,
      ),
      failure: (error) => RideSearchResultsLoaded(
        results: const [],
        query: query,
        isPickup: isPickup,
      ),
    );
  }

  void _checkBothSelected() {
    if (_currentPickup != null && _currentDestination != null) {
      emit(
        RideLocationsSelected(
          pickup: _currentPickup!,
          destination: _currentDestination!,
        ),
      );
    } else {
      emit(
        RideSearchInitial(
          pickup: _currentPickup,
          destination: _currentDestination,
          favorites: _repo.getFavoritePlaces(),
          recents: _repo.getRecentPlaces(),
        ),
      );
    }
  }
}
