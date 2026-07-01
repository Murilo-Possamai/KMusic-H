import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum VelocitySource { gps, accelerometer }

class VelocityData {
  final double speedKmh;
  final VelocitySource source;
  final double? latitude;
  final double? longitude;

  const VelocityData({
    required this.speedKmh,
    required this.source,
    this.latitude,
    this.longitude,
  });
}

class VelocityService {
  final _controller = StreamController<VelocityData>.broadcast();
  Stream<VelocityData> get velocityStream => _controller.stream;

  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  bool _isTracking = false;
  bool _useGPS = true;
  double _currentSpeed = 0;
  final List<double> _accelBuffer = [];
  static const int _bufferSize = 20;

  Position? _lastPosition;

  bool get isTracking => _isTracking;
  bool get useGPS => _useGPS;
  double get currentSpeedKmh => _currentSpeed;

  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> startTracking({bool useGPS = true}) async {
    if (_isTracking) return;
    _useGPS = useGPS;
    _isTracking = true;
    _currentSpeed = 0;

    if (useGPS) {
      await _startGPS();
    } else {
      _startAccelerometer();
    }
  }

  Future<void> _startGPS() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      _useGPS = false;
      _startAccelerometer();
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _gpsSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) {
      _handleGPSPosition(position);
    });
  }

  void _handleGPSPosition(Position position) {
    double speed = 0;

    if (position.speed >= 0) {
      speed = position.speed * 3.6;
    } else if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      final timeDelta =
          (position.timestamp.millisecondsSinceEpoch -
              _lastPosition!.timestamp.millisecondsSinceEpoch) /
          1000;
      if (timeDelta > 0) {
        speed = (distance / timeDelta) * 3.6;
      }
    }

    _lastPosition = position;
    _currentSpeed = speed.clamp(0, 300);

    _controller.add(VelocityData(
      speedKmh: _currentSpeed,
      source: VelocitySource.gps,
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }

  void _startAccelerometer() {
    _accelSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _handleAccelerometer(event);
    });
  }

  void _handleAccelerometer(AccelerometerEvent event) {
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    final acceleration = (magnitude - 9.81).clamp(0.0, double.infinity);

    _accelBuffer.add(acceleration);
    if (_accelBuffer.length > _bufferSize) {
      _accelBuffer.removeAt(0);
    }

    final avgAccel =
        _accelBuffer.reduce((a, b) => a + b) / _accelBuffer.length;

    _currentSpeed = (_currentSpeed + avgAccel * 0.1) * 0.95;
    _currentSpeed = _currentSpeed.clamp(0, 200);

    _controller.add(VelocityData(
      speedKmh: _currentSpeed * 3.6,
      source: VelocitySource.accelerometer,
    ));
  }

  void stopTracking() {
    _isTracking = false;
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _currentSpeed = 0;
    _accelBuffer.clear();
  }

  void switchSource({required bool useGPS}) {
    stopTracking();
    startTracking(useGPS: useGPS);
  }

  void dispose() {
    stopTracking();
    _controller.close();
  }
}
