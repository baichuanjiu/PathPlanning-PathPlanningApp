import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/dio_model.dart';

class PathExtractionPage extends StatefulWidget {
  const PathExtractionPage({super.key});

  @override
  State<PathExtractionPage> createState() => _PathExtractionPageState();
}

class _PathExtractionPageState extends State<PathExtractionPage> {
  ImagePicker imagePicker = ImagePicker();
  bool hasUploadedImage = false;

  bool isPending = false;
  bool hasGotResult = false;

  late XFile currentImage;
  late Uint8List currentImageBytes;
  late Uint8List resultImageBytes;

  final DioModel dioModel = DioModel();

  roadExtraction() async {
    try {
      Response response;
      var formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(currentImageBytes, filename: currentImage.name),
      });

      isPending = true;
      hasGotResult = false;
      setState(() {});

      response = await dioModel.dio.post('/roadExtraction', data: formData, options: Options(responseType: ResponseType.bytes));

      resultImageBytes = Uint8List.fromList(response.data);

      isPending = false;
      hasGotResult = true;

      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (hasUploadedImage) {
      if (isPending) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "道路提取",
            ),
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(currentImageBytes),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text("重新上传"),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text("道路提取"),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (hasGotResult) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "道路提取",
            ),
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(currentImageBytes),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                            if (mounted) {
                              if (image != null) {
                                currentImage = image;
                                currentImageBytes = await currentImage.readAsBytes();
                                isPending = false;
                                hasGotResult = false;
                                hasUploadedImage = true;
                                setState(() {});
                              }
                            }
                          },
                          child: const Text("重新上传"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/pathPlanning',arguments: {
                              'currentImage': currentImage,
                              'resultImageBytes': resultImageBytes,
                            });
                          },
                          child: const Text("路径规划"),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(resultImageBytes),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "道路提取",
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(currentImageBytes),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                          if (mounted) {
                            if (image != null) {
                              currentImage = image;
                              currentImageBytes = await currentImage.readAsBytes();
                              isPending = false;
                              hasGotResult = false;
                              hasUploadedImage = true;
                              setState(() {});
                            }
                          }
                        },
                        child: const Text("重新上传"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          roadExtraction();
                        },
                        child: const Text("道路提取"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "道路提取",
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 3),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: const Text("您可以通过点击下方按钮，上传一张1024 * 1024分辨率的图片对其进行道路提取。"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                        if (mounted) {
                          if (image != null) {
                            currentImage = image;
                            currentImageBytes = await currentImage.readAsBytes();
                            hasUploadedImage = true;
                            setState(() {});
                          }
                        }
                      },
                      child: const Text("上传图片"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
