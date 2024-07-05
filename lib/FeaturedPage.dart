import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr/CreateDataPage.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeaturedPage extends StatefulWidget {
  const FeaturedPage({super.key});

  @override
  State<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends State<FeaturedPage> {
  bool qrLoading = false;
  bool createDialog = false;

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
        body: _buildFeaturedPage(context),
      ),
    );
  }

  Widget _buildFeaturedPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/bg_main.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 56,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(
                            Icons.arrow_back,
                            color: Color(0xFFFFFFFF),
                            size: 30,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text("Featured styles",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFFFFFFF),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: SaveDataUtils.imagePaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (!createDialog) {
                              SaveDataUtils.saveInt(
                                  SaveDataUtils.createQrBg, index);
                              setState(() {
                                createDialog = true;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage(SaveDataUtils.imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child:
                                    Image.asset('assets/img/ic_qr_code_2.webp'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (createDialog)
                CustomDialog(
                  onClose: () {
                    setState(() {
                      createDialog = false;
                    });
                  },
                ),
            ]),
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

class CustomDialog extends StatelessWidget {
  final VoidCallback onClose;

  const CustomDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [
      'assets/img/icon_text.webp',
      'assets/img/icon_barcode.webp',
      'assets/img/icon_location.webp',
      'assets/img/icon_wifi.webp',
      'assets/img/icon_email.webp',
      'assets/img/icon_url.webp',
      'assets/img/icon_facebook.webp',
      'assets/img/icon_youtube.webp',
      'assets/img/icon_instagram.webp',
    ];
    List<String> imageText = [
      'Text',
      'Barcode',
      'Location',
      'Wi-Fi',
      'Email',
      'URL',
      "Facebook",
      "YouTube",
      "Instagram",
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          height: 464,
          decoration: BoxDecoration(
            color: const Color(0xFF252325),
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/img/bg_dialog.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.asset('assets/img/icon_close.webp'),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Create',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GradientButton(
                        colors: const [
                          Color(0xFF35D4FF),
                          Color(0xFFFF00FF),
                          Color(0xFFFFFF86)
                        ],
                        height: 50.0,
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Quick Create",
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 14,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  Image.asset('assets/img/icon_direction.webp'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: imagePaths.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              onClose();
                              SaveDataUtils.saveString(
                                  SaveDataUtils.createState, imageText[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateDataPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Image.asset(imagePaths[index]),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(imageText[index],
                                          style: const TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 12,
                                            color: Color(0xFFFFFFFF),
                                          ))
                                    ],
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    Key? key,
    this.colors,
    this.width,
    this.height,
    this.padding,
    this.onPressed,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  final List<Color>? colors;

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? padding;
  final GestureTapCallback? onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Color> _colors =
        colors ?? [theme.primaryColor, theme.primaryColorDark];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _colors),
        borderRadius: borderRadius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: _colors.last,
          highlightColor: Colors.transparent,
          borderRadius: borderRadius,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: height, width: width),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(padding ?? 16.0),
                child: DefaultTextStyle(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
