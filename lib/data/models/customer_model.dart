class CustomerModel {
  String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String username;
  String gender;
  DateTime? createdAt;
  CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.username,
    required this.gender,
    this.createdAt,
  });
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      username: map['username'] ?? '',
      gender: map['gender'] ?? 'Not set',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }
  String get fullName => "$firstName $lastName";
}
