import 'dart:io';
import '../domian/patient.dart';
import '../domian/bed.dart';
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
      final typeRaw = r.type.toString().split('.').last;
      final typeStr = typeRaw
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
      stdout.writeln(
        '${i + 1}. ${r.roomId} ($typeStr) - ${r.getAvailableBedCount()}/${r.capacity} available',
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

    final typeRaw = targetRoom.type.toString().split('.').last;
    final typeStr = typeRaw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');

    if (targetRoom.isFull()) {
      stdout.writeln('Selected room ${targetRoom.roomId} ($typeStr) is full.');
      return;
    }

    stdout.write('Assign to a specific bed? (Y/N): ');
    final choice = (stdin.readLineSync() ?? '').trim().toLowerCase();
    try {
      if (choice == 'y') {
        stdout.writeln('Beds in ${targetRoom.roomId} ($typeStr):');
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
          'Patient ${patient.name} assigned to ${assigned.bedId} in room ${targetRoom.roomId} ($typeStr).',
        );
      } else {
        final assigned = targetRoom.assignPatientToRoom(patient);
        stdout.writeln(
          'Patient ${patient.name} assigned to ${assigned.bedId} in room ${targetRoom.roomId} ($typeStr).',
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
      final sTypeRaw = sourceRoom.type.toString().split('.').last;
      final sTypeStr = sTypeRaw
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
      stdout.writeln(
        'Patient $pid discharged from room ${sourceRoom.roomId} ($sTypeStr).',
      );
    } catch (e) {
      stdout.writeln('Failed to discharge patient: $e');
    }
  }

  void transferPatientConsole() {
    stdout.writeln('\n--- Transfer Patient ---');

    stdout.write('Enter patient id to transfer: ');
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

    // locate source room and bed
    Room? sourceRoom;
    Bed? sourceBed;
    for (var r in rooms) {
      for (var b in r.beds) {
        if (b.isOccupied && b.currentPatient?.patientId == pid) {
          sourceRoom = r;
          sourceBed = b;
          break;
        }
      }
      if (sourceRoom != null) break;
    }

    if (sourceRoom == null || sourceBed == null) {
      stdout.writeln('Patient $pid not found in any room.');
      return;
    }

    final srcTypeRaw = sourceRoom.type.toString().split('.').last;
    final srcTypeStr = srcTypeRaw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    stdout.writeln(
      'Patient found in room ${sourceRoom.roomId} ($srcTypeStr), bed ${sourceBed.bedId}.',
    );

    // choose destination room
    stdout.writeln('\nAvailable rooms:');
    for (var i = 0; i < rooms.length; i++) {
      final r = rooms[i];
      final typeRaw = r.type.toString().split('.').last;
      final typeStr = typeRaw
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
      stdout.writeln(
        '${i + 1}. ${r.roomId} ($typeStr) - ${r.getAvailableBedCount()}/${r.capacity} available',
      );
    }

    stdout.write('Choose destination room by number: ');
    final roomChoice = stdin.readLineSync()?.trim() ?? '';
    final idx = int.tryParse(roomChoice);
    Room? targetRoom;
    if (idx != null && idx > 0 && idx <= rooms.length) {
      targetRoom = rooms[idx - 1];
    } else {
      stdout.writeln('Invalid room selection.');
      return;
    }

    // pick bed in target room
    final tTypeRaw = targetRoom.type.toString().split('.').last;
    final tTypeStr = tTypeRaw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    stdout.writeln('Beds in ${targetRoom.roomId} ($tTypeStr):');
    for (var b in targetRoom.beds) {
      final status = b.isOccupied
          ? 'occupied by ${b.currentPatient?.name}'
          : 'available';
      stdout.writeln(' - ${b.bedId} ($status)');
    }

    stdout.write('Enter destination bed number (or full id): ');
    final bedInput = stdin.readLineSync()?.trim() ?? '';
    if (bedInput.isEmpty) {
      stdout.writeln('Bed selection required.');
      return;
    }

    String destBedId;
    final maybeIndex = int.tryParse(bedInput);
    if (maybeIndex != null) {
      destBedId =
          'Room number: ${targetRoom.roomId} - Bed number: ${maybeIndex}';
    } else {
      destBedId = bedInput;
    }

    // perform transfer via domain API (will validate existence/availability)
    try {
      Room.transferPatient(pid, targetRoom.roomId, destBedId);
      stdout.writeln(
        'Patient $pid transferred to bed $destBedId in room ${targetRoom.roomId} ($tTypeStr).',
      );
    } catch (e) {
      stdout.writeln('Transfer failed: $e');
    }
  }

  void consoleRoomManagement() {
    while (true) {
      print('--- Room Management ---\n');
      print('1. Create new room');
      print('2. Assign room for patient');
      print('3. Transfer patient');
      print('4. Discharge patient');
      print('5. Check for available room');
      print('6. Exit the program');
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
          transferPatientConsole();
          break;
        case 4:
          dischargePatientConsole();
          break;
        case 5:
          final rooms = Room.getAllRooms();
          if (rooms.isEmpty) {
            stdout.writeln('No rooms created yet.');
          } else {
            stdout.writeln('Rooms:');
            for (var r in rooms) {
              // Make a human-friendly room type string: e.g. GENERAL_WARD -> General Ward
              final typeRaw = r.type.toString().split('.').last;
              final typeStr = typeRaw
                  .replaceAll('_', ' ')
                  .toLowerCase()
                  .split(' ')
                  .map(
                    (s) => s.isEmpty
                        ? s
                        : '${s[0].toUpperCase()}${s.substring(1)}',
                  )
                  .join(' ');

              stdout.writeln(
                ' - ${r.roomId} ($typeStr): ${r.getAvailableBedCount()}/${r.capacity} available',
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
        case 6:
          stdout.writeln('Exiting...');
          return;
        default:
          stdout.writeln('Invalid choice. Please select 1-6.');
      }
    }
  }
}
