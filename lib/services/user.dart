class User{
  final String userId;
  User({this.userId});
}
class UserData{
  final String userId;
  final String fullNames;
  final String email;
  final String phone;
  final String picture;
  final String address;
  final int aColor;
  final DateTime dob;
  final bool admin;
  UserData({this.userId, this.fullNames, this.email, this.phone, this.address, this.aColor, this.dob, this.picture, this.admin});

Map<String,dynamic> getDataMap(){
    return {
      "userId": userId,
      "fullNames":fullNames,
      "email": email,
      "phone": phone,
      "address": address,
      "aColor": aColor,
      "picture": picture,
      "dob": dob,
      "admin": admin
    };
  }
}