import 'package:room_management/domian/models/room.dart';
import 'package:room_management/domian/models/bed.dart';
import 'package:room_management/domian/models/enum.dart';

void main() {
  // Example usage of Room and Bed models
  Room room = Room(
    type: RoomType.general,
    capacity: 3,
  );

  print('Room Info: ${room.displayRoomInfo()}');

  // Add a bed to the room
  room.addBed();
  print('Updated Room Info after adding a bed: ${room.displayRoomInfo()}');

  // Remove a bed from the room
  room.removeBed(room.beds.first.bedId);
  print('Updated Room Info after removing a bed: ${room.displayRoomInfo()}');
}
