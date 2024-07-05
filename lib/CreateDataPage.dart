import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr/SaveDataUtils.dart';
import 'package:flutter_qr/mob/MobUtils.dart';
import 'package:flutter_qr/mob/ScanUtils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CreateStylePage.dart';
import 'HomePage.dart';

class CreateDataPage extends StatefulWidget {
  const CreateDataPage({super.key});

  @override
  State<CreateDataPage> createState() => _CreateDataPageState();
}

class _CreateDataPageState extends State<CreateDataPage> {
  bool qrLoading = false;
  String createdState = '';
  bool showCreateBut = false;
  String qrDataType = "Text";
  bool isLoading = true;
  int netType = 1;
  int urlType = 1;
  final textController = TextEditingController();

  final netController = TextEditingController();
  final netPassController = TextEditingController();

  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final longitudeController = TextEditingController();
  final latitudeController = TextEditingController();

  final emailController = TextEditingController();
  final contentController = TextEditingController();

  final urlController = TextEditingController();
  late MobUtils adManager;

  @override
  void initState() {
    super.initState();
    textController.addListener(showCreteBut);
    netController.addListener(showCreteBut);
    netPassController.addListener(showCreteBut);
    countryController.addListener(showCreteBut);
    cityController.addListener(showCreteBut);
    longitudeController.addListener(showCreteBut);
    latitudeController.addListener(showCreteBut);
    emailController.addListener(showCreteBut);
    contentController.addListener(showCreteBut);
    urlController.addListener(showCreteBut);
    getQrDataType();
    seCState();
    adManager = ScanUtils.getMobUtils(context);
    adManager.loadAd(AdWhere.BACK);
    adManager.loadAd(AdWhere.SCAN);
  }

  @override
  void dispose() {
    super.dispose();
    textController.removeListener(showCreteBut);
    netController.removeListener(showCreteBut);
    netPassController.removeListener(showCreteBut);
    countryController.removeListener(showCreteBut);
    cityController.removeListener(showCreteBut);
    longitudeController.removeListener(showCreteBut);
    latitudeController.removeListener(showCreteBut);
    emailController.removeListener(showCreteBut);
    contentController.removeListener(showCreteBut);
    urlController.removeListener(showCreteBut);
  }

  Future<void> getQrDataType() async {
    qrDataType = (await SaveDataUtils.getString(SaveDataUtils.createState))!;
    createdState =
        qrDataType; // Assuming you want to set createdState here too.
    setState(() {
      isLoading = false;
    });
  }

  void seCState() async {
    createdState = (await SaveDataUtils.getString(SaveDataUtils.createState))!;
  }
  void backFun() async {
    if (!adManager.canShowAd(AdWhere.BACK)) {
      adManager.loadAd(AdWhere.BACK);
    }
    setState(() {
      qrLoading = true;
    });
    ScanUtils.showScanAd(context, AdWhere.BACK, () {
      setState(() {
        qrLoading = false;
      });
    }, () {
      Navigator.pop(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        backFun();
      },
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildCreateDataPage(context),
      ),
    );
  }

