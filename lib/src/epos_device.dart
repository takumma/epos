class EposDevice {
  final String deviceName;
  final String target;

  EposDevice({required this.deviceName, required this.target});

  factory EposDevice.fromMap(Map<String, dynamic> map) {
    return EposDevice(deviceName: map['deviceName'], target: map['target']);
  }
}
