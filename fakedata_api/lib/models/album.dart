class Album {
  int userId;
  int id;
  String title;
  Album(this.userId, this.id, this.title);

  Album.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        id = json["id"],
        title = json["title"];
}
