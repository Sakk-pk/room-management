import 'dart:io';
import '../domian/patient.dart';
import '../domian/room.dart';

class RoomConsole {
  int id = 0;
  RoomConsole();

  void addPatient() {
    print('\n--- Add Patient ---');
    final pid = 'P00${++id}';

    stdout.write('Name: ');
    final name = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Age: ');
    final ageInput = stdin.readLineSync()?.trim() ?? '';
    final age = int.tryParse(ageInput) ?? 0;

    stdout.write('Gender: ');
    final gender = stdin.readLineSync()?.trim() ?? '';

    Patient patient = new Patient(pid, name: name, age: age, gender: gender);
    print(
      'New patient add successfully name: ${patient.name}, id: ${patient.patientId}',
    );
  }

  void createNewRoom() {
    while (true) {
      print('--- Create New Room ---\n');
      print('1. General ward room');
      print('2. Private room');
      print('3. Emergency room');
      print('4. Operating room');
      print('5. ICU room');
      print('6. Back');
      stdout.write('Choice: ');
      final choiceCnrInput = stdin.readLineSync()?.trim() ?? '';
      final choiceCnr = int.tryParse(choiceCnrInput) ?? 0;

      switch (choiceCnr) {
        case 1:
          try {
            final room = Room(
              null,
              [],
              type: RoomType.GENERAL_WARD,
            ).createRoom(RoomType.GENERAL_WARD, 10);
            stdout.writeln(
              'Created general ward room ${room.roomId} with capacity ${room.capacity}.',
            );
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 2:
          try {
            final room = Room(
              null,
              [],
              type: RoomType.PRIVATE_ROOM,
            ).privateRoom();
            stdout.writeln('Created private room ${room.roomId}');
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 3:
          try {
            final room = Room(
              null,
              [],
              type: RoomType.EMERGENCY,
            ).emergencyRoom();
            stdout.writeln('Created emergency room ${room.roomId}');
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 4:
          try {
            final room = Room(
              null,
              [],
              type: RoomType.OPERATING_ROOM,
            ).operatingRoom();
            stdout.writeln('Created operating room ${room.roomId}');
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 5:
          try {
            final room = Room(null, [], type: RoomType.ICU).icuRoom();
            stdout.writeln('Created ICU room ${room.roomId}');
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 6:
          return;
        default:
          stdout.writeln('Invalid choice. Please select 1-6.');
          break;
      }
    }
  }

  void consoleRoomManagement() {
    while (true) {
      print('--- Room Management ---\n');
      print('1. Create new room');
      print('2. Assign room for patient');
      print('3. Discharge patient');
      print('4. Check for available room');
      print('5. Exit the program');
      stdout.write('Choice: ');
      final choiceInput = stdin.readLineSync()?.trim() ?? '';
      final choice = int.tryParse(choiceInput) ?? 0;

      switch (choice) {
        case 1:
          addPatient();
          break;
        case 2:
          createNewRoom();
          break;
        case 3:
          assignRoomForPatient();
          break;
        case 4:
          stdout.writeln('Feature not implemented yet.');
          break;
        case 5:
          final rooms = Room.getAllRooms();
          if (rooms.isEmpty) {
            stdout.writeln('No rooms created yet.');
          } else {
            stdout.writeln('Rooms:');
            for (var r in rooms) {
              stdout.writeln(
                ' - ${r.roomId}: ${r.getAvailableBedCount()}/${r.capacity} available',
              );
            }
          }
          break;
        case 6:
          stdout.writeln('Exiting...');
          return;
        default:
          stdout.writeln('Invalid choice. Please select 1-6.');
      }
    }
  }

  void assignRoomForPatient() {
    stdout.writeln('\n--- Assign Room for Patient ---');

    final pid = 'P00${++id}';

    stdout.write('Name: ');
    final name = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Age: ');
    final ageInput = stdin.readLineSync()?.trim() ?? '';
    final age = int.tryParse(ageInput) ?? 0;

    stdout.write('Gender: ');
    final gender = stdin.readLineSync()?.trim() ?? '';

    final patient = Patient(pid, name: name, age: age, gender: gender);

    final rooms = Room.getAllRooms();
    if (rooms.isEmpty) {
      stdout.writeln('No rooms available. Create a room first.');
      return;
    }

    stdout.writeln('\nAvailable rooms:');
    for (var i = 0; i < rooms.length; i++) {
      final r = rooms[i];
      stdout.writeln(
        '${i + 1}. ${r.roomId} (${r.getAvailableBedCount()}/${r.capacity} available)',
      );
    }

    stdout.write('Choose room by number or enter room id: ');
    final roomChoice = stdin.readLineSync()?.trim() ?? '';
    Room? targetRoom;
    final idx = int.tryParse(roomChoice);
    if (idx != null && idx > 0 && idx <= rooms.length) {
      targetRoom = rooms[idx - 1];
    } else {
      try {
        targetRoom = rooms.firstWhere((r) => r.roomId == roomChoice);
      } catch (e) {
        targetRoom = null;
      }
    }

    if (targetRoom == null) {
      stdout.writeln('Room not found.');
      return;
    }

    if (targetRoom.isFull()) {
      stdout.writeln('Selected room is full.');
      return;
    }

    stdout.write('Assign to a specific bed? (y/N): ');
    final choice = (stdin.readLineSync() ?? '').trim().toLowerCase();
    try {
      if (choice == 'y') {
        stdout.writeln('Beds in ${targetRoom.roomId}:');
        for (var b in targetRoom.beds) {
          stdout.writeln(' - ${b.bedId} (occupied: ${b.isOccupied})');
        }
        stdout.write('Enter bed id: ');
        final bedId = stdin.readLineSync()?.trim() ?? '';
        final assigned = targetRoom.assignPatientToBed(patient, bedId);
        stdout.writeln(
          'Patient ${patient.name} assigned to ${assigned.bedId} in room ${targetRoom.roomId}.',
        );
      } else {
        final assigned = targetRoom.assignPatientToRoom(patient);
        stdout.writeln(
          'Patient ${patient.name} assigned to ${assigned.bedId} in room ${targetRoom.roomId}.',
        );
      }
    } catch (e) {
      stdout.writeln('Failed to assign patient: $e');
    }
  }
}