  Widget _buildCreateDataPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/bg_main.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        backFun();
                      },
                    ),
                    const Text("Create",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          color: Colors.white,
                        )),
                    const Spacer(),
                    if (showCreateBut)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: GradientButton(
                          width: 75,
                          padding: 8,
                          colors: const [
                            Color(0xFF35D4FF),
                            Color(0xFFFF00FF),
                            Color(0xFFFFFF86)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          onPressed: () {
                            showScanAd();
                          },
                          child: const Text(
                            "Create",
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 14,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                getCreateView(),
                qrLoading
                    ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Colors.white,
                    size: 30,
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void showCreteBut() async {
    String? state = await SaveDataUtils.getString(SaveDataUtils.createState);
    if (state == null || state.isEmpty) {
      return;
    }
    bool data = (() {
      switch (state) {
        case "Text":
        case "Barcode":
          return textController.text.trim().isNotEmpty;
        case "Location":
          return countryController.text.trim().isNotEmpty ||
              cityController.text.trim().isNotEmpty ||
              longitudeController.text.trim().isNotEmpty ||
              latitudeController.text.trim().isNotEmpty;
        case "Wi-Fi":
          return netController.text.trim().isNotEmpty ||
              netPassController.text.trim().isNotEmpty;
        case "Email":
          return emailController.text.trim().isNotEmpty ||
              contentController.text.trim().isNotEmpty;
        case "URL":
        case "Facebook":
        case "YouTube":
        case "Instagram":
          return urlController.text.trim().isNotEmpty;
        default:
          return false;
      }
    })();
    setState(() {
      showCreateBut = data;
    });
  }
  void showScanAd() async {
    if (!adManager.canShowAd(AdWhere.SCAN)) {
      adManager.loadAd(AdWhere.SCAN);
    }
    setState(() {
      qrLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    ScanUtils.showScanAd(context, AdWhere.SCAN, () {
      setState(() {
        qrLoading = false;
      });
    }, () {
      jumpToCreateStylePage();
    });
  }
  void jumpToCreateStylePage() async {
    String? state = await SaveDataUtils.getString(SaveDataUtils.createState);
    String qrData = (() {
      switch (state) {
        case "Text":
        case "Barcode":
        case "URL":
          return textController.text;
        case "Location":
          return "${countryController.text},${cityController.text}, ${longitudeController.text}, ${latitudeController.text}";
        case "Wi-Fi":
          if (netType == 1) {
            return "WEP,${netController.text},${netPassController.text}";
          }
          if (netType == 2) {
            return "WEP/WPA2,${netController.text},${netPassController.text}";
          }
          if (netType == 3) {
            return "None,${netController.text},${netPassController.text}";
          }
          return "WEP,${netController.text},${netPassController.text}";
        case "Email":
          return "${emailController.text},${contentController.text}";
        case "Facebook":
        case "YouTube":
        case "Instagram":
          return urlController.text;
        default:
          return "";
      }
    })();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateStylePage(qrData: qrData),
      ),
    );
  }

  void _handleNetTypeChange(int netType) {
    // Handle the changed net type here
    netType = netType;
  }

  void onUrlTypeChanged(int value) {
    urlType = value;
  }

  Future<void> launchSearchOrUrl(String input) async {
    final Uri url;
    if (Uri.tryParse(input)?.hasAbsolutePath ?? false) {
      url = Uri.parse(input);
    } else {
      final query = Uri.encodeComponent(input);
      url = Uri.parse('https://www.google.com/search?q=$query');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final query = Uri.encodeComponent(input);
      await launchUrl(Uri.parse('https://www.google.com/search?q=$query'));
    }
  }

  Widget getCreateView() {
    print("showCreteBut=${qrDataType}");

    switch (qrDataType) {
      case "Text":
      case "Barcode":
      case "URL":
        return QrDataInput(
          qrDataType: qrDataType,
          textController: textController,
        );
      case "Wi-Fi":
        return QrWIFIInput(
          netController: netController,
          netPassController: netPassController,
          onNetTypeChanged: _handleNetTypeChange,
        );
      case "Email":
        return QrEmailInput(
            emailController: emailController,
            contentController: contentController);
      case "Facebook":
      case "YouTube":
      case "Instagram":
        return QrUrlInput(
            qrDataType: qrDataType,
            urlController: urlController,
            onUrlTypeChanged: onUrlTypeChanged);
      default:
        return QrDataInput(
          qrDataType: qrDataType,
          textController: textController,
        );
    }
  }
}

class QrDataInput extends StatelessWidget {
  final String? qrDataType;
  final TextEditingController textController;

  const QrDataInput({
    Key? key,
    required this.qrDataType,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (qrDataType == "URL") {
      textController.text = "https://";
    }
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF040A25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: 200,
                    child: TextField(
                      inputFormatters: qrDataType == "Barcode"
                          ? [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]'))
                            ]
                          : null,
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter the content to be included in the QR code here.',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrWIFIInput extends StatefulWidget {
  final TextEditingController netController;
  final TextEditingController netPassController;
  final Function(int) onNetTypeChanged;

  const QrWIFIInput({
    Key? key,
    required this.netController,
    required this.netPassController,
    required this.onNetTypeChanged,
  }) : super(key: key);

  @override
  _QrWIFIInputState createState() => _QrWIFIInputState();
}

class _QrWIFIInputState extends State<QrWIFIInput> {
  int netTypeData = 1;

  void _updateNetType(int newNetType) {
    setState(() {
      netTypeData = newNetType;
    });
    widget.onNetTypeChanged(newNetType);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF040A25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              "Encipher",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GradientButton(
                  width: 91,
                  height: 36,
                  padding: 8,
                  colors: netTypeData == 1
                      ? [
                          const Color(0xFF35D4FF),
                          const Color(0xFFFF00FF),
                          const Color(0xFFFFFF86),
                        ]
                      : [
                          const Color(0xFF2A2F46),
                          const Color(0xFF2A2F46),
                        ],
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    _updateNetType(1);
                  },
                  child: const Text(
                    "WEP",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                GradientButton(
                  padding: 8,
                  colors: netTypeData == 2
                      ? [
                          const Color(0xFF35D4FF),
                          const Color(0xFFFF00FF),
                          const Color(0xFFFFFF86),
                        ]
                      : [
                          const Color(0xFF2A2F46),
                          const Color(0xFF2A2F46),
                        ],
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    _updateNetType(2);
                  },
                  child: const Text(
                    "WPA/WPA2",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                GradientButton(
                  width: 91,
                  height: 36,
                  padding: 8,
                  colors: netTypeData == 3
                      ? [
                          const Color(0xFF35D4FF),
                          const Color(0xFFFF00FF),
                          const Color(0xFFFFFF86),
                        ]
                      : [
                          const Color(0xFF2A2F46),
                          const Color(0xFF2A2F46),
                        ],
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    _updateNetType(3);
                  },
                  child: const Text(
                    "None",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: widget.netController,
                    decoration: const InputDecoration(
                      hintText: 'Network Name',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: widget.netPassController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrLocationInput extends StatelessWidget {
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController longitudeController;
  final TextEditingController latitudeController;

  const QrLocationInput({
    Key? key,
    required this.countryController,
    required this.cityController,
    required this.longitudeController,
    required this.latitudeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF040A25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      hintText: 'Country',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      hintText: 'City',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: longitudeController,
                    decoration: const InputDecoration(
                      hintText: 'Longitude',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: latitudeController,
                    decoration: const InputDecoration(
                      hintText: 'Latitude',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrEmailInput extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController contentController;

  const QrEmailInput({
    Key? key,
    required this.emailController,
    required this.contentController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF040A25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 240,
                  child: TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      hintText: 'Content',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrUrlInput extends StatefulWidget {
  final String qrDataType;
  final TextEditingController urlController;
  final Function(int) onUrlTypeChanged;

  const QrUrlInput({
    Key? key,
    required this.qrDataType,
    required this.urlController,
    required this.onUrlTypeChanged,
  }) : super(key: key);

  @override
  _QrUrlInputState createState() => _QrUrlInputState();
}

class _QrUrlInputState extends State<QrUrlInput> {
  int urlTypeData = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUrlControllerText();
  }

  void _updateNetType(int newNetType) {
    setState(() {
      urlTypeData = newNetType;
    });
    widget.onUrlTypeChanged(newNetType);
    _setUrlControllerText();
  }

  void _setUrlControllerText() {
    String newText = '';
    if (widget.qrDataType == 'Facebook') {
      newText = urlTypeData == 1
          ? "https://www.facebook.com/"
          : "https://www.facebook.com/groups/";
    } else if (widget.qrDataType == 'YouTube') {
      newText = urlTypeData == 1
          ? "https://www.youtube.com/watch?v="
          : "https://www.youtube.com/channel/";
    } else if (widget.qrDataType == 'Instagram') {
      newText = urlTypeData == 1
          ? "https://www.instagram.com/"
          : "https://www.instagram.com/p/";
    }
    widget.urlController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("widget.qrDataType=${widget.qrDataType}");
    print("urlTypeData=${urlTypeData}");
    String oneBut = "Option 1"; // default value
    String twoBut = "Option 2"; // default value

    if (widget.qrDataType == 'Facebook') {
      oneBut = "Homepage";
      twoBut = "Group";
    }
    if (widget.qrDataType == 'YouTube') {
      oneBut = "Video";
      twoBut = "Channel";
    }
    if (widget.qrDataType == 'Instagram') {
      oneBut = "Homepage";
      twoBut = "Post link";
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 29),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF040A25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              "Encipher",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GradientButton(
                  width: 140,
                  height: 36,
                  padding: 8,
                  colors: urlTypeData == 1
                      ? [
                          const Color(0xFF35D4FF),
                          const Color(0xFFFF00FF),
                          const Color(0xFFFFFF86),
                        ]
                      : [
                          const Color(0xFF2A2F46),
                          const Color(0xFF2A2F46),
                        ],
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    _updateNetType(1);
                  },
                  child: Text(
                    oneBut,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                GradientButton(
                  width: 140,
                  height: 36,
                  padding: 8,
                  colors: urlTypeData == 2
                      ? [
                          const Color(0xFF35D4FF),
                          const Color(0xFFFF00FF),
                          const Color(0xFFFFFF86),
                        ]
                      : [
                          const Color(0xFF2A2F46),
                          const Color(0xFF2A2F46),
                        ],
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () {
                    _updateNetType(2);
                  },
                  child: Text(
                    twoBut,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181E36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: widget.urlController,
                    decoration: InputDecoration(
                      hintText: urlTypeData == 1 ? oneBut : twoBut,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
