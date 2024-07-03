import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPaper extends StatelessWidget {
  const SettingPaper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SettingModel(),
    );
  }
}

class SettingModel extends StatefulWidget {
  const SettingModel({super.key});

  @override
  _SettingModel createState() => _SettingModel();
}

class _SettingModel extends State<SettingModel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Settings'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _launchURL();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 34, right: 20, left: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 16),
                Text(
                  "Privacy",
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Color(0xFFCCCCCC),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://flutterchina.club/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '无法打开网页 $url';
    }
  }

}
