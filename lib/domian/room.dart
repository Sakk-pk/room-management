import 'bed.dart';
import 'patient.dart';

enum RoomType { GENERAL_WARD, PRIVATE_ROOM, ICU, EMERGENCY, OPERATING_ROOM }

class Room {
  static int _idCounter = 0;
  final String roomId;
  final RoomType type;
  int capacity;
  List<Bed> beds;
  // Registry of created rooms by roomId to prevent duplicates
  static final Map<String, Room> _registry = {};

  Room(String? roomId, this.beds, {required this.type, this.capacity = 0})
    : roomId = roomId ?? 'R00${_idCounter++}';

  Room createRoom(RoomType? type, int capacity) {
    String roomNumber = roomId;
    if (roomNumber.isEmpty) {
      throw ArgumentError('Room number cannot be empty.');
    }
    if (capacity <= 0) {
      throw ArgumentError('Room capacity must be greater than 0');
    }

    // Check for duplicate room number
    if (_registry.containsKey(roomNumber)) {
      throw StateError('Room "$roomNumber" already exists.');
    }

    final List<Bed> beds = List.generate(capacity, (index) {
      return Bed('Room number: ${roomNumber} - Bed number: ${index + 1}');
    });

    final room = Room(
      roomNumber,
      beds,
      type: RoomType.GENERAL_WARD,
      capacity: capacity,
    );
    _registry[roomNumber] = room;
    return room;
  }

  // create ICU room with 4 capacity
  Room icuRoom() {
    return createRoom(RoomType.ICU, 4);
  }

  // create Private room 1 capacity
  Room privateRoom() {
    return createRoom(RoomType.PRIVATE_ROOM, 1);
  }

  // create Emergency room with 2 capacity
  Room emergencyRoom() {
    return createRoom(RoomType.EMERGENCY, 2);
  }

  // create Operating room with 1 capacity
  Room operatingRoom() {
    return createRoom(RoomType.OPERATING_ROOM, 1);
  }

  bool isFull() => beds.every((bed) => bed.isOccupied);

  /// list all available bed
  List<Bed> availableBeds() {
    return beds.where((b) => b.isAvailable()).toList();
  }

  int getAvailableBedCount() => beds.where((bed) => bed.isAvailable()).length;

  Bed assignPatientToRoom(Patient patient) {
    if (isFull()) {
      throw ArgumentError('Room $roomId full. No Available bed.');
    }

    final availableBed = availableBeds().first;
    availableBed.assignPatients(patient);
    return availableBed;
  }

  Bed assignPatientToBed(Patient patient, String bedNumber) {
    final bed = beds.firstWhere(
      (bed) => bed.bedId == bedNumber,
      orElse: () =>
          throw ArgumentError('Bed $bedNumber is not found in room $roomId.'),
    );

    if (!bed.isAvailable()) {
      throw ArgumentError('Bed $bedNumber is already occupied.');
    }

    bed.assignPatients(patient);
    return bed;
  }

  void dischargePatient(String patientId) {
    for (final bed in beds) {
      if (bed.isOccupied && bed.currentPatient?.patientId == patientId) {
        bed.releasePatient();
        return;
      }
    }
    throw ArgumentError('Patient $patientId not found.');
  }

  static List<Room> getAllRooms() => _registry.values.toList();

  @override
  String toString() {
    return 'Room{room number: $roomId, type: $type, available: ${getAvailableBedCount()}/$capacity}';
  }
}
