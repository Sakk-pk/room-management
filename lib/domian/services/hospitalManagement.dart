import 'package:room_management/domian/models/patient.dart';
import 'package:room_management/domian/models/room.dart';
import 'package:room_management/domian/models/bed.dart';

class Hospitalmanagement {
  List<Room> rooms = [];
  List<Bed> beds = [];
  List<Patient> patients = [];
  
  void addRoom(Room room) {
    rooms.add(room);
    beds.addAll(room.beds);
  }

  void removeRoom(String roomId) {
    rooms.removeWhere((room) => room.roomId == roomId);
    beds.removeWhere((bed) => bed.bedId.startsWith(roomId));
  }

  void addBedToRoom(String roomId) {
    var room = rooms.firstWhere((room) => room.roomId == roomId);
    room.addBed();
    beds.add(room.beds.last);
  }

  void removeBedFromRoom(String roomId, String bedId) {
    var room = rooms.firstWhere((room) => room.roomId == roomId);
    room.removeBed(bedId);
    beds.removeWhere((bed) => bed.bedId == bedId);
  }

  void assignPatientToBed(String bedId, Patient patient) {
    var bed = beds.firstWhere((bed) => bed.bedId == bedId);
    if (bed.isAvailable()) {
      bed.assignPatient(patient);
      patients.add(patient);
    } else {
      throw Exception('Bed $bedId is not available.');
    }
  }

  void removePatientFromBed(String bedId) {
    var bed = beds.firstWhere((bed) => bed.bedId == bedId);
    if (!bed.isAvailable()) {
      bed.releasePatient();
    } else {
      throw Exception('Bed $bedId is already available.');
    }
  }

  getAvailableBeds() {
    return beds.where((bed) => bed.isAvailable()).toList();
  }

  displayAllRoomsInfo() {
    return rooms.map((room) => room.displayRoomInfo()).toList();
  }

  displayAllPatientsInfo() {
    return patients;
  }


}