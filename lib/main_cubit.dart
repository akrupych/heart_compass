import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

class MainCubit extends Cubit<MainState> {
  late DatabaseReference _userRef;
  late DatabaseReference _heartRef;
  late SharedPreferences _prefs;

  MainCubit() : super(const MainState()) {
    init();
  }

  init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _prefs = await SharedPreferences.getInstance();
    String userId = _prefs.getString("userId") ?? const Uuid().v4();
    print(userId);
    _prefs.setString("userId", userId);
    emit(state.copyWith(userId: userId));

    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child(userId).get();
    if (snapshot.exists) {
      _userRef = snapshot.ref;
    } else {
      await dbRef.update({userId: userId});
      _userRef = dbRef.child(userId);
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final heartId = _prefs.getString("heartId");
    if (heartId != null) {
      fallInLove(heartId);
    } else {
      emit(state.copyWith(inLove: false));
    }
  }

  Location myLocation = const Location(0, 0, 0);
  Location heartLocation = const Location(0, 0, 0);
  double heading = 0;
  double heartbeat = 0;

  fallInLove(String heartId) async {
    _heartRef = FirebaseDatabase.instance.ref(heartId);
    _prefs.setString("heartId", heartId);
    emit(state.copyWith(inLove: true));

    // final myLocation = await Geolocator.getCurrentPosition();
    // print(myLocation);
    // emit(state.copyWith(
    //   myLocation: Location(myLocation.latitude, myLocation.longitude),
    // ));
    // _userRef.set({
    //   "latitude": myLocation.latitude,
    //   "longitude": myLocation.longitude,
    // });

    Geolocator.getPositionStream().distinct().listen((position) {
      print(position);
      myLocation = Location(
        position.latitude,
        position.longitude,
        DateTime.now().millisecondsSinceEpoch,
      );
      _userRef.set({
        "latitude": myLocation.latitude,
        "longitude": myLocation.longitude,
        "timestamp": myLocation.timestamp,
      });
    });

    _heartRef.onValue.distinct().listen((event) {
      print("heart ${event.snapshot.value}");
      Map map = json.decode(json.encode(event.snapshot.value));
      heartLocation = Location(
        map["latitude"],
        map["longitude"],
        map["timestamp"],
      );
      // heartLocation = Location(
      //   49.823119,
      //   24.028971,
      //   DateTime.now()
      //       .subtract(const Duration(seconds: 10))
      //       .millisecondsSinceEpoch,
      // );
    });

    FlutterCompass.events?.listen((compassEvent) {
      heading = compassEvent.heading ?? 0;
      // emit(state.copyWith(
      //   heading: compassEvent.heading,
      // ));
    });

    Stream.periodic(const Duration(seconds: 1)).listen((event) {
      emit(state.copyWith(
        myLocation: myLocation,
        heartLocation: heartLocation,
        heading: heading,
        speed: heartbeat,
      ));
    });
  }
}

class MainState extends Equatable {
  final bool? inLove;
  final String? userId;
  final Location? myLocation;
  final Location? heartLocation;
  final double? heading;
  final double? speed;

  const MainState({
    this.inLove,
    this.userId,
    this.myLocation,
    this.heartLocation,
    this.heading,
    this.speed,
  });

  MainState copyWith({
    bool? inLove,
    String? userId,
    Location? myLocation,
    Location? heartLocation,
    double? heading,
    double? speed,
  }) =>
      MainState(
        inLove: inLove ?? this.inLove,
        userId: userId ?? this.userId,
        myLocation: myLocation ?? this.myLocation,
        heartLocation: heartLocation ?? this.heartLocation,
        heading: heading ?? this.heading,
        speed: speed ?? this.speed,
      );

  @override
  List<Object?> get props => [
        inLove,
        userId,
        myLocation,
        heartLocation,
        heading,
        speed,
      ];
}

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final int timestamp;

  const Location(this.latitude, this.longitude, this.timestamp);

  double getBearing(Location other) {
    return Geolocator.bearingBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  double getDistance(Location other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}
