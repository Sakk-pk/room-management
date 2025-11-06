class Patient {
  final String patientId;
  final String name;
  int age;
  final String gender;

  Patient(
    this.patientId, {
    required this.name,
    required this.age,
    required this.gender
  });

  @override
  String toString() {
    return 'Patient{id: $patientId, name: $name, age: $age, gender: $gender}';
  }
}
