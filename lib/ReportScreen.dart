import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';


class ReportScreen extends StatefulWidget {

  // Create the initialization Future outside of `build`:
  @override

  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('doctors').snapshots();

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
    FirebaseFirestore.instance.collection('doctors');
    return MaterialApp(
      home: report(),
    );



  }


}

class report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ScreenshotController screenshotController = ScreenshotController();

    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('doctors').snapshots();
    CollectionReference users =
    FirebaseFirestore.instance.collection('doctors');
    Future<void> batchDelete() {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      return users.get().then((querySnapshot) {
        querySnapshot.docs.forEach((document) {
          batch.delete(document.reference);
        });

        return batch.commit();
      });
    }
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Warning !"),
                  content: Text("Are you sure you want to delete ALL ?"),
                  actions: [
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed:  () {Navigator.of(context, rootNavigator: true).pop();},
                    ),
                    FlatButton(
                      child: Text("Delete"),
                      onPressed:  () {
                        batchDelete();
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    )],
                )
            );

          },
          child: const Icon(Icons.delete_forever),
          backgroundColor: Colors.red,
        ),
        appBar: AppBar(automaticallyImplyLeading: false,
          leading: IconButton (
            icon: Icon(Icons.download),
            onPressed: () async{
              final doc = pw.Document();
              final List<String>names =[];
              final List<Timestamp>dateadded =[];

              await FirebaseFirestore.instance.collection("doctors").get().then((querySnapshot) {
                querySnapshot.docs.forEach((result) {
                  names.add(result.data()!["name"]);
                  dateadded.add(result.data()!["dateadded"]);
                   // Page;

                });
              });



              doc.addPage(pw.MultiPage(
                  margin: pw.EdgeInsets.all(10),
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return <pw.Widget>[
                    pw.Table(
                    children: [
                    for (var i = 0; i < names.length; i++)
                    pw.TableRow(
                    children: [
                    pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment
                        .center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                    pw.Text(names[i],
                    style: pw.TextStyle(fontSize: 6)),
                    pw.Divider(thickness: 1)
                    ]
                    ),
                    pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment
                        .center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                    pw.Text(dateadded[i].toDate().toString(),
                    style: pw.TextStyle(fontSize: 6)),
                    pw.Divider(thickness: 1)
                    ]
                    ),

                    ]
                    )
                    ]
                    )
                    ];
                  }));





              /*doc.addPage(pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Center(
                      child: pw.Text(result.data()!["name"]),
                    ); // Center
                  }));

*/
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfPreview(
                    build: (format) => doc.save(),
                  )));


             /* doc.addPage(
                pw.MultiPage(
                  build: (context) => [
                    pw.Table.fromTextArray(context: context, data: <List<String>>[
                      <String>['Msg ID', 'DateTime', 'Type', 'Body'],
                      ...msgList.map(
                              (msg) => [msg.counter, msg.dateTimeStamp, msg.type, msg.body])
                    ]),
                  ],
                ),
              );

*/



      },
          ),title: Text("Users Report"),),
        body:

        loadReports(initialization: _initialization, usersStream: _usersStream),
      ),
    );
  }
}

class loadReports extends StatelessWidget {
  const loadReports({
    Key? key,
    required Future<FirebaseApp> initialization,
    required Stream<QuerySnapshot<Object?>> usersStream,
  }) : _initialization = initialization, _usersStream = usersStream, super(key: key);

  final Future<FirebaseApp> _initialization;
  final Stream<QuerySnapshot<Object?>> _usersStream;

  @override
  Widget build(BuildContext context) {
    final doc = pw.Document();
    return Center(
      child: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Container(
              child: Text(
                "Error",
                textDirection: TextDirection.rtl,
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong',
                      textDirection: TextDirection.rtl);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading", textDirection: TextDirection.rtl);
                }

                return new ListView(
                    children: snapshot.data!.docs.map((document) {
                      Timestamp nsd = document['dateadded'];

                      return new ListTile(
                        title: new Text(document['name']),
                        subtitle: new Text(nsd.toDate().toString()),




                      );
                    }).toList());




              },
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

