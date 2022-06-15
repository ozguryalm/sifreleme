import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController xController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Text> _strings = [];
  String _randomKey = 'Unknown';
  String _string = "Unknown";
  String _encrypted = "Unknown";
  String string = "";

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final cryptor = new PlatformStringCryptor();

    var key = await cryptor.generateRandomKey();
    print("randomKey: $key");

    var encrypted = await cryptor.encrypt(string, key);
    var decrypted = await cryptor.decrypt(encrypted, key);

    assert(decrypted == string);

    String wrongKey =
        "jIkj0VOLhFpOJSpI7SibjA==:RZ03+kGZ/9Di3PT0a3xUDibD6gmb2RIhTVF+mQfZqy0=";
    print("YANLIŞ KEY DENEMESİ \n");
    try {
      await cryptor.decrypt(encrypted, key);
    } on MacMismatchException {
      print("wrongly decrypted");
    }

    var salt = "Ee/aHwc6EfEactQ00sm/0A=="; // await cryptor.generateSalt();
    var password = "a_strong_password%./😋";
    var generatedKey = await cryptor.generateKeyFromPassword(password, salt);
    print("salt: $salt, key: $generatedKey");

    assert(generatedKey == wrongKey);

    setState(() {
      _randomKey = key;
      _string = string;
      _encrypted = encrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Yazı Şifreleme'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: ListView(
                  controller: scrollController,
                  children: _strings,
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _string = value;
                  });
                },
                controller: xController,
                onEditingComplete: () {
                  initPlatformState();

                  setState(() {
                    _strings.add(Text(
                      xController.text,
                      style: TextStyle(color: Colors.red),
                    ));
                    xController.clear();
                  });
                  setState(() {
                    scrollController.animateTo(scrollController.offset,
                        duration: Duration(milliseconds: 350),
                        curve: Curves.bounceIn);
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25))),
              ),
              Spacer(),
              Center(
                child: Text(
                    'Random key: $_randomKey\n\nString: $_string\n\nEncrypted: $_encrypted'),
              ),
              SizedBox(height: 150)
            ],
          ),
        ),
      ),
    );
  }
}
