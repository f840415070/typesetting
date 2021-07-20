import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as PATH;

class FileList extends StatelessWidget {
  final List fileList;
  final Function onTapItem;

  FileList(this.fileList, this.onTapItem);

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    fileList.forEach((item) {
      tiles.add(ListTile(
        leading: item is Directory ?
        Icon(Icons.folder, color: Color.fromARGB(255, 135, 206, 235)) :
        Icon(Icons.description, color: Color.fromARGB(255, 102, 153, 102)),
        title: Text(PATH.basename(item.path), maxLines: 2, style: TextStyle(inherit: false, color: Colors.black)),
        onTap: () => onTapItem(item),
      ));
    });
    return ListView(
      children: ListTile.divideTiles(tiles: tiles, context: context).toList(),
    );
  }
}