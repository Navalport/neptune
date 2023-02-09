import 'package:flutter/material.dart';
import 'package:mooringapp/types.dart';

class MessagesWidget extends StatefulWidget {
  final Berth berth;
  final dynamic voyage;

  const MessagesWidget({Key? key, required this.berth, required this.voyage}) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
