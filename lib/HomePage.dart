import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'dart:io';

import 'QRViewPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool qrLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },

      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                  // Add your onPressed code here!
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Add your onPressed code here!
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Add your onPressed code here!
                },
              ),
            ],
          ),
        ),
        body: _buildHomePage(context),
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    List<String> imagePaths = [
      'assets/img/img_qr_bg_0.webp',
      'assets/img/img_qr_bg_1.webp',
      'assets/img/img_qr_bg_2.webp',
      'assets/img/img_qr_bg_3.webp',
      'assets/img/img_qr_bg_4.webp',
      'assets/img/img_qr_bg_5.webp',
      'assets/img/img_qr_bg_6.webp',
      'assets/img/img_qr_bg_7.webp',
      'assets/img/img_qr_bg_8.webp',
      'assets/img/img_qr_bg_9.webp',
      'assets/img/img_qr_bg_10.webp',
      'assets/img/img_qr_bg_11.webp',
      'assets/img/img_qr_bg_12.webp',
      'assets/img/img_qr_bg_13.webp',
      'assets/img/img_qr_bg_14.webp',
    ];
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/bg_main.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 86),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text("App Name",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFFFFFFF),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset('assets/img/icon_menu.webp'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 24),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  QRViewPage()),
                          );
                        },
                        child: Stack(alignment: Alignment.center, children: [
                          SizedBox(
                            width: 154,
                            height: 184,
                            child: Image.asset('assets/img/bg_button.webp'),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    Image.asset('assets/img/icon_qr_home.webp'),
                              ),
                              const Text('QR Scan',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF),
                                  ))
                            ],
                          ),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, top: 24),
                      child: GestureDetector(
                        onTap: () {},
                        child: Stack(alignment: Alignment.center, children: [
                          SizedBox(
                            width: 154,
                            height: 184,
                            child: Image.asset('assets/img/bg_button.webp'),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    Image.asset('assets/img/icon_create.webp'),
                              ),
                              const Text('Create',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF),
                                  ))
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(width: 16),
                      const Text(
                        "Featured styles",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset('assets/img/icon_direction.webp'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          _showToast('Click $index');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image:  DecorationImage(
                              image: AssetImage(imagePaths[index]),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: Image.asset('assets/img/ic_qr_code_2.webp'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
