// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';

import 'package:pet_adopt/widgetlar/gonderikarti.dart';

class TekliGonderi extends StatefulWidget {
  final String? gonderiId;
  final String? gonderiSahibiId;
  const TekliGonderi({
    Key? key,
    this.gonderiId,
    this.gonderiSahibiId,
  }) : super(key: key);

  @override
  State<TekliGonderi> createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {
  @override
  Gonderi? _gonderi;
  Kullanici? _gonderiSahibiId;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    gonderiGetir();
  }

  gonderiGetir() async {
    Gonderi gonderi = await FireStoreServisi()
        .tekliGonderiGetir(widget.gonderiId!, widget.gonderiSahibiId!);

    if (gonderi != null) {
      Kullanici? gonderiSahibi =
          await FireStoreServisi().kullaniciGetir(gonderi.yayinlayanId);

      setState(() {
        _gonderi = gonderi;
        _gonderiSahibiId = gonderiSahibi!;
        _yukleniyor = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Gönderi",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.orange,
        ),
        body: !_yukleniyor
            ? GonderiKarti(
                gonderi: _gonderi,
                yayinlayanId: _gonderiSahibiId,
              )
            : Center(child: CircularProgressIndicator()));
  }
}
