import 'patient.dart';

class Bed {
  final String bedId;
  Patient? currentPatient;
  bool isOccupied;

  Bed(this.bedId, {this.currentPatient, this.isOccupied = false});

  void assignPatients(Patient newPatient) {
    if (isOccupied) {
      print('Bed $bedId is already occupied.');
    } else {
      currentPatient = newPatient;
      isOccupied = true;
    }
  }

  void releasePatient() {
    if (!isOccupied) {
      print('Bed is already empty.');
    } else {
      currentPatient = null;
      isOccupied = false;
    }
  }

  bool isAvailable() => !isOccupied;

  @override
  String toString() {
    return 'Bed{bed number: $bedId, patient: $currentPatient, oppcupied: $isOccupied.}';
  }
}
