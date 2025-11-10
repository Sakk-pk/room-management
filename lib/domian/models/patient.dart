import 'package:room_management/domian/models/enum.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid().v4();

class Patient {
  final String patientId;
  final String name;
  final PatientGender gender;
  final DateTime entryDate;
  DateTime? leaveDate;

  String? currentBed;
  List<String> bedHistroy = [];
  List<String> history = [];

  Patient({
    String? patientId,
    required this.name,
    required this.gender,
    required this.entryDate,
    this.leaveDate,
  }) : patientId = patientId ?? uuid;

  void assignBed(String bedId) {
    currentBed = bedId;
    bedHistroy.add(bedId);
  }

  void releaseBed() => currentBed = null;

  @override
  String toString() {
    return 'Patient{id: $patientId, name: $name, gender: $gender}';
  }
}
