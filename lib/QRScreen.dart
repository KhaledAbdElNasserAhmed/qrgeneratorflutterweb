import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class QRScreen extends StatefulWidget {
  @override

  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String qrdata = "test";



  @override
  Widget build(BuildContext context) {

    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width/1.5,
                child: TextField(
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "Enter name here..",
                  ),
                  onChanged: (text){
                    changeQR(text);
                  },
                ),
              ),
            ),
            Center(
              child: QrImage(
                data: qrdata,
                version: QrVersions.auto,
                size: 300.0,
              ),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                await  downloadImage(qrdata);
              },
              child: Text('Download QR'),
            )
          ],
        ));
  }
  void changeQR(String test) {
    setState(() {
      qrdata = test;
    });
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
    );
  }


}


Future<Image> toQrImageData(String text) async {
  try {
    final image = await QrPainter(
      data: text,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.cyan,
      emptyColor:Colors.white,
    ).toImage(300);
    final a = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = a!.buffer.asUint8List();
    print(pngBytes);
    final bytes = Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
      1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65,
      84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
      69, 78, 68, 174, 66, 96, 130 // prevent dartfmt
    ]);


    final codec = await instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();


    return Image.memory(bytes);;

  } catch (e) {
    throw e;
  }
}

Future<void> downloadImage(String qrCodeText) async {
  try {
    // first we make a request to the url like you did
    // in the android and ios version
    // final http.Response r = await http.get(
    // Uri.parse(imageUrl),
    // );
    final image = await QrPainter(
      data: qrCodeText,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.cyan,
      emptyColor:Colors.white,
    ).toImage(300);
    final a2 = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = a2!.buffer.asUint8List();


    // we get the bytes from the body
    final data  = Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
      1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65,
      84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
      69, 78, 68, 174, 66, 96, 130 // prevent dartfmt
    ]);;
    // and encode them to base64
    final base64data = base64Encode(pngBytes);

    // then we create and AnchorElement with the html package
    final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');

    // set the name of the file we want the image to get
    // downloaded to
    a.download = 'download.jpg';

    // and we click the AnchorElement which downloads the image
    a.click();
    // finally we remove the AnchorElement
    a.remove();
  } catch (e) {
    print(e);
  }
}