import "dart:io";
import 'package:path/path.dart' as path;
import "package:favourite_place/models/place.dart";
import 'package:path_provider/path_provider.dart' as syspaths;
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class UserPlacesNotifier extends StateNotifier<List<Places>> {
  UserPlacesNotifier() : super([]);

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, "places.db"),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
      },
      version: 1,
    );
    return db;
  }

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final placesData = await db.query("user_places");
    final places = placesData
        .map(
          (e) => Places(
            id: e["id"] as String,
            title: e["title"] as String,
            image: File(e["image"] as String),
            location: PlaceLocation(
              latitude: e["lat"] as double,
              longitude: e["lng"] as double,
              address: e["address"] as String,
            ),
          ),
        )
        .toList();
    state = places;
  }

  void addPlace(String title, File img, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(img.path);
    final savedImage = await img.copy("${appDir.path}/$fileName");
    final newPlace = Places(
      title: title,
      image: savedImage,
      location: location,
    );
    final db = await _getDatabase();
    await db.insert("user_places", {
      "id": newPlace.id,
      "title": newPlace.title,
      "image": newPlace.image.path,
      "lat": newPlace.location.latitude,
      "lng": newPlace.location.longitude,
      "address": newPlace.location.address,
    });
    state = [
      ...state,
      newPlace,
    ];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Places>>(
  (ref) => UserPlacesNotifier(),
);
