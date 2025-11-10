import 'package:room_management/domian/models/enum.dart';
import 'package:uuid/uuid.dart';
import 'patient.dart';

var uuid = Uuid().v4();

class Bed {
  final String bedId;
  Patient? patient;
  BedStatus status;

  Bed({String? bedId, this.patient, this.status = BedStatus.AVAILABLE})
    : bedId = bedId ?? uuid;

  void assignPatient(Patient newPatient) {
    patient = newPatient;
    newPatient.assignBed(bedId);
    status = BedStatus.OCCUPIED;
  }

  void releasePatient() {
    if (patient != null) {
      patient!.releaseBed();
      patient = null;
      status = BedStatus.AVAILABLE;
    }
  }

  bool isAvailable() => status == BedStatus.AVAILABLE;

  Map<String, dynamic> toMap() {

    return {

      'bedId': bedId,

      'occupied': status == BedStatus.OCCUPIED,

    };

  }

  @override
  String toString() {
    return 'Bed{bed number: $bedId, patient: , oppcupied: .}';
  }
}
