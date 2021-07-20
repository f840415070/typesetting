import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/file_manager.dart';

class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isShowFileManager = false;
  bool isLoading = false;

  // 在授权状态下打开文件管理器
  void openFileManager() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        isShowFileManager = true;
      });
    }
  }

  void closeFileManager() {
    setState(() => isShowFileManager = false);
  }

  void setLoading(bool loading) {
    setState(() => isLoading = loading);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: double.infinity,
      color: Color.fromARGB(255, 16, 8, 39),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0, bottom: 0, left: 0,
            child: Container(
              width: double.infinity, height: double.infinity,
              child: Center(
                child: Container(
                  width: 160, height: 40,
                  child: RaisedButton(
                    onPressed: openFileManager,
                    color: Color.fromARGB(255, 94, 96, 206),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(22))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 17, color: Colors.white),
                        SizedBox(width: 5),
                        Text('文件管理器', style: TextStyle(fontSize: 14, inherit: false))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          isShowFileManager ? Positioned(
            top: 0, right: 0, bottom: 0, left: 0,
            child: FileManager(onClose: closeFileManager, setLoading: setLoading),
          ): Container(),
          isLoading ? Positioned(
            top: 0, right: 0, bottom: 0, left: 0,
            child: Container(
              width: double.infinity, height: double.infinity,
              color: Color.fromARGB(128, 0, 0, 0),
              child: Center(
                child: Text('处理中...', style: TextStyle(color: Colors.white, fontSize: 18, inherit: false)),
              ),
            )
          ) : Container()
        ],
      ),
    );
  }
}