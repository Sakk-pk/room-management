import 'package:room_management/domian/models/bed.dart';
import 'enum.dart';

class Room {
  // start IDs from 1
  static int _idCounter = 1;
  final String roomId;
  final RoomType type;
  int capacity;
  List<Bed> beds;
  
  Room({
    String? roomId,
    required this.type,
    required this.capacity,
  })  : roomId = roomId ?? (_idCounter++).toString(),
        beds = List.generate(
            capacity, (index) => Bed(bedId: '${_idCounter - 1}-$index'));

  void addBed() {
    beds.add(Bed(bedId: '${roomId}-${beds.length}'));
    capacity++;
  }

  void removeBed(String bedId) {
    beds.removeWhere((bed) => bed.bedId == bedId);
    capacity--;
  }

  void getAvailableBeds() {
    beds.where((bed) => bed.isAvailable()).toList();
  }

  void isRoomFull() {
    beds.every((bed) => !bed.isAvailable());
  }
  
  Map<String, dynamic> displayRoomInfo() {
    return {
      'roomId': roomId,
      'type': type,
      'capacity': capacity,
      'beds': beds.map((bed) => bed.toMap()).toList(),
    };
  }

}