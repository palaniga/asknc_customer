class User {
  int id;

  String name;
  String? code;
  String email;
  String phone;
  String? rawPhone;
  String? countryCode;
  String photo;
  String role;
  String walletAddress;
  String? accountName;
  String? accountNumber;
  String? bankName;
  String? ifscCode;
  User({
    required this.id,
    this.code,
    required this.name,
    required this.email,
    required this.phone,
    this.rawPhone,
    required this.countryCode,
    required this.photo,
    required this.role,
    required this.walletAddress,
     this.accountName,
     this.accountNumber,
     this.bankName,
    this.ifscCode
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? "",
      rawPhone: json['raw_phone'],
      walletAddress: json['wallet_address'] ?? "",
      countryCode: json['country_code'],
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "client",
      accountName: json['account_name']??"",
      accountNumber: json['account_number']??"",
      bankName: json['bank_name']??"",
      ifscCode: json['ifsc_code']??""
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'email': email,
      'phone': phone,
      'raw_phone': rawPhone,
      'country_code': countryCode,
      'photo': photo,
      'role_name': role,
      'wallet_address': walletAddress,
      'account_name':accountName,
      'account_number':accountNumber,
      'bank_name':bankName,
      'ifsc_code':ifscCode
    };
  }
}
