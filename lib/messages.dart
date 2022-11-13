import 'package:flutter/material.dart';
import 'package:neptune/types.dart';

class MessagesWidget extends StatefulWidget {
  final Berth berth;
  final dynamic docking;

  const MessagesWidget({Key? key, required this.berth, required this.docking}) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
