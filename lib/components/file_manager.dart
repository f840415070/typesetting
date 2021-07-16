import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';

class FileManager extends StatefulWidget {
  final VoidCallback closeFileManager;

  FileManager({Key key, this.closeFileManager}): super(key: key);

  @override
  State<StatefulWidget> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final String _rootPath = '/storage/emulated/0';
  final RegExp txt = RegExp(r"\.txt$");
  final List<String> endSymbols = ['。', '」', '！', '？', '”'];
  List<String> _pathStack = [];
  String _currentDirName;
  List _dirFileList = [];
  bool _canUse = true;

  @override
  void initState() {
    super.initState();
    pathUpdate();
  }

  // 关闭文件视图
  void close() {
    widget.closeFileManager();
  }

  // 返回上一级
  void pathBack() {
    _pathStack.removeLast();
    if (_pathStack.length < 1) return close();
    pathUpdate(path: _pathStack.last, isBack: true);
  }
  // 更新当前文件路径
  void pathUpdate({String path, bool isBack: false}) {
    if (path == null) path = _rootPath;
    setState(() {
      _currentDirName = path.split('/').last;
      if (!isBack) _pathStack.add(path);
      dirFileListFor(path);
    });
  }
  // 获取路径下文件目录
  void dirFileListFor(String path) {
    Directory thisDir = Directory(path);
    thisDir.list().toList().then((list) => setState(() => _dirFileList = list));
  }
  void tapDirFileItem(item) {
    if (item is Directory) {
      pathUpdate(path: item.path);
    } else {
      if (txt.hasMatch(item.path) && _canUse) {
        setState(() {
          _canUse = false;
        });
        typesetting(item.path);
      } else {
        showDialogOf('目标文件不正确，请重新选择一个txt文本文件');
      }
    }
  }

  void typesetting(String path) async {
    File file = File(path);
    var pathSlices = path.split('/');
    pathSlices.last = '【副本】' + pathSlices.last;
    File targetFile = File(pathSlices.join('/'));
    targetFile.createSync();

    String resultStr = '';
    String lastLineWord = '';
    bool addFlag = false;
    List<String> lines;
    var encoding;

    try {
      lines = await file.readAsLines();
      encoding = utf8;
    } catch (e) {
      lines = await file.readAsLines(encoding: gbk);
      encoding = gbk;
    }
    for (var line in lines) {
      line = line.trimRight();
      if (line == '') continue;
      if (!endSymbols.any((element) => element == lastLineWord)) addFlag = true;
      if (line.trimLeft()[0] == '」') addFlag = true;

      if (addFlag) resultStr += line.trim();
      else resultStr += '\n$line';

      addFlag = false;
      lastLineWord = line[line.length - 1];
    }
    targetFile.writeAsString(resultStr, mode: FileMode.append, encoding: encoding);
    showDialogOf('排版成功！已在该路径下生成文件：${pathSlices.last}');
    setState(() {
      _canUse = true;
    });
    dirFileListFor(_pathStack.last);
  }

  Future<bool> showDialogOf(String content) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('操作提示'),
            content: Text(content),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('确定')
              )
            ],
          );
        }
    );
  }

  // 文件目录列表
  List<Widget> dirFileListWidgets() {
    List<Widget> _listWidgets = [];
    _dirFileList.forEach((item) {
      _listWidgets.add(ListTile(
        leading: item is Directory ?
          Icon(Icons.folder, color: Color.fromARGB(255, 135, 206, 235)) :
          Icon(Icons.description, color: Color.fromARGB(255, 102, 153, 102)),
        title: Text(item.path.split('/').last, maxLines: 2, style: TextStyle(inherit: false, color: Colors.black),),
        onTap: () {tapDirFileItem(item);}
      ));
    });
    return ListTile.divideTiles(tiles: _listWidgets, context: context).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: double.infinity,
      color: Color.fromARGB(120, 0, 0, 0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
          ),
          child: Stack(
            children: [
              // header
              Positioned(
                top: 0, left: 0, right: 0, height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  padding: EdgeInsets.only(left: 10, top: 8),
                  child: Column(
                    children: [
                      Text(
                          _currentDirName,
                          style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 38, 38, 38), inherit: false)
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 30, height: 25,
                              child: FlatButton(
                                color: Colors.white,
                                child: Icon(Icons.arrow_back, size: 15),
                                padding: EdgeInsets.only(left: 2, right: 2),
                                onPressed: pathBack,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // 文件 list
              Positioned(
                top: 60, right: 0, bottom: 50, left: 0,
                child: Container(
                  child: MediaQuery.removePadding(
                      context: context, removeTop: true,
                      child: ListView(
                        children: dirFileListWidgets(),
                      )
                  ),
                ),
              ),
              // 取消选择 退出文件视图
              Positioned(
                bottom: 0, left: 0, right: 0, height: 50,
                child: Container(
                  child: FlatButton(
                    onPressed: close,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                    ),
                    child: Text(
                        '取消选择',
                        style: TextStyle(fontSize: 16, color: Colors.black, inherit: false)
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}