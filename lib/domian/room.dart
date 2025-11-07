import 'bed.dart';
import 'patient.dart';

enum RoomType { GENERAL_WARD, PRIVATE_ROOM, ICU, EMERGENCY, OPERATING_ROOM }

class Room {
  // start IDs from 1
  static int _idCounter = 1;
  final String roomId;
  final RoomType type;
  int capacity;
  List<Bed> beds;
  // Registry of created rooms by roomId to prevent duplicates
  static final Map<String, Room> _registry = {};

  Room(String? roomId, this.beds, {required this.type, this.capacity = 0})
    : roomId = roomId ?? 'R00' + '${_idCounter++}';

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
      type: type ?? RoomType.GENERAL_WARD,
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

  /// Transfer a patient within this room to another bed in the same room.
  void transferPatientToBed(String patientId, String toBedId) {
    final currentBed = beds.firstWhere(
      (bed) => bed.isOccupied && bed.currentPatient?.patientId == patientId,
      orElse: () =>
          throw ArgumentError('Patient $patientId not found in room $roomId.'),
    );

    final targetBed = beds.firstWhere(
      (bed) => bed.bedId == toBedId,
      orElse: () =>
          throw ArgumentError('Bed $toBedId not found in room $roomId.'),
    );

    if (!targetBed.isAvailable()) {
      throw ArgumentError('Bed $toBedId in room $roomId is already occupied.');
    }

    final patient = currentBed.currentPatient;
    if (patient == null) {
      throw StateError('Internal error: expected patient in current bed.');
    }

    currentBed.releasePatient();
    targetBed.assignPatients(patient);
  }

  /// Transfer a patient (by id) to another room and bed, or to a bed in the same room.
  /// Throws ArgumentError if patient/room/bed not found or if destination bed occupied.
  static void transferPatient(
    String patientId,
    String toRoomId,
    String toBedId,
  ) {
    // find source room that currently has the patient
    final sourceRoom = _registry.values.firstWhere(
      (r) => r.beds.any(
        (b) => b.isOccupied && b.currentPatient?.patientId == patientId,
      ),
      orElse: () => throw ArgumentError(
        'Patient $patientId not found in any registered room.',
      ),
    );

    final targetRoom = _registry[toRoomId];
    if (targetRoom == null) {
      throw ArgumentError('Target room $toRoomId not found.');
    }

    if (sourceRoom.roomId == toRoomId) {
      // same room transfer
      sourceRoom.transferPatientToBed(patientId, toBedId);
      return;
    }

    final sourceBed = sourceRoom.beds.firstWhere(
      (b) => b.isOccupied && b.currentPatient?.patientId == patientId,
      orElse: () => throw ArgumentError(
        'Patient $patientId not found in room ${sourceRoom.roomId}.',
      ),
    );

    final patient = sourceBed.currentPatient;
    if (patient == null) {
      throw StateError('Internal error: expected patient in source bed.');
    }

    final destBed = targetRoom.beds.firstWhere(
      (b) => b.bedId == toBedId,
      orElse: () =>
          throw ArgumentError('Bed $toBedId not found in room $toRoomId.'),
    );

    if (!destBed.isAvailable()) {
      throw ArgumentError(
        'Bed $toBedId in room $toRoomId is already occupied.',
      );
    }

    // perform move
    sourceBed.releasePatient();
    destBed.assignPatients(patient);
  }

  /// Helper to lookup a room by id
  static Room? getRoom(String roomId) => _registry[roomId];

  static List<Room> getAllRooms() => _registry.values.toList();

  @override
  String toString() {
    return 'Room{room number: $roomId, type: $type, available: ${getAvailableBedCount()}/$capacity}';
  }
}
