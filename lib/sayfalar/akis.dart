import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class Akis extends StatefulWidget {
  const Akis({Key? key}) : super(key: key);

  @override
  State<Akis> createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Akış Sayfasi"));
  }
}
