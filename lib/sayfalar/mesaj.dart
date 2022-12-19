import 'package:flutter/widgets.dart';

class MesajKutusu extends StatefulWidget {
  const MesajKutusu({super.key});

  @override
  State<MesajKutusu> createState() => _MesajKutusuState();
}

class _MesajKutusuState extends State<MesajKutusu> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Mesaj Kutusu"));
  }
}
