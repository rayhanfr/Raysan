import 'dart:convert';
import 'dart:typed_data';
import 'package:biu_project/invitation/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import 'add.dart';

class MainInvite extends StatefulWidget {
  //const MainInvite({Key? key}) : super(key: key);
  const MainInvite({Key? key}) : super(key: key);
  @override
  MainInviteState createState() => MainInviteState();
}

class MainInviteState extends State<MainInvite> {
  //make list variable to accomodate all data from database
  String id = "";
  String username = "";
  List _get = [];
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PageLogin(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
        "Berhasil logout",
        style: TextStyle(fontSize: 16),
      )),
    );
  }

  //make different color to different card
  final _lightColors = [
    Colors.amber.shade300,
    Colors.lightGreen.shade300,
    Colors.lightBlue.shade300,
    Colors.orange.shade300,
    Colors.pinkAccent.shade100,
    Colors.tealAccent.shade100
  ];
  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    getPref();
    _getData();
  }

  Future _getData() async {
    print(username);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      print(username);
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          "https://nscis.nsctechnology.com/index.php?r=t-invitation/invitation-api&id=" +
              username));
      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // entry data to variabel list _get
        setState(() {
          _get = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 190, 245).withOpacity(0.5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //leading: Icon(Icons.menu),
        title: Text("Bina Insani University"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      //if not equal to 0 show data
      //else show text "no data available"

      body: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/images/bg2.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: _get.length != 0
            //we use masonry grid to make masonry card style
            ? MasonryGridView.count(
                crossAxisCount: 2,
                itemCount: _get.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          //routing into edit page
                          //we pass the id note
                          MaterialPageRoute(
                              builder: (context) => View(
                                    id: _get[index]['id_invitation'],
                                  )));
                    },
                    child: Card(
                      //make random color to eveery card
                      color: _lightColors[index % _lightColors.length],
                      child: Container(
                        //make 2 different height
                        // constraints:
                        // BoxConstraints(minHeight: (index % 2 + 1) * 85),
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${_get[index]['schedule_date']}',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              'Time: ${_get[index]['time_schedule']}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Invitation Code: ${_get[index]['invitation_code']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Status: ${_get[index]['status']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Desc: ${_get[index]['description']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "No Data Available",
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          backgroundColor: Color.fromARGB(255, 4, 211, 45),
          elevation: 4.0,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Guest'),
          // onPressed: () => null,
          onPressed: () {
            Navigator.push(
                context,
                //routing into add page
                MaterialPageRoute(builder: (context) => Add()));
          },
        ),
      ),
    );
  }
}
