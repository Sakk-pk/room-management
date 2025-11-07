import 'package:test/test.dart';

import '../lib/domian/room.dart';
import '../lib/domian/patient.dart';

void main() {
  group('Room management', () {
    test('create rooms, assign, transfer', () {
      // create two rooms
      final r1 = Room(
        null,
        [],
        type: RoomType.GENERAL_WARD,
      ).createRoom(RoomType.GENERAL_WARD, 2);
      final r2 = Room(
        null,
        [],
        type: RoomType.PRIVATE_ROOM,
      ).createRoom(RoomType.PRIVATE_ROOM, 1);

      // create a patient and assign to r1
      final p = Patient('p1', name: 'Alice', age: 30, gender: 'F');
      final bed1 = r1.assignPatientToRoom(p);

      expect(bed1.isOccupied, isTrue);
      expect(r1.getAvailableBedCount(), equals(1));

      // transfer patient to r2 bed 1
      final destBedId = 'Room number: ${r2.roomId} - Bed number: 1';
      Room.transferPatient(p.patientId, r2.roomId, destBedId);

      expect(r2.beds.first.currentPatient?.patientId, equals(p.patientId));
      expect(r1.getAvailableBedCount(), equals(2));
    });
  });
}
