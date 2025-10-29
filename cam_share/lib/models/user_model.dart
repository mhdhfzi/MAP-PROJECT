class UserModel {
  final String uid;
  final String name;
  final String email;
  final String userType; // Beginner or Pro

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.userType = 'Beginner',
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'userType': userType,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        name: json['name'],
        email: json['email'],
        userType: json['userType'] ?? 'Beginner',
      );
}
