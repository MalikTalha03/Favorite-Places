import "dart:io";

import "package:favourite_place/models/place.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class UserPlacesNotifier extends StateNotifier<List<Places>> {
  UserPlacesNotifier() : super([]);

  void addPlace(String title, File img) {
    state = [
      ...state,
      Places(
        title: title,
        image: img,
      ),
    ];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Places>>(
  (ref) => UserPlacesNotifier(),
);
