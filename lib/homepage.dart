import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'directory_view.dart';

class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool show = false;

  // 打开文件视图
  void openDirectoryView() => showDirectoryView(true);
  void showDirectoryView(bool isShow) => setState(() => show = isShow);
  // 点击选择文件事件, 未授权进行授权
  void onSelectFile() async {
    if(await Permission.storage.request().isGranted) {
      openDirectoryView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: double.infinity,
      color: Color.fromARGB(255, 139, 233, 253),
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
                    onPressed: onSelectFile,
                    color: Color.fromARGB(255, 34, 87, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(22))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 17, color: Colors.white),
                        SizedBox(width: 5),
                        Text('打开目录', style: TextStyle(fontSize: 14, inherit: false))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          show ? Positioned(
            top: 0, right: 0, bottom: 0, left: 0,
            child: DirectoryView(showDirectoryView: showDirectoryView),
          ): Container()
        ],
      ),
    );
  }
}