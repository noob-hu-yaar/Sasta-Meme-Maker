

//import 'dart:html';
import 'dart:math';
import 'dart:ui' as ui;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey globalKey = new GlobalKey();

  String headerText = "";
  String footerText = "";


  File _image;
  File _imageFile;
  Random rng = new Random();
  bool imageSelected = false;

  Future getImage() async {
    var image;
    try {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("not allowing " + platformException);
    }
    setState(() {
      if (image != null) {
        imageSelected = true;
      } else {}
      _image = image;
    });
    new Directory('storage/emulated/0/' + 'MemeGenerator')
        .create(recursive: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
              child: Container(
          child: Column(
            children: [
              SizedBox(height: 25.0,),
              Image.asset("assets/pixx11.png", height: 110.0,),
              SizedBox(height: 10,),
              //Padding(padding: EdgeInsets.all(18.0)),
              Image.asset("assets/maker.png",height: 30,),

              RepaintBoundary(
                key: globalKey,
                            child: Stack(
                  children: [
                    _image != null ? Image.file(_image, height: 300,) : Container(),
                    Container(
                      height: 300,
                      padding: EdgeInsets.symmetric(vertical: 12.0,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        
                        children: [
                          Text(headerText,
                          
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 26.0,
                          ),),
                          Spacer(),
                          Text(footerText,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 26.0,
                          ),
                          textAlign: TextAlign.center,)
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              imageSelected ? Column(
                children: [
                TextField(
                onChanged: (val){
                  setState(() {
                    headerText = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Header Text"
                ),
              ) ,
              SizedBox(height: 10.0,),
              TextField(
                onChanged: (val){
                  setState(() {
                    footerText = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Footer Text"
                ),
              ),

              RaisedButton(
                onPressed: (){
                  takeSS();
                },
              child: Text("save"),
              ),
                ]
              ): Container(
                child: Center(
                  child: Text("SELECT IMAGE"),
                ),
              ),
              _imageFile != null ? Image.file(_imageFile) : Container(),
               
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          getImage();
        },
      child: Icon(Icons.add_a_photo),),
    
    );
    SizedBox(height: 10.0);
     
  }

  takeSS() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });

    _savefile( _imageFile);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);

  }

  _savefile(File file) async{
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions;
    permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
}

