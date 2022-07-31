import 'package:animate_do/animate_do.dart';
import 'package:fakedata_api/models/user.dart';
import 'package:fakedata_api/pages/album.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

User? data;
void main() => runApp(Profile(
      profileData: data,
    ));

class Profile extends StatelessWidget {
  User? profileData;
  Profile({Key? key, required this.profileData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 700),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profile User'),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) {
                return <PopupMenuEntry<int>>[
                  PopupMenuItem(
                    // ignore: sort_child_properties_last
                    child: const Text('View Albums'),
                    value: 0,
                  ),
                  // ignore: sort_child_properties_last
                  const PopupMenuItem(child: Text('1'), value: 1),
                ];
              },
              onSelected: (val) {
                if (val == 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InitialAlbum(
                                userId: profileData!.id,
                              )));
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // ignore: sort_child_properties_last
            Expanded(
                // ignore: sort_child_properties_last
                child: ProfilePhoto(profileData: profileData),
                flex: 1),
            // ignore: sort_child_properties_last
            Expanded(
                // ignore: sort_child_properties_last
                child: DataPerson(profileData: profileData),
                flex: 2),
          ],
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    Key? key,
    required this.profileData,
  }) : super(key: key);

  final User? profileData;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        child: Center(
            child: Text(profileData!.name.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontSize: 100.0))));
  }
}

class DataPerson extends StatelessWidget {
  const DataPerson({
    Key? key,
    required this.profileData,
  }) : super(key: key);

  final User? profileData;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
          children: [
            ListTile(
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Name'),
                subtitle: Text(profileData!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Email'),
                subtitle: Text(profileData!.email,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Phone'),
                subtitle: Text(profileData!.phone,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Website'),
                subtitle: Text(profileData!.website,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Company'),
                subtitle: Text(profileData!.company["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        // ignore: avoid_unnecessary_containers
                        return Container(
                            child: AlertDialog(
                          title: const Text('¿Abrir dirección en Google Maps?'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No')),
                            ElevatedButton(
                                onPressed: () {
                                  double lat = double.parse(
                                      profileData!.address["geo"]["lat"]);
                                  double lng = double.parse(
                                      profileData!.address["geo"]["lng"]);
                                  openDirection(lat, lng);
                                },
                                child: const Text('Si')),
                          ],
                        ));
                      });
                },
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios, size: 20.0)),
                title: const Text('Address'),
                subtitle: Text(
                    profileData!.address["street"] +
                        "," +
                        " " +
                        profileData!.address["city"],
                    style: const TextStyle(fontWeight: FontWeight.bold)))
          ],
        ));
  }

  void openDirection(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
