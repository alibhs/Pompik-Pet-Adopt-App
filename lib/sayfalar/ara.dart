import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  State<Ara> createState() => _AraState();
}

class _AraState extends State<Ara> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Arama Sayfasi"));
  }
}
