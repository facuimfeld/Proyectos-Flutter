class User {
  int id = 0;
  String name = '';
  String username = '';
  String email = '';
  Map<String, dynamic> address = {};
  String phone = '';
  String website = '';
  Map<String, dynamic> company = {};

  User(this.id, this.name, this.username, this.email, this.address, this.phone,
      this.website, this.company);

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        username = json["username"],
        email = json["email"],
        address = json["address"],
        phone = json["phone"],
        website = json["website"],
        company = json["company"];
}
