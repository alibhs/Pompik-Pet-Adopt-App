// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatBox extends StatefulWidget {
  final String mesaj;
  final bool aktifKullanici;

  const ChatBox({
    Key? key,
    required this.mesaj,
    required this.aktifKullanici,
  }) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.aktifKullanici
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(18),
          margin: EdgeInsets.all(18),
          constraints: BoxConstraints(maxWidth: 220),
          decoration: BoxDecoration(
              color: widget.aktifKullanici
                  ? Colors.purple[300]
                  : Colors.orange[300],
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Text(
            widget.mesaj,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
