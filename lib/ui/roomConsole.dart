import 'dart:io';
import '../domian/patient.dart';
import '../domian/room.dart';

class RoomConsole {
  int id = 0;
  RoomConsole();

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
          stdout.write('Capacity for general ward: ');
          final capacityInput = stdin.readLineSync()?.trim() ?? '';
          final capacity = int.tryParse(capacityInput) ?? 10;
          try {
            final room = Room(
              null,
              [],
              type: RoomType.GENERAL_WARD,
            ).createRoom(RoomType.GENERAL_WARD, capacity);
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
            stdout.writeln(
              'Created private room ${room.roomId} with capacity ${room.capacity}.',
            );
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
            stdout.writeln(
              'Created emergency room ${room.roomId} with capacity ${room.capacity}.',
            );
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
            stdout.writeln(
              'Created operating room ${room.roomId} with capacity ${room.capacity}.',
            );
          } catch (e) {
            stdout.writeln('Failed to create room: $e');
          }
          break;
        case 5:
          try {
            final room = Room(null, [], type: RoomType.ICU).icuRoom();
            stdout.writeln(
              'Created ICU room ${room.roomId} with capacity ${room.capacity}.',
            );
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
          createNewRoom();
          break;
        case 2:
          assignRoomForPatient();
          break;
        case 3:
          dischargePatientConsole();
          break;
        case 4:
          final rooms = Room.getAllRooms();
          if (rooms.isEmpty) {
            stdout.writeln('No rooms created yet.');
          } else {
            stdout.writeln('Rooms:');
            for (var r in rooms) {
              stdout.writeln(
                ' - ${r.roomId}: ${r.getAvailableBedCount()}/${r.capacity} available',
              );
              // show bed-level status with patient name when occupied
              for (var b in r.beds) {
                final status = b.isOccupied
                    ? 'occupied by ${b.currentPatient?.name}'
                    : 'available';
                stdout.writeln('    - ${b.bedId} ($status)');
              }
            }
          }
          break;
        case 5:
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
    print(
      'New patient add successfully name: ${patient.name}, id: ${patient.patientId}',
    );

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

    stdout.write('Choose room by number: ');
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

    stdout.write('Assign to a specific bed? (Y/N): ');
    final choice = (stdin.readLineSync() ?? '').trim().toLowerCase();
    try {
      if (choice == 'y') {
        stdout.writeln('Beds in ${targetRoom.roomId}:');
        for (var b in targetRoom.beds) {
          final status = b.isOccupied
              ? 'occupied by ${b.currentPatient?.name}'
              : 'available';
          stdout.writeln(' - ${b.bedId} ($status)');
        }
        stdout.write('Enter bed number: ');
        final bedInput = stdin.readLineSync()?.trim() ?? '';
        // If the user entered a simple number (e.g. "2"), convert it to the
        // full bedId string used by the Room/Bed model:
        // 'Room number: <roomId> - Bed number: <n>'
        String bedId;
        final maybeIndex = int.tryParse(bedInput);
        if (maybeIndex != null) {
          bedId =
              'Room number: ${targetRoom.roomId} - Bed number: ${maybeIndex}';
        } else {
          bedId = bedInput;
        }
        final assigned = targetRoom.assignPatientToBed(patient, bedId);
        stdout.writeln(
          'Patient ${patient.name} assigned to ${assigned.bedId}.',
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

  void dischargePatientConsole() {
    stdout.writeln('\n--- Discharge Patient ---');

    stdout.write('Enter patient id to discharge: ');
    final pid = stdin.readLineSync()?.trim() ?? '';
    if (pid.isEmpty) {
      stdout.writeln('Patient id is required.');
      return;
    }

    final rooms = Room.getAllRooms();
    if (rooms.isEmpty) {
      stdout.writeln('No rooms available.');
      return;
    }

    try {
      final sourceRoom = rooms.firstWhere(
        (r) => r.beds.any(
          (b) => b.isOccupied && b.currentPatient?.patientId == pid,
        ),
      );
      sourceRoom.dischargePatient(pid);
      stdout.writeln('Patient $pid discharged from room ${sourceRoom.roomId}.');
    } catch (e) {
      stdout.writeln('Failed to discharge patient: $e');
    }
  }
}
