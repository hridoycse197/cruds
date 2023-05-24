import 'dart:io';

import 'package:crudoperation/controller/data_controller.dart';
import 'package:crudoperation/model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'Helper/dbhelper.dart';

final dbHelper = DatabaseHelper();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final dataC = Get.put(DataController());
  // homepage layout
  @override
  Widget build(BuildContext context) {
    //_query();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _query();
          //dbHelper.queryAllPhotoRos();
        },
        child: Icon(Icons.query_builder),
      ),
      appBar: AppBar(
        title: const Text('sqflite'),
      ),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Column(
                children: [
                  Text('Name'),
                  TextField(
                    onChanged: dataC.name,
                  ),
                  Text('Dob'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(dataC.Dob.value != '' ? dataC.Dob.value : 'Not Selected'),
                      GestureDetector(
                          onTap: () async {
                            await dataC.pickDate(context: context);
                          },
                          child: const Icon(Icons.date_range_rounded))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Save Image'),
                      GestureDetector(
                          onTap: () async {
                            await dataC.pickImage(imageSource: ImageSource.camera);
                          },
                          child: const Icon(Icons.camera))
                    ],
                  ),
                  Obx(() => dataC.imageList.isEmpty
                      ? const Text('No Data')
                      : SizedBox(
                          height: 150,
                          width: 400,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dataC.imageList.length,
                            itemBuilder: (context, index) {
                              final item = dataC.imageList[index];
                              return Card(child: Image.file(File(item)));
                            },
                          ),
                        )),
                  ElevatedButton(
                      onPressed: () {
                        _insert(name: dataC.name.value, dob: dataC.Dob.value, imageLink: Uuid().v4());
                      },
                      child: const Text('Save')),
                ],
              )),
              Obx(() => dataC.allData.isEmpty
                  ? const Text('No Data')
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataC.allData.length,
                        itemBuilder: (context, index) {
                          final item = dataC.allData[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(item.name),
                                subtitle: Text(item.dob),
                              ),
                              if (item.images.isNotEmpty)
                                SizedBox(
                                  height: 150,
                                  width: 400,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: item.images.length,
                                    itemBuilder: (context, index) {
                                      final items = item.images[index];
                                      return Card(child: Image.file(File(items)));
                                    },
                                  ),
                                )
                            ],
                          );
                        },
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }

  // Button onPressed methods

  void _insert({required String name, required String dob, required String imageLink}) async {
    // row to insert
    Map<String, dynamic> row = {DatabaseHelper.columnName: name, DatabaseHelper.columnDob: dob, DatabaseHelper.imageLink: imageLink};
    final id = await dbHelper.insert(row);
    debugPrint('inserted row id: $id');
    if (dataC.imageList.isNotEmpty) {
      for (var element in dataC.imageList) {
        _insertPhoto(imageLink: imageLink, imagePath: element);
      }
    }
  }

  void _insertPhoto({required String imageLink, required String imagePath}) async {
    // row to insert
    Map<String, dynamic> row = {DatabaseHelper.imageLink: imageLink, DatabaseHelper.imagePath: imagePath};
    final id = await dbHelper.insertPhoto(row);
    debugPrint('inserted photo id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    dataC.allData.clear();
    for (final row in allRows) {
      final allx = await dbHelper.queryAllPhotoRows(uniqueName: row['imageLink']);

      final allxs = allx.map((e) => e['imagePath']).toList();
      // print(allxs.length);
      final allDatas =
          allRows.map((e) => DataModel(images: allxs, dob: e['dob'], imageLink: e['imageLink'], name: e['name'])).toList();
      dataC.allData.clear();
      dataC.allData.addAll(allDatas);
      for (var element in dataC.allData) {
        print(element.name);
        print(element.images.length);
      }
    }
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {DatabaseHelper.columnId: 1, DatabaseHelper.columnName: 'Mary', DatabaseHelper.columnDob: 32};
    final rowsAffected = await dbHelper.update(row);
    debugPrint('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    debugPrint('deleted $rowsDeleted row(s): row $id');
  }
}
