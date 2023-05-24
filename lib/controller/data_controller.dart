import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../Helper/dbhelper.dart';
import 'package:image_picker/image_picker.dart';
import '../model/data_model.dart';

class DataController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
  }

  final allData = RxList<DataModel>([]);
  final name = RxString('');
  final Dob = RxString('');
  final imageList = RxList<String>();

  pickDate({required BuildContext context}) async {
    final date =
        await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2050));

    if (date != null) {
      Dob.value = DateFormat('yyyy-MM-dd').format(date).toString();
    }
  }

  pickImage({required ImageSource imageSource}) async {
    final pickImage = await ImagePicker().pickImage(source: imageSource);
    if (pickImage != null) {
      imageList.add(pickImage.path);
      //final fileName = getExt(path: pickImage.path);
    }
  }
}
