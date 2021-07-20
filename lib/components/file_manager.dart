import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as PATH;
import 'package:fast_gbk/fast_gbk.dart';
import './file_list.dart';

const List<String> ENDINGS = ['。', '」', '！', '？', '”'];
const String ROOT = '/storage/emulated/0';
final RegExp TXT = RegExp(r"\.txt$");

String handleLines(List<String> lines) {
  String result = '';
  String lastWord = '';
  bool addFlag = false;

  for (var line in lines) {
    line = line.trimRight();
    if (line == '') continue;
    if (!ENDINGS.any((item) => item == lastWord) || line.trimLeft()[0] == '」') {
      addFlag = true;
    }
    if (addFlag) result += line.trim();
    else result += '\n$line';
    addFlag = false;
    lastWord = line[line.length - 1];
  }
  return result;
}

Future getTextDetail(String path) async {
  List<String> lines;
  var encoding;
  File textFile = File(path);

  try {
    lines = await textFile.readAsLines();
    encoding = utf8;
  } catch (e) {
    lines = await textFile.readAsLines(encoding: gbk);
    encoding = gbk;
  }
  return {
    'lines': lines,
    'encoding': encoding
  };
}

class FileManager extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) setLoading;

  FileManager({Key key, this.onClose, this.setLoading}): super(key: key);

  @override
  State<StatefulWidget> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final List<String> history = [];
  String currentDirName;
  List fileList = [];

  @override
  void initState() {
    super.initState();
    goUpdate();
  }

  // 关闭文件视图
  void close() {
    widget.onClose();
  }

  // 返回上一级
  void goBack() {
    history.removeLast();
    if (history.length < 1) return close();
    goUpdate(path: history.last, isBack: true);
  }

  // 更新当前文件路径
  void goUpdate({String path, bool isBack: false}) {
    if (path == null) path = ROOT;
    if (!isBack) history.add(path);
    setFileListOf(path);
    setState(() => currentDirName = PATH.basename(path));
  }

  // 获取路径下文件目录
  void setFileListOf(String path) {
    Directory(path).list().toList().then((list) {
      list = list.where((item) => PATH.basename(item.path)[0] != '.').toList();
      list.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      setState(() => fileList = list);
    });
  }

  void onTapItem(item) {
    if (item is Directory) {
      goUpdate(path: item.path);
    } else {
      if (TXT.hasMatch(item.path)) {
        handleTxtFile(item.path);
      } else {
        showDialogOf('目标文件不正确，请重新选择一个 [name].txt 文本文件');
      }
    }
  }

  void handleTxtFile(String path) async {
    widget.setLoading(true);
    String newFilename = '【副本】' + PATH.basename(path);
    String newFilePath = PATH.join(PATH.dirname(path), newFilename);
    Map textDetail = await getTextDetail(path);
    String result = handleLines(textDetail['lines']);

    File newFile = File(newFilePath);
    newFile.createSync();
    newFile.writeAsString(result, mode: FileMode.append, encoding: textDetail['encoding']);

    widget.setLoading(false);
    showDialogOf('排版成功！已在该路径下生成文件：$newFilename');
    setFileListOf(history.last);
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
                          currentDirName,
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
                                onPressed: goBack,
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
                      child: FileList(fileList, onTapItem)
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