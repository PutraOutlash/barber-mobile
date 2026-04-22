class User {
  String email;
  String password;

  User({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}
